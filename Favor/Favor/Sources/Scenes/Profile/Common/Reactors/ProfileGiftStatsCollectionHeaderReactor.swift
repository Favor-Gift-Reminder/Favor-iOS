//
//  ProfileGiftStatsCollectionHeaderReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/15.
//

import FavorKit
import ReactorKit

public final class ProfileGiftStatsCollectionHeaderReactor: Reactor {
  
  // MARK: - Properties
  
  public var initialState: State
  
  public enum Action {
    
  }
  
  public enum Mutation {
    
  }
  
  public struct State {
    var gifts: [Gift]
    var totalGifts: Int = -1
    var receivedGifts: Int = -1
    var givenGifts: Int = -1
  }
  
  // MARK: - Initializer
  
  public init(gift: [Gift]) {
    self.initialState = State(
      gifts: gift
    )
  }
  
  // MARK: - Functions

  public func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state

      newState.totalGifts = state.gifts.count
      newState.receivedGifts = state.gifts.filter { $0.isGiven == false }.count
      newState.givenGifts = state.gifts.filter { $0.isGiven == true }.count

      return newState
    }
  }
}
