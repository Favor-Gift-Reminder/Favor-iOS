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
    var givenGifts: Int
    var receivedGifts: Int
    var totalGifts: Int
  }
  
  // MARK: - Initializer
  
  public init(user: User) {
    self.initialState = State(
      givenGifts: user.givenGifts,
      receivedGifts: user.receivedGifts,
      totalGifts: user.totalgifts
    )
  }
  
  public init(friend: Friend) {
    self.initialState = State(
      givenGifts: friend.givenGift,
      receivedGifts: friend.receivedGift,
      totalGifts: friend.totalGift
    )
  }
}
