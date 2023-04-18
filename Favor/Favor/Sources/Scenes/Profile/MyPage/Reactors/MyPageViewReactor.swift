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
    var sections: [ProfileSection]
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
}

// MARK: - Temporaries

extension MyPageViewReactor {
  static func setupMockSection() -> [ProfileSection] {
    let newProfile1 = ProfileSectionItem.profileSetupHelper(FavorSetupProfileCellReactor())
    let newProfile2 = ProfileSectionItem.profileSetupHelper(FavorSetupProfileCellReactor())
    let newProfileSection = ProfileSection.profileSetupHelper([newProfile1, newProfile2])
    
    let favor1 = ProfileSectionItem.preferences(FavorPrefersCellReactor())
    let favor2 = ProfileSectionItem.preferences(FavorPrefersCellReactor())
    let favor3 = ProfileSectionItem.preferences(FavorPrefersCellReactor())
    let favorSection = ProfileSection.preferences([favor1, favor2, favor3])
    
    let anniversary1 = ProfileSectionItem.anniversaries(FavorAnniversaryCellReactor())
    let anniversary2 = ProfileSectionItem.anniversaries(FavorAnniversaryCellReactor())
    let anniversary3 = ProfileSectionItem.anniversaries(FavorAnniversaryCellReactor())
    let anniversarySection = ProfileSection.anniversaries([anniversary1, anniversary2, anniversary3])

    let friendSection = ProfileSection.friends(
      (1...10).map { _ in ProfileSectionItem.friends(ProfileFriendCellReactor()) }
    )
    
    return [newProfileSection, favorSection, anniversarySection, friendSection]
  }
}
