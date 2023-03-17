//
//  UpcomingCellReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/01/31.
//

import UIKit

import ReactorKit

final class UpcomingCellReactor: Reactor {
  
  // MARK: - Properties
  
  var initialState: State
  
  enum Action {
    
  }
  
  enum Mutation {
    
  }
  
  struct State {
    var iconImage: UIImage?
    var title: String
    var subtitle: String
  }
  
  // MARK: - Initializer
  
  init(cellData: CardCellData) {
    self.initialState = State(
      iconImage: cellData.iconImage,
      title: cellData.title,
      subtitle: cellData.subtitle
    )
  }
  
}
