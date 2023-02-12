//
//  MyPageReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/10.
//

import ReactorKit
import RxCocoa
import RxFlow

final class MyPageReactor: Reactor, Stepper {
  
  // MARK: - Properties
  
  var initialState: State
  var steps = PublishRelay<Step>()
  
  enum Action {
    
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
  

}

// MARK: - Privates

private extension MyPageReactor {
  static func setupMockSection() -> [MyPageSection] {
    let giftCount1 = MyPageSectionItem.giftCount
    let giftCount2 = MyPageSectionItem.giftCount
    let giftCount3 = MyPageSectionItem.giftCount
    let giftCountSection = MyPageSection.giftCount([giftCount1, giftCount2, giftCount3])
    
    let newProfile1 = MyPageSectionItem.newProfile
    let newProfile2 = MyPageSectionItem.newProfile
    let newProfileSection = MyPageSection.newProfile([newProfile1, newProfile2])
    
    let favor1 = MyPageSectionItem.favor
    let favor2 = MyPageSectionItem.favor
    let favor3 = MyPageSectionItem.favor
    let favorSection = MyPageSection.favor([favor1, favor2, favor3])
    
    let anniversary1 = MyPageSectionItem.anniversary
    let anniversary2 = MyPageSectionItem.anniversary
    let anniversary3 = MyPageSectionItem.anniversary
    let anniversarySection = MyPageSection.anniversary([anniversary1, anniversary2, anniversary3])
    
    return [giftCountSection, newProfileSection, favorSection, anniversarySection]
  }
}