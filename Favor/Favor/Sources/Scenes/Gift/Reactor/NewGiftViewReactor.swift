//
//  NewGiftViewReactor.swift
//  Favor
//
//  Created by 김응철 on 2023/02/09.
//

//import UIKit
//
//import ReactorKit
//
//final class NewGiftViewReactor: Reactor {
//  
//  enum Action {
//    case viewDidLoad
//  }
//  
//  enum Mutation {
//    case setDataSource
//  }
//  
//  struct State {
//    var pictureSection = [PickedPictureSection]()
//  }
//  
//  let initialState = State()
//  
//  func mutate(action: Action) -> Observable<Mutation> {
//    switch action {
//    case .viewDidLoad:
//      return .just(.setDataSource)
//    }
//  }
//  
//  func reduce(state: State, mutation: Mutation) -> State {
//    var state = state
//    switch mutation {
//    case .setDataSource:
//      state.pictureSection = getMockSection()
//    }
//    
//    return state
//  }
//}
