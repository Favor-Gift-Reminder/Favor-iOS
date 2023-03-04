//
//  MyPageViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/10.
//

import UIKit

import ReactorKit
import RxCocoa
import RxFlow

final class MyPageViewReactor: Reactor, Stepper {
  
  // MARK: - Properties
  
  var initialState: State
  var steps = PublishRelay<Step>()
  
  enum Action {
    case profileDidTap
  }
  
  enum Mutation {

  }
  
  struct State {
    var sections: [MyPageSection]
  }
  
  // MARK: - Initializer
  
  init() {
    self.initialState = State(
      sections: MyPageViewReactor.setupMockSection()
    )
  }
  
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .profileDidTap:
      self.steps.accept(AppStep.editMyPageIsRequired)
      return .empty()
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {

    }
    
    return newState
  }
}

// MARK: - Temporaries

extension MyPageViewReactor {
  static func setupMockSection() -> [MyPageSection] {
    let giftCount = MyPageSectionItem.giftStats(FavorGiftStatsCellReactor())
    let giftCountSection = MyPageSection.giftStats([giftCount])
    
    let newProfile1 = MyPageSectionItem.setupProfile(FavorSetupProfileCellReactor())
    let newProfile2 = MyPageSectionItem.setupProfile(FavorSetupProfileCellReactor())
    let newProfileSection = MyPageSection.setupProfile([newProfile1, newProfile2])
    
    let favor1 = MyPageSectionItem.prefers(FavorPrefersCellReactor())
    let favor2 = MyPageSectionItem.prefers(FavorPrefersCellReactor())
    let favor3 = MyPageSectionItem.prefers(FavorPrefersCellReactor())
    let favorSection = MyPageSection.prefers([favor1, favor2, favor3])
    
    let anniversary1 = MyPageSectionItem.anniversary(FavorAnniversaryCellReactor())
    let anniversary2 = MyPageSectionItem.anniversary(FavorAnniversaryCellReactor())
    let anniversary3 = MyPageSectionItem.anniversary(FavorAnniversaryCellReactor())
    let anniversarySection = MyPageSection.anniversary([anniversary1, anniversary2, anniversary3])

    let friend1 = MyPageSectionItem.friend(FriendCellReactor())
    let friend2 = MyPageSectionItem.friend(FriendCellReactor())
    let friend3 = MyPageSectionItem.friend(FriendCellReactor())
    let friend4 = MyPageSectionItem.friend(FriendCellReactor())
    let friend5 = MyPageSectionItem.friend(FriendCellReactor())
    let friendSection = MyPageSection.friend([friend1, friend2, friend3, friend4, friend5])
    
    return [giftCountSection, newProfileSection, favorSection, anniversarySection, friendSection]
  }
}
