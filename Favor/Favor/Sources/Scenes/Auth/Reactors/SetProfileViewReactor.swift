//
//  SetProfileViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/01/16.
//

import OSLog
import UIKit

import ReactorKit
import RxCocoa
import RxFlow

final class SetProfileViewReactor: Reactor, Stepper {
  
  // MARK: - Properties
  
  var initialState: State
  let pickerManager: PHPickerManager
  var steps = PublishRelay<Step>()

  // Global States
  let isNameEmpty = BehaviorRelay<Bool>(value: true)
  let idValidate = BehaviorRelay<ValidationResult>(value: .empty)
  
  enum Action {
    case profileImageButtonDidTap
    case nameTextFieldDidUpdate(String)
    case idTextFieldDidUpdate(String)
    case nextFlowRequested
  }
  
  enum Mutation {
    case updateProfileImage(UIImage?)
    case updateUserName(String)
    case updateNameValidationResult(Bool)
    case updateIDValidationResult(ValidationResult)
    case validateNextButton(Bool)
  }
  
  struct State {
    var profileImage: UIImage?
    var userName: String = ""
    var nameValidationResult: Bool = true
    var idValidationResult: ValidationResult = .empty
    var isNextButtonEnabled: Bool = false
  }
  
  // MARK: - Initializer
  
  init(pickerManager: PHPickerManager) {
    self.pickerManager = pickerManager
    self.initialState = State()
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .profileImageButtonDidTap:
      self.steps.accept(AppStep.imagePickerIsRequired(self.pickerManager))
      return Observable<Mutation>.empty()

    case .nameTextFieldDidUpdate(let name):
      os_log(.debug, "Name TextField did update: \(name)")
      self.isNameEmpty.accept(name.isEmpty)
      return .concat([
        .just(.updateNameValidationResult(name.isEmpty)),
        .just(.updateUserName(name))
      ])

    case .idTextFieldDidUpdate(let id):
      os_log(.debug, "ID TextField did update: \(id)")
      let idValidationResult = AuthValidationManager(type: .id).validate(id)
      self.idValidate.accept(idValidationResult)
      return .just(.updateIDValidationResult(idValidationResult))
      
    case .nextFlowRequested:
      self.steps.accept(AppStep.termIsRequired(self.currentState.userName))
      return Observable<Mutation>.empty()
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

    case .updateUserName(let userName):
      newState.userName = userName

    case .updateNameValidationResult(let isNameValid):
      newState.nameValidationResult = isNameValid

    case .updateIDValidationResult(let isIDValid):
      newState.idValidationResult = isIDValid

    case .validateNextButton(let isNextButtonEnabled):
      newState.isNextButtonEnabled = isNextButtonEnabled
    }
    
    return newState
  }
  
}
