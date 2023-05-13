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
  }
  
  struct State {
    /// 0: 선택된 친구들
    /// 1: 현재 친구들
    var items: [[NewGiftFriendItem]] = []
    /// 현재 리스트로 보여지고 있는 친구 목록입니다.
    var currentFriends: [Friend] = []
    /// 선택된 친구 목록입니다.
    var selectedFriends: [Friend] = []
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
          print(selectedFriends)
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
    }
    
    return newState
  }
  
  // MARK: - Transform
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      var newItems: [[NewGiftFriendItem]] = []
      
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
      
      var selectedFriendItems = state.selectedFriends
        .map { NewGiftFriendItem.friend(NewGiftFriendCellReactor($0, rightButtonState: .remove)) }
      selectedFriendItems = selectedFriendItems.isEmpty ? [.empty] : selectedFriendItems
      
      newItems.append(selectedFriendItems)
      newItems.append(friendItems)
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
