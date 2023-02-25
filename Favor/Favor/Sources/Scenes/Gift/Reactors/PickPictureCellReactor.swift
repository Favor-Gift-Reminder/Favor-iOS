//
//  PickPictureCellReactor.swift
//  Favor
//
//  Created by 김응철 on 2023/02/09.
//

import UIKit

import ReactorKit

final class PickPictureCellReactor: Reactor {
  typealias Action = NoAction
  
  struct State {
    var imageCount: Int
  }
  
  let initialState: State
  
  init(_ imageCount: Int) {
    self.initialState = State(imageCount: imageCount)
  }
}
