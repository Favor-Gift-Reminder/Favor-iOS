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

final class NewGiftFriendViewReactor: Reactor, Stepper {
  
  enum Action {
    case viewDidLoad
    case cellDidTap(IndexPath, NewGiftFriendCell.RightButtonType)
    case textFieldDidChange(String)
  }
  
  enum Mutation {
    case updateFriends([Friend])
    case updateSelectedFriends([Friend])
    case updateLoading(Bool)
    case updateFinsihButtonState(Bool)
  }
  
  struct State {
    /// 0: 선택된 친구들
    /// 1: 현재 친구들
    var items: [[NewGiftFriendItem]] = []
    /// 현재 리스트로 보여지고 있는 친구 목록입니다.
    var currentFriends: [Friend] = []
    /// 선택된 친구 목록입니다.
    var selectedFriends: [Friend] = []
    var isEnabledFinishButton: Bool = false
    var isLoading: Bool = false
  }
  
  // MARK: - Properties
  
  var initialState: State = State()
  var steps = PublishRelay<Step>()
  let friendFetcher = Fetcher<[Friend]>()
  
  /// 최초로 불러온 친구 목록 입니다.
  var allFriends: [Friend] = []
  
  // MARK: - Initializer
  
  init() {
    self.setupFriendFetcher()
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return self.friendFetcher.fetch()
        .flatMap { (status, friends) -> Observable<Mutation> in
          self.allFriends = friends
          return .concat([
            .just(.updateFriends(friends)),
            .just(.updateLoading(status == .inProgress))
          ])
        }
      
    case let .cellDidTap(indexPath, rightButtonType):
      if indexPath.row == -1 {
        return .empty()
      } else {
        switch rightButtonType {
        case .add:
          var selectedFriends = self.currentState.selectedFriends
          let friend = self.currentState.currentFriends[indexPath.row]
          selectedFriends.append(friend)
          return .just(.updateSelectedFriends(selectedFriends))
        case .done:
          return .empty()
        case .remove:
          var selectedFriends = self.currentState.selectedFriends
          selectedFriends.remove(at: indexPath.row)
          return .just(.updateSelectedFriends(selectedFriends))
        }
      }
      
    case .textFieldDidChange(let text):
      let friends = text.isEmpty ?
      self.allFriends :
      self.allFriends.filter { $0.name.contains(text) }
      return .just(.updateFriends(friends))
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
      // 친구 아이템
      let friendItems = state.currentFriends
        .map { friend in
          var buttonType: NewGiftFriendCell.RightButtonType = .add
          if let _ = state.selectedFriends.first(where: { $0.friendNo == friend.friendNo }) {
            buttonType = .done
          }
          return NewGiftFriendItem.friend(
            NewGiftFriendCellReactor(friend, rightButtonState: buttonType)
          )
        }
      // 선택된 친구 아이템
      var selectedFriendItems = state.selectedFriends
        .map { NewGiftFriendItem.friend(NewGiftFriendCellReactor($0, rightButtonState: .remove)) }
      selectedFriendItems = selectedFriendItems.isEmpty ? [.empty] : selectedFriendItems
      // 마지막으로 각 아이템들을 2차원 배열 안에 주입합니다.
      newItems.append(selectedFriendItems)
      newItems.append(friendItems)
      
      // 선택된 친구들을 참조하여 완료 버튼의 상태를 바꾸고 상태값을 업데이트 합니다.
      newState.isEnabledFinishButton = state.selectedFriends.isEmpty ? false : true
      // 2차원 배열의 아이템을 새로운 State값에 주입합니다.
      newState.items = newItems
      return newState
    }
  }
}

// MARK: - Fetcher

private extension NewGiftFriendViewReactor {
  func setupFriendFetcher() {
    // onRemote
    self.friendFetcher.onRemote = {
      let networking = UserNetworking()
      let friends = networking.request(.getAllFriendList(userNo: UserInfoStorage.userNo))
        .flatMap { response -> Observable<[Friend]> in
          let responseData = response.data
          let friends: ResponseDTO<[FriendResponseDTO]> = try APIManager.decode(responseData)
          return .just(friends.data.map {
            Friend(
              friendNo: $0.friendNo,
              name: $0.friendName,
              memo: $0.friendMemo,
              friendUserNo: $0.friendUserNo,
              isUser: $0.isUser
            )
          })
        }
        .asSingle()
      return friends
    }
    // onLocal
    self.friendFetcher.onLocal = {
      let friends = try await RealmManager.shared.read(Friend.self)
      return await friends.toArray()
    }
    // onLocalUpdate
    self.friendFetcher.onLocalUpdate = { friends in
      try await RealmManager.shared.updateAll(friends)
    }
  }
}
