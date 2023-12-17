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
  private let workbench = RealmWorkbench()
  private var pickerManager: PickerManager?

  // Global States
  let isNameEmpty = BehaviorRelay<Bool>(value: true)
  let idValidate = BehaviorRelay<ValidationResult>(value: .empty)
  
  public enum Action {
    case profileImageButtonDidTap
    case nameTextFieldDidUpdate(String)
    case idTextFieldDidUpdate(String)
    case nextButtonDidTap
    case imageDidSelected(UIImage?)
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
      let pickerManager = PickerManager()
      self.pickerManager = pickerManager
      self.steps.accept(AppStep.imagePickerIsRequired(pickerManager, selectionLimit: 1))
      return .empty()
      
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
      let shared = AuthTempStorage.shared
      shared.saveUser(self.currentState.user)
      shared.saveProfileImage(self.currentState.profileImage)
      self.steps.accept(AppStep.termIsRequired(self.currentState.user))
      return .empty()
      
    case .imageDidSelected(let image):
      return .just(.updateProfileImage(image))
    }
  }
  
  public func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
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
    return Observable.merge(mutation, combineValidationsMutation)
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
      let userNetworking = UserNetworking()
      let userPhotoNetworking = UserPhotoNetworking()
      let disposable = userNetworking.request(
        .patchProfile(userId: user.searchID, name: user.name))
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
          single(.failure(error))
        })

      return Disposables.create {
        disposable.dispose()
      }
    }
  }
}
