//
//  SetProfileViewReactor.swift
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

final class SetProfileViewReactor: Reactor, Stepper {
  
  // MARK: - Properties
  
  var initialState: State
  let pickerManager: PHPickerManager
  var steps = PublishRelay<Step>()
  private let workbench = RealmWorkbench()
  private let networking = UserNetworking()

  // Global States
  let isNameEmpty = BehaviorRelay<Bool>(value: true)
  let idValidate = BehaviorRelay<ValidationResult>(value: .empty)
  
  enum Action {
    case viewNeedsLoaded
    case profileImageButtonDidTap
    case nameTextFieldDidUpdate(String)
    case idTextFieldDidUpdate(String)
    case nextFlowRequested
  }
  
  enum Mutation {
    case updateProfileImage(UIImage?)
    case updateUserNo(Int)
    case updateUserName(String)
    case updateUserId(String)
    case updateNameValidationResult(Bool)
    case updateIDValidationResult(ValidationResult)
    case validateNextButton(Bool)
    case updateLoading(Bool)
  }
  
  struct State {
    var profileImage: UIImage?
    var userNo: Int = .min
    var userName: String = ""
    var userId: String = ""
    var nameValidationResult: Bool = true
    var idValidationResult: ValidationResult = .empty
    var isNextButtonEnabled: Bool = false
    var isLoading: Bool = false
  }
  
  // MARK: - Initializer
  
  init(pickerManager: PHPickerManager) {
    self.pickerManager = pickerManager
    self.initialState = State()
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      return self.fetchStagedUserInfo()
        .asObservable()
        .flatMap { user -> Observable<Mutation> in
          return .concat([
            .just(.updateUserNo(user.identifier)),
            .just(.updateUserName(user.name)),
            .just(.updateUserId(user.searchID))
          ])
        }

    case .profileImageButtonDidTap:
      self.steps.accept(AppStep.imagePickerIsRequired(self.pickerManager))
      return Observable<Mutation>.empty()

    case .nameTextFieldDidUpdate(let name):
      os_log(.debug, "Name TextField did update: \(name).")
      self.isNameEmpty.accept(name.isEmpty)
      return .concat([
        .just(.updateNameValidationResult(name.isEmpty)),
        .just(.updateUserName(name))
      ])

    case .idTextFieldDidUpdate(let id):
      os_log(.debug, "ID TextField did update: \(id).")
      let idValidationResult = AuthValidationManager(type: .id).validate(id)
      self.idValidate.accept(idValidationResult)
      return .concat([
        .just(.updateUserId(id)),
        .just(.updateIDValidationResult(idValidationResult))
      ])
      
    case .nextFlowRequested:
      if self.currentState.isNextButtonEnabled {
        let userNo = self.currentState.userNo
        let userId = self.currentState.userId
        let userName = self.currentState.userName
        
        return .concat([
          .just(.updateLoading(true)),
          self.networking.request(.patchProfile(
            userId: userId,
            name: userName,
            userNo: userNo
          ))
          .flatMap { _ -> Observable<Mutation> in
            self.steps.accept(AppStep.termIsRequired(userName))
            return .just(.updateLoading(false))
          }
        ])
      }
      return .empty()
    }
  }
  
  func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
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
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .updateProfileImage(let image):
      newState.profileImage = image

    case .updateUserNo(let userNo):
      newState.userNo = userNo

    case .updateUserName(let userName):
      newState.userName = userName

    case .updateNameValidationResult(let isNameValid):
      newState.nameValidationResult = isNameValid

    case .updateIDValidationResult(let isIDValid):
      newState.idValidationResult = isIDValid
      
    case .updateUserId(let id):
      newState.userId = id

    case .validateNextButton(let isNextButtonEnabled):
      newState.isNextButtonEnabled = isNextButtonEnabled
      
    case .updateLoading(let isLoading):
      newState.isLoading = isLoading
    }
    
    return newState
  }
  
}

// MARK: - Privates

private extension SetProfileViewReactor {
  func fetchStagedUserInfo() -> Single<User> {
    return Single<User>.create { single in
      let task = Task {
        guard let user = await self.workbench.values(UserObject.self).first else {
          single(.failure(FavorError.optionalBindingFailure("UserObject")))
          return
        }
        single(.success(User(realmObject: user)))
      }

      return Disposables.create {
        task.cancel()
      }
    }
  }
}
