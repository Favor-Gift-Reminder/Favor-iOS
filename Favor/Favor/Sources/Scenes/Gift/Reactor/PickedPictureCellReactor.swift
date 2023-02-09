//
//  PickedPictureCellReactor.swift
//  Favor
//
//  Created by 김응철 on 2023/02/09.
//

import UIKit

import ReactorKit

final class PickedPictureCellReactor: Reactor {
  
  typealias Action = NoAction
  
  struct State {
    var image: UIImage
  }
  
  let initialState: State
  
  init(_ image: UIImage) {
    self.initialState = State(image: image)
  }
}
