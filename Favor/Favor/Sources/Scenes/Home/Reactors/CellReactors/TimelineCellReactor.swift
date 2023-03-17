//
//  TimelineCellReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/01/31.
//

import UIKit

import ReactorKit

final class TimelineCellReactor: Reactor {
  
  // MARK: - Properties
  
  var initialState: State
  
  enum Action {
    
  }
  
  enum Mutation {
    
  }
  
  struct State {
    var image: UIImage?
    var isPinned: Bool
  }
  
  // MARK: - Initializer
  
  init(cellData: TimelineCellData) {
    self.initialState = State(
      image: cellData.image,
      isPinned: cellData.isPinned
    )
  }
  
  
  // MARK: - Functions
  

}
