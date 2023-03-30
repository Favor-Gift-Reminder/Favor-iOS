//
//  ReminderCellReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/03/30.
//

import UIKit.UIImage

import ReactorKit

final class ReminderCellReactor: Reactor {

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


  // MARK: - Functions


}
