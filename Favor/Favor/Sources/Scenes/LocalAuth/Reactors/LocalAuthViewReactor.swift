//
//  LocalAuthViewReactor.swift
//  Favor
//
//  Created by 이창준 on 6/29/23.
//

import ReactorKit
import RxCocoa
import RxFlow

public final class LocalAuthViewReactor: Reactor, Stepper {

  // MARK: - Properties

  public var initialState: State
  public let steps = PublishRelay<Step>()

  public enum Action {
    case keypadDidSelected(FavorNumberKeypadCellModel)
  }

  public enum Mutation {
    case appendInput(Int)
    case removeLastInput
  }

  public struct State {
    var inputs: [KeypadInput] = Array(repeating: KeypadInput(data: nil, isLastInput: false), count: 4)
  }

  // MARK: - Initializer

  init() {
    self.initialState = State()
  }

  // MARK: - Functions

  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .keypadDidSelected(let keypad):
      switch keypad {
      case .keyString(let keyString):
        guard let keyNumber = Int(keyString) else { return .empty() }
        let currentInputs = self.currentState.inputs
        if currentInputs.filter({ $0.data != nil }).count == currentInputs.count - 1 {
          // 마지막 입력
        }
        return .just(.appendInput(keyNumber))
      case .keyImage(let keyImage):
        guard keyImage == .favorIcon(.erase) else { return .empty() }
        return .just(.removeLastInput)
      }
    }
  }

  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .appendInput(let inputNumber):
      guard let emptyIdx = newState.inputs.firstIndex(where: { $0.data == nil }) else { return state }
      newState.inputs[emptyIdx].data = inputNumber
      newState.inputs[emptyIdx].isLastInput = true
      if emptyIdx - 1 >= 0 {
        newState.inputs[emptyIdx - 1].isLastInput = false
      }

    case .removeLastInput:
      guard let lastIdx = state.inputs.lastIndex(where: { $0.data != nil }) else { return state }
      newState.inputs[lastIdx].isLastInput = false
      newState.inputs[lastIdx].data = nil
    }

    return newState
  }
}
