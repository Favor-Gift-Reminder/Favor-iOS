//
//  AuthTermViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/03/02.
//

import OSLog
import UIKit

import FavorKit
import FavorNetworkKit
import ReactorKit
import RxCocoa
import RxFlow

public final class AuthTermViewReactor: Reactor, Stepper {

  // MARK: - Properties

  public var initialState: State
  public var steps = PublishRelay<Step>()
  private var workbench = RealmWorkbench()
  private let keychain = KeychainManager()

  public enum Action {
    case viewNeedsLoaded
    case acceptAllDidTap
    case itemSelected(IndexPath)
    case nextButtonDidTap
  }

  public enum Mutation {
    case updateLoading(Bool)
    case updateTerms([Terms])
    case toggleAllTerms
    case validateNextButton
  }

  public struct State {
    var userProfile: UIImage?
    var userName: String
    var terms: [Terms] = []
    var termItems: [AuthTermSectionItem] = []
    var isAllAccepted: Bool = false
    var isNextButtonEnabled: Bool = false
    var isLoading: Bool = false
  }
  
  // MARK: - Initializer

  init(with user: User) {
    self.initialState = State(
      userProfile: AuthTempStorage.shared.profileImage,
      userName: user.name
    )
  }
  
  // MARK: - Functions

  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      return .just(.updateTerms(self.fetchTerms()))

    case .acceptAllDidTap:
      return .concat([
        .just(.toggleAllTerms),
        .just(.validateNextButton)
      ])

    case .itemSelected(let indexPath):
      var terms = self.currentState.terms
      terms[indexPath.item].isAccepted.toggle()
      print(terms)
      return .concat([
        .just(.updateTerms(terms)),
        .just(.validateNextButton)
      ])
      
    case .nextButtonDidTap:
      let storage = AuthTempStorage.shared
      let email = storage.email
      let password = storage.password
      
      return .concat([
        .just(.updateLoading(true)),
        self.requestSignUp(email: email, password: password)
          .asObservable()
          .flatMap { _ in
            // Request sign-in to retrieve access token
            return self.requestSignIn(email: email, password: password)
              .asObservable()
              .flatMap { token -> Observable<Mutation> in
                do {
                  guard
                    let emailData = email.data(using: .utf8),
                    let passwordData = password.data(using: .utf8),
                    let tokenData = token.data(using: .utf8)
                  else { return .empty() }
                  try self.keychain.set(
                    value: emailData,
                    account: KeychainManager.Accounts.userEmail.rawValue)
                  try self.keychain.set(
                    value: passwordData,
                    account: KeychainManager.Accounts.userPassword.rawValue)
                  try self.keychain.set(
                    value: tokenData,
                    account: KeychainManager.Accounts.accessToken.rawValue)
                  FTUXStorage.authState = .email
                } catch {
                  os_log(.error, "\(error)")
                  return .just(.updateLoading(false))
                }
                return .just(.updateLoading(false))
              }
          }
          .flatMap { _ in return self.requestPatchProfile() }
          .flatMap { _ in
            if let image = AuthTempStorage.shared.profileImage {
              let userPhotoNetworking = UserPhotoNetworking()
              return userPhotoNetworking.request(.postProfile(file: APIManager.createMultiPartForm(image)))
                .flatMap { _ in
                  self.steps.accept(AppStep.authIsComplete)
                  return Observable<Mutation>.just(.updateLoading(false))
                }
            } else {
              self.steps.accept(AppStep.authIsComplete)
              return .just(.updateLoading(false))
            }
          }
      ])
    }
  }

  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updateLoading(let isLoading):
      newState.isLoading = isLoading
      
    case .updateTerms(let terms):
      newState.terms = terms

    case .toggleAllTerms:
      newState.isAllAccepted.toggle()
      newState.terms = state.terms.map { term in
        var newTerm = term
        newTerm.isAccepted = newState.isAllAccepted
        return newTerm
      }

    case .validateNextButton:
      if state.terms.first(where: { $0.isRequired && !$0.isAccepted }) != nil {
        newState.isNextButtonEnabled = false
      } else {
        newState.isNextButtonEnabled = true
      }
    }

    return newState
  }

  public func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state

      newState.termItems = state.terms.map { AuthTermSectionItem(terms: $0) }
      newState.isAllAccepted = state.terms.filter { !$0.isAccepted }.isEmpty

      return newState
    }
  }
}

// MARK: - Newtorks

private extension AuthTermViewReactor {
  func requestSignup() -> Observable<Void> {
    let email = AuthTempStorage.shared.email
    let password = AuthTempStorage.shared.password
    
    return Observable<Void>.create { observer in
      let userNetworking = UserNetworking()
      return userNetworking.request(.postSignUp(email: email, password: password))
        .map(ResponseDTO<UserSingleResponseDTO>.self)
        .map { User(singleDTO: $0.data) }
        .subscribe(onNext: { _ in
          observer.onNext(())
          observer.onCompleted()
        })
    }
  }
  
  func requestPatchProfile() -> Observable<Void> {
    let userId = AuthTempStorage.shared.user.searchID
    let userName = AuthTempStorage.shared.user.name
    return Observable<Void>.create { observer in
      let userNetworking = UserNetworking()
      return userNetworking.request(.patchProfile(userId: userId, name: userName))
        .map(ResponseDTO<UserSingleResponseDTO>.self)
        .map { User(singleDTO: $0.data) }
        .subscribe(onNext: { user in
          UserInfoStorage.userNo = user.identifier
          self.updateUser(with: user)
          observer.onNext(())
          observer.onCompleted()
        })
    }
  }
  
  func updateUser(with user: User) {
    Task {
      try await self.workbench.write { transaction in
        transaction.update(user.realmObject(), update: .all)
      }
    }
  }
  
  func requestSignIn(email: String, password: String) -> Single<String> {
    return Single<String>.create { single in
      let networking = UserNetworking()
      let disposable = networking.request(.postSignIn(email: email, password: password))
        .take(1)
        .asSingle()
        .subscribe(onSuccess: { response in
          do {
            let responseDTO: ResponseDTO<SignInResponseDTO> = try APIManager.decode(response.data)
            single(.success(responseDTO.data.token))
          } catch {
            single(.failure(error))
          }
        }, onFailure: { error in
          single(.failure(error))
        })

      return Disposables.create {
        disposable.dispose()
      }
    }
  }
  
  func requestSignUp(email: String, password: String) -> Single<User> {
    return Single<User>.create { single in
      let networking = UserNetworking()
      let disposable = networking.request(.postSignUp(email: email, password: password))
        .take(1)
        .asSingle()
        .subscribe(onSuccess: { response in
          do {
            let responseDTO: ResponseDTO<UserSingleResponseDTO> = try APIManager.decode(response.data)
            single(.success(User(singleDTO: responseDTO.data)))
          } catch {
            single(.failure(error))
          }
        }, onFailure: { error in
          if let error = error as? APIError {
            os_log(.error, "\(error.description)")
          }
          single(.failure(error))
        })

      return Disposables.create {
        disposable.dispose()
      }
    }
  }
}

// MARK: - Privates

private extension AuthTermViewReactor {
  func fetchTerms() -> [Terms] {
    typealias JSON = [String: Any]

    guard let filePath = Bundle.main.path(forResource: "Term-Info", ofType: "plist") else {
      fatalError("Couldn't find the 'Term-Info.plist' file.")
    }

    var terms: JSON = [:]
    do {
      var plistRAW: Data
      if #available(iOS 16.0, *) {
        plistRAW = try Data(contentsOf: URL(filePath: filePath))
      } else {
        plistRAW = try NSData(contentsOfFile: filePath) as Data
      }
      terms = try PropertyListSerialization.propertyList(from: plistRAW, format: nil) as! JSON
    } catch {
      os_log(.error, "\(error)")
    }

    var decodedTerms: [Terms] = []
    terms.forEach { term in
      guard
        let value = term.value as? JSON,
        let title = value["Title"] as? String,
        let isRequired = value["Required"] as? Bool,
        let url = value["URL"] as? String,
        let index = value["Index"] as? Int
      else { return }

      let term = Terms(title: title, isRequired: isRequired, url: url, index: index)
      decodedTerms.append(term)
    }

    return decodedTerms.sorted(by: { $0.index < $1.index })
  }
}
