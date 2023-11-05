//
//  NewGiftFriendViewReactor.swift
//  Favor
//
//  Created by 김응철 on 2023/04/15.
//

import UIKit

import FavorKit
import FavorNetworkKit
import ReactorKit
import RxCocoa
import RxFlow

final class FriendSelectorViewReactor: Reactor, Stepper {
  
  /// 친구 선택 페이지를 분기처리하기 위한 열거형입니다.
  enum ViewType {
    case gift
    case reminder
    
    /// 최대로 선택할 수 있는 친구 수
    var maximumSelection: Int {
      switch self {
      case .gift:
        return 5
      case .reminder:
        return 1
      }
    }
  }
  
  // MARK: - Properties
  
  var initialState: State
  var steps = PublishRelay<Step>()
  private let fetcher = Fetcher<Friend>()
  private let workbench = RealmWorkbench()
  
  enum Action {
    case viewDidLoad
    case cellDidTap(IndexPath, FriendSelectorCell.RightButtonType)
    case textFieldDidChange(String)
    case addFriendDidTap
    case finishButtonDidTap
    case tempFriendDidAdd(String)
  }
  
  enum Mutation {
    case updateFriends([Friend])
    case updateSelectedFriends([Friend])
    case updateLoading(Bool)
    case updateFinsihButtonState(Bool)
  }
  
  struct State {
    var viewType: ViewType
    var sections: [NewGiftFriendSection] = []
    /// 0: 선택된 친구들
    /// 1: 현재 친구들
    var items: [[NewGiftFriendItem]] = []
    /// 현재 리스트로 보여지고 있는 친구 목록입니다.
    var currentFriends: [Friend] = []
    /// 선택된 친구 목록입니다.
    var selectedFriends: [Friend]
    var isEnabledFinishButton: Bool = false
    var isLoading: Bool = false
  }
  
  // MARK: - Properties
  
  // MARK: - Initializer
  
  init(_ viewType: ViewType, selectedFriends: [Friend] = []) {
    self.initialState = State(viewType: viewType, selectedFriends: selectedFriends)
    self.setupFriendFetcher()
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return self.fetcher.fetch()
        .map { $0.results }
        .asObservable()
        .flatMap { friends in
          return Observable<Mutation>.just(.updateFriends(friends))
        }
      
    case let .cellDidTap(indexPath, rightButtonType):
      if indexPath.row == -1 {
        return .empty()
      } else {
        switch rightButtonType {
        case .add:
          var selectedFriends = self.currentState.selectedFriends
          if selectedFriends.count >= self.currentState.viewType.maximumSelection {
            // 현재 최대 친구 수를 넘어서면 선택이 되지 않습니다.
            return .empty()
          } else {
            let friend = self.currentState.currentFriends[indexPath.row]
            selectedFriends.append(friend)
            return .just(.updateSelectedFriends(selectedFriends))
          }
        case .done:
          return .empty()
        case .remove:
          var selectedFriends = self.currentState.selectedFriends
          selectedFriends.remove(at: indexPath.row)
          return .just(.updateSelectedFriends(selectedFriends))
        }
      }
      
    case .textFieldDidChange(let text):
      let allFriends = self.currentState.currentFriends
      let filteredFriends = text.isEmpty ?
      allFriends : allFriends.filter { $0.friendName.contains(text) }
      return .just(.updateFriends(filteredFriends))
      
    case .addFriendDidTap:
      self.steps.accept(AppStep.friendManagementIsRequired(.new))
      return .empty()
      
    case .finishButtonDidTap:
      let friends = self.currentState.selectedFriends
      self.steps.accept(AppStep.friendSelectorIsComplete(friends))
      return .empty()
      
    case .tempFriendDidAdd(let friendName):
      let tempFriend = Friend(friendName: friendName)
      var selectedFriends = self.currentState.selectedFriends
      selectedFriends.append(tempFriend)
      return .just(.updateSelectedFriends(selectedFriends))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .updateLoading(let isLoading):
      newState.isLoading = isLoading
      
    case .updateFriends(let friends):
      newState.currentFriends = friends
      
    case .updateSelectedFriends(let friends):
      newState.selectedFriends = friends
      
    case .updateFinsihButtonState(let isEnabled):
      newState.isEnabledFinishButton = isEnabled
    }
    
    return newState
  }
  
  // MARK: - Transform
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      
      // 친구 배열과 선택된 친구 배열을 참조하여
      // 새로운 아이템 2차원 배열을 만듭니다.
      var newItems: [[NewGiftFriendItem]] = []
      let newSections: [NewGiftFriendSection] = [.selectedFriends, .friends]
      // 친구 아이템
      let friendItems = state.currentFriends
        .map { friend in
          var buttonType: FriendSelectorCell.RightButtonType = .add
          if state.selectedFriends.first(where: { $0 == friend }) != nil {
            buttonType = .done
          }
          return NewGiftFriendItem.friend(friend: friend, buttonType: buttonType)
        }
      // 선택된 친구 아이템
      var selectedFriendItems = state.selectedFriends
        .map { NewGiftFriendItem.friend(friend: $0, buttonType: .remove) }
      selectedFriendItems = selectedFriendItems.isEmpty ? [.empty] : selectedFriendItems
      // 마지막으로 각 아이템들을 2차원 배열 안에 주입합니다.
      newItems.append(selectedFriendItems)
      newItems.append(friendItems)
      
      // 선택된 친구들을 참조하여 완료 버튼의 상태를 바꾸고 상태값을 업데이트 합니다.
      newState.isEnabledFinishButton = state.selectedFriends.isEmpty ? false : true
      // 2차원 배열의 아이템을 새로운 State값에 주입합니다.
      newState.items = newItems
      newState.sections = newSections
      return newState
    }
  }
}

// MARK: - Privates

private extension FriendSelectorViewReactor {
  func setupFriendFetcher() {
    // onRemote
    self.fetcher.onRemote = {
      let networking = UserNetworking()
      return networking.request(.getAllFriendList)
        .map(ResponseDTO<[FriendResponseDTO]>.self)
        .map { $0.data.map { Friend(friendResponseDTO: $0) } }
        .asSingle()
    }
    // onLocal
    self.fetcher.onLocal = {
      return await self.workbench.values(FriendObject.self)
        .filter { $0.friendNo > 0 }
        .map { return Friend(realmObject: $0) }
    }
    // onLocalUpdate
    self.fetcher.onLocalUpdate = { _, remoteFriend in
      try await self.workbench.write { transaction in
        remoteFriend.forEach { friend in
          transaction.update(Friend.self, values: [.name(friend.friendName)])
        }
      }
    }
  }
}
