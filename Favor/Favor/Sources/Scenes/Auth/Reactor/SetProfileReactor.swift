//
//  SetProfileReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/01/16.
//

import UIKit

import ReactorKit

final class SetProfileReactor: Reactor {
  
  // MARK: - Properties
  
  weak var coordinator: AuthCoordinator?
  var initialState: State
  let pickerManager: PHPickerManager
  
  enum Action {
    case ProfileImageButtonTap
    case nextButtonTap
  }
  
  enum Mutation {
    case updateProfileImage(UIImage?)
  }
  
  struct State {
    var profileImage: UIImage?
  }
  
  // MARK: - Initializer
  
  init(coordinator: AuthCoordinator, pickerManager: PHPickerManager) {
    self.coordinator = coordinator
    self.pickerManager = pickerManager
    self.initialState = State()
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .ProfileImageButtonTap:
      self.coordinator?.presentImagePicker()
      return Observable<Mutation>.empty()
      
    case .nextButtonTap:
      self.coordinator?.showTermFlow()
      return Observable<Mutation>.empty()
    }
  }
  
  func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    let pickerMutation = self.pickerManager.pickedContents
      .flatMap({ (picker) -> Observable<Mutation> in
        return .just(.updateProfileImage(picker.first))
      })
    return Observable.merge(mutation, pickerMutation)
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .updateProfileImage(let image):
      newState.profileImage = image
    }
    
    return newState
  }
  
}
