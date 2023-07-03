//
//  FriendManagementViewReactor.swift
//  Favor
//
//  Created by 김응철 on 2023/05/19.
//

import ReactorKit
import RxCocoa
import RxFlow

public final class FriendManagementViewReactor: Reactor, Stepper {

  public typealias Action = NoAction
  
  public struct State {
    
  }
  
  // MARK: - Properties
  
  public var steps = PublishRelay<Step>()
  public var initialState: State = State()
}
