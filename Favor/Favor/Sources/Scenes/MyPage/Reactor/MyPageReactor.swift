//
//  MyPageReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/10.
//

import UIKit

import ReactorKit
import RxCocoa
import RxFlow

final class MyPageReactor: Reactor, Stepper {
  
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
      sections: MyPageReactor.setupMockSection()
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

// MARK: - Privates

private extension MyPageReactor {
  static func setupMockSection() -> [MyPageSection] {
    let giftCount = MyPageSectionItem.giftStat(GiftStatCellReactor())
    let giftCountSection = MyPageSection.giftStat([giftCount])
    
    let newProfile1 = MyPageSectionItem.newProfile(NewProfileCellReactor())
    let newProfile2 = MyPageSectionItem.newProfile(NewProfileCellReactor())
    let newProfileSection = MyPageSection.newProfile([newProfile1, newProfile2])
    
    let favor1 = MyPageSectionItem.favor(FavorCellReactor())
    let favor2 = MyPageSectionItem.favor(FavorCellReactor())
    let favor3 = MyPageSectionItem.favor(FavorCellReactor())
    let favorSection = MyPageSection.favor([favor1, favor2, favor3])
    
    let anniversary1 = MyPageSectionItem.anniversary(AnniversaryCellReactor())
    let anniversary2 = MyPageSectionItem.anniversary(AnniversaryCellReactor())
    let anniversary3 = MyPageSectionItem.anniversary(AnniversaryCellReactor())
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
