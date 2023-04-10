//
//  NewGiftViewReactor.swift
//  Favor
//
//  Created by 김응철 on 2023/02/09.
//

import UIKit

import FavorKit
import ReactorKit
import RxCocoa
import RxFlow
import RxSwift

final class NewGiftViewReactor: Reactor, Stepper {
  
  // MARK: - PROPERTIES
  
  var steps = PublishRelay<Step>()
  var initialState: State = State()
  let pickerManager: PHPickerManager
  
  enum Action {
    case cancelButtonDidTap
    case giftReceivedButtonDidTap
    case giftGivenButtonDidTap
    case categoryDidChange(FavorCategory)
    case titleTextFieldDidChange(String)
    case cellSelected(index: Int)
    case pinToggle(Bool)
    case photoRemoveButtonDidTap(index: Int)
  }
  
  enum Mutation {
    case setReceivedGift(Bool)
    case setCategory(FavorCategory)
    case setTitle(String)
    case setDataSource([UIImage])
    case setPin(Bool)
  }
  
  struct State {
    var isReceivedGift: Bool = true
    var currentCategory: FavorCategory = .lightGift
    var currentTitle: String = ""
    var currentImages: [UIImage] = []
    var newGiftPhotoSection = NewGiftPhotoSection.NewGiftPhotoSectionModel(
      model: 0,
      items: []
    )
    var isPinned: Bool = false
  }
  
  // MARK: - INITIALIZER
  
  init(pickerManager: PHPickerManager) {
    self.pickerManager = pickerManager
  }
  
  // MARK: - HELPERS
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .cancelButtonDidTap:
      self.steps.accept(AppStep.newGiftIsComplete)
      return .empty()

    case .giftGivenButtonDidTap:
      return .just(.setReceivedGift(false))
      
    case .giftReceivedButtonDidTap:
      return .just(.setReceivedGift(true))
      
    case .titleTextFieldDidChange(let title):
      return .just(.setTitle(title))
      
    case .categoryDidChange(let category):
      return .just(.setCategory(category))
      
    case .pinToggle(let state):
      return .just(.setPin(state))
      
    case .photoRemoveButtonDidTap(let index):
      var images = self.currentState.currentImages
      images.remove(at: index - 1)
      return .just(.setDataSource(images))
      
    case .cellSelected(let index):
      switch index {
      case 0:
        self.steps.accept(AppStep.imagePickerIsRequired(self.pickerManager))
        return .empty()
      default:
        return .empty()
      }
    }
  }
  
  func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    let pickedImages = self.pickerManager.pickedContents
      .flatMap { images -> Observable<Mutation> in
        return .just(.setDataSource(images))
      }
    return .merge(pickedImages, mutation)
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setReceivedGift(let state):
      newState.isReceivedGift = state
      
    case .setCategory(let category):
      newState.currentCategory = category
      
    case .setTitle(let title):
      newState.currentTitle = title
      
    case .setPin(let isPinned):
      newState.isPinned = isPinned
      
    case .setDataSource(let images):
      let items = images.map { NewGiftPhotoSection.NewGiftSectionItem.photo($0) }
      let sectionModel = NewGiftPhotoSection.NewGiftPhotoSectionModel(
        model: 0,
        items: items
      )
      newState.currentImages = images
      newState.newGiftPhotoSection = sectionModel
    }
    
    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map {
      var newState = $0
      newState.newGiftPhotoSection.items.insert(.empty, at: 0)
      return newState
    }
  }
}
