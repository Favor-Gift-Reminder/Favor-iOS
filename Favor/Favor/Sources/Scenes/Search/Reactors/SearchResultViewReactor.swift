//
//  SearchResultViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/09.
//

import FavorKit
import ReactorKit
import RxCocoa
import RxFlow

final class SearchResultViewReactor: Reactor, Stepper {

  // MARK: - Constants

  public enum SelectedSearch {
    case gift, user
  }
  
  // MARK: - Properties
  
  var initialState: State
  var steps = PublishRelay<Step>()
  
  enum Action {
    case backButtonDidTap
    case textDidChanged(String?)
    case selectedSearchDidUpdate(SelectedSearch)
  }
  
  enum Mutation {
    case updateText(String?)
    case updateSelectedSearch(SelectedSearch)
  }
  
  struct State {
    var searchString: String
    var selectedSearch: SelectedSearch = .gift
    var giftResults = SearchGiftResultSection.SearchGiftResultModel(
      model: .zero,
      items: [.gift(SearchGiftResultCellReactor()), .gift(SearchGiftResultCellReactor()), .gift(SearchGiftResultCellReactor()), .gift(SearchGiftResultCellReactor()), .gift(SearchGiftResultCellReactor()), .gift(SearchGiftResultCellReactor()), .gift(SearchGiftResultCellReactor()), .gift(SearchGiftResultCellReactor()), .gift(SearchGiftResultCellReactor())]
    )
  }
  
  // MARK: - Initializer
  
  init(initialSearchString: String) {
    self.initialState = State(
      searchString: initialSearchString
    )
  }
  
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .backButtonDidTap:
      self.steps.accept(AppStep.searchResultIsComplete)
      return .empty()

    case .textDidChanged(let text):
      return .just(.updateText(text))

    case .selectedSearchDidUpdate(let selected):
      return .just(.updateSelectedSearch(selected))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .updateText(let text):
      newState.searchString = text ?? ""

    case .updateSelectedSearch(let selected):
      newState.selectedSearch = selected
    }
    
    return newState
  }
}
