//
//  AuthSetProfileViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/01/16.
//

import OSLog
import UIKit

import FavorKit
import FavorNetworkKit
import ReactorKit
import RxCocoa
import RxFlow

public final class AuthSetProfileViewReactor: Reactor, Stepper {

  // MARK: - Properties
  
  public var initialState: State
  public var steps = PublishRelay<Step>()
  private let pickerManager = PHPickerManager()
  private let workbench = RealmWorkbench()

  // Global States
  let isNameEmpty = BehaviorRelay<Bool>(value: true)
  let idValidate = BehaviorRelay<ValidationResult>(value: .empty)
  
  public enum Action {
    case profileImageButtonDidTap
    case nameTextFieldDidUpdate(String)
    case idTextFieldDidUpdate(String)
    case nextButtonDidTap
  }
  
  public enum Mutation {
    case updateProfileImage(UIImage?)
    case updateUser(User)
    case updateNameValidationResult(Bool)
    case updateIDValidationResult(ValidationResult)
    case validateNextButton(Bool)
    case updateLoading(Bool)
  }
  
  public struct State {
    var profileImage: UIImage?
    var user: User
    var nameValidationResult: Bool = true
    var idValidationResult: ValidationResult = .empty
    var isNextButtonEnabled: Bool = false
    var isLoading: Bool = false
  }
  
  // MARK: - Initializer
  
  init(_ user: User) {
    self.initialState = State(user: user)
  }
  
  // MARK: - Functions
  
  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .profileImageButtonDidTap:
      self.steps.accept(AppStep.imagePickerIsRequired(self.pickerManager))
      return Observable<Mutation>.empty()

    case .nameTextFieldDidUpdate(let name):
      os_log(.debug, "Name TextField did update: \(name).")
      self.isNameEmpty.accept(name.isEmpty)
      var newUser = self.currentState.user
      newUser.name = name
      return .concat([
        .just(.updateNameValidationResult(name.isEmpty)),
        .just(.updateUser(newUser))
      ])

    case .idTextFieldDidUpdate(let id):
      os_log(.debug, "ID TextField did update: \(id).")
      let idValidationResult = AuthValidationManager(type: .id).validate(id)
      self.idValidate.accept(idValidationResult)
      var newUser = self.currentState.user
      newUser.searchID = id
      return .concat([
        .just(.updateUser(newUser)),
        .just(.updateIDValidationResult(idValidationResult))
      ])
      
    case .nextButtonDidTap:
      if self.currentState.isNextButtonEnabled {
        return .concat([
          .just(.updateLoading(true)),
          self.requestPatchProfile(self.currentState.user)
            .asObservable()
            .flatMap { user -> Observable<Mutation> in
              self.steps.accept(AppStep.termIsRequired(user))
              return .just(.updateLoading(false))
            }
        ])
      }
      return .empty()
    }
  }
  
  public func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    let pickerMutation = self.pickerManager.pickedContents
      .flatMap({ (picker) -> Observable<Mutation> in
        return .just(.updateProfileImage(picker.first))
      })
    let combineValidationsMutation: Observable<Mutation> = Observable.combineLatest(
      self.isNameEmpty,
      self.idValidate,
      resultSelector: { nameValidate, idValidate in
        if nameValidate == false && idValidate == .valid {
          return .validateNextButton(true)
        } else {
          return .validateNextButton(false)
        }
      })
    return Observable.merge(mutation, pickerMutation, combineValidationsMutation)
  }
  
  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .updateProfileImage(let image):
      newState.profileImage = image

    case .updateUser(let user):
      newState.user = user

    case .updateNameValidationResult(let isNameValid):
      newState.nameValidationResult = isNameValid

    case .updateIDValidationResult(let isIDValid):
      newState.idValidationResult = isIDValid

    case .validateNextButton(let isNextButtonEnabled):
      newState.isNextButtonEnabled = isNextButtonEnabled
      
    case .updateLoading(let isLoading):
      newState.isLoading = isLoading
    }
    
    return newState
  }
  
}

// MARK: - Privates

private extension AuthSetProfileViewReactor {
  func requestPatchProfile(_ user: User) -> Single<User> {
    return Single<User>.create { single in
      let networking = UserNetworking()
      let disposable = networking.request(
        .patchProfile(userId: user.searchID, name: user.name, userNo: user.identifier))
        .take(1)
        .asSingle()
        .subscribe(onSuccess: { response in
          do {
            let responseDTO: ResponseDTO<UserResponseDTO> = try APIManager.decode(response.data)
            single(.success(User(dto: responseDTO.data)))
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
}
