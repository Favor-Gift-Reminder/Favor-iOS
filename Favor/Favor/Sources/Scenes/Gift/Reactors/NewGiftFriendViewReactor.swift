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
  }
  
  enum Mutation {
    case setFriendList([Friend])
    case setSelectedFriends([Friend])
    case removeSelectedFriend(Friend)
    case setLoading(Bool)
  }
  
  struct State {
    var selectedSection = NewGiftFriendSection.NewGiftFriendSectionModel(
      model: .selectedFriends,
      items: []
    )
    var friendListSection = NewGiftFriendSection.NewGiftFriendSectionModel(
      model: .friendList,
      items: []
    )
    var currentFriendList: [Friend] = []
    var selectedFriends: [Friend] = []
    var isLoading: Bool = false
  }
  
  // MARK: - Properties
  
  var initialState: State = State()
  var steps = PublishRelay<Step>()
  let friendFetcher = Fetcher<[Friend]>()
  
  // MARK: - Initializer

  init() {
    self.setupFriendFetcher()
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return .just(.setFriendList([
        .init(friendNo: 0, name: "김응철", isUser: false),
        .init(friendNo: 1, name: "이창준", isUser: false),
        .init(friendNo: 2, name: "배가희", isUser: false),
        .init(friendNo: 3, name: "조민수", isUser: false),
        .init(friendNo: 4, name: "김현빈", isUser: false),
        .init(friendNo: 5, name: "정은기", isUser: false),
        .init(friendNo: 6, name: "이주원", isUser: false)
      ]))
//      return self.friendFetcher.fetch()
//        .flatMap { (status, friends) -> Observable<Mutation> in
//          let friendListSection = self.refineFriendList(friends)
//          return .concat([
//            .just(.setFriendListSection(friendListSection)),
//            .just(.setLoading(status == .inProgress))
//          ])
//        }
      
    case let .cellDidTap(indexPath, rightButtonType):
      switch rightButtonType {
      case .done:
        return .empty()
      case .remove:
        let targetFriend = self.currentState.selectedFriends[indexPath.row]
        return .just(.removeSelectedFriend(targetFriend))
      case .add:
        let targetFriend = [self.currentState.currentFriendList[indexPath.row]]
        return .just(.setSelectedFriends(targetFriend))
      }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setLoading(let isLoading):
      newState.isLoading = isLoading
      
    case .setFriendList(let friends):
      newState.currentFriendList = friends
      newState.friendListSection = self.refineFriendList_Initial(friends)
      
    case .setSelectedFriends(let selectedFriends):
      newState.selectedFriends.append(contentsOf: selectedFriends)
      
      let newSelectedFriends = newState.selectedFriends
      newState.selectedSection = self.refineSelectedFriendSection(newSelectedFriends)
      newState.friendListSection = self.refineFriendList(selectedFriends: newSelectedFriends)
      
    case .removeSelectedFriend(let friend):
      var friendList = self.currentState.selectedFriends
      friendList.enumerated().forEach {
        if $1.friendNo == friend.friendNo {
          friendList.remove(at: $0)
        }
      }
      
      newState.selectedFriends = friendList
      newState.selectedSection = self.refineSelectedFriendSection(friendList)
      newState.friendListSection = self.refineFriendList(selectedFriends: friendList)
    }
    
    return newState
  }
  
  // MARK: - Transform
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map {
      var newState = $0
      
      // 선택한 친구 섹션 생성
      if newState.selectedFriends.isEmpty {
        newState.selectedSection.items.append(.empty)
      }
      
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
      let friends = networking.request(.getAllFriendList(userNo: 1))
      // TODO: UserNo 변경
        .flatMap { response -> Observable<[Friend]> in
          let responseData = response.data
          let friends: ResponseDTO<[FriendResponseDTO.Friend]> =
          APIManager.decode(responseData)
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

// MARK: - Privates

private extension NewGiftFriendViewReactor {
  func refineFriendList_Initial(
    _ friends: [Friend]
  ) -> NewGiftFriendSection.NewGiftFriendSectionModel {
    let items = friends.map {
      let reactor = NewGiftFriendCellReactor(
        $0,
        rightButtonState: .add
      )
      return NewGiftFriendSection.NewGiftFriendSectionItem.friend(reactor)
    }
    
    return NewGiftFriendSection.NewGiftFriendSectionModel(
      model: .friendList,
      items: items
    )
  }
  
  func refineFriendList(
    selectedFriends: [Friend]
  ) -> NewGiftFriendSection.NewGiftFriendSectionModel {
    let currentFriends = self.currentState.currentFriendList
    
    let items = currentFriends.map { selectedFriend in
      let reactor = NewGiftFriendCellReactor(
        selectedFriend,
        rightButtonState: selectedFriends.contains(
          where: { selectedFriend.friendNo == $0.friendNo }
        ) ? .done : .add
      )
      return NewGiftFriendSection.NewGiftFriendSectionItem.friend(reactor)
    }
    
    return NewGiftFriendSection.NewGiftFriendSectionModel(
      model: .friendList,
      items: items
    )
  }
  
  func refineSelectedFriendSection(
    _ friends: [Friend]
  ) -> NewGiftFriendSection.NewGiftFriendSectionModel {
    let items = friends.map {
      let reactor = NewGiftFriendCellReactor(
        $0,
        rightButtonState: .remove
      )
      return NewGiftFriendSection.NewGiftFriendSectionItem.friend(reactor)
    }
    return NewGiftFriendSection.NewGiftFriendSectionModel(
      model: .selectedFriends,
      items: items
    )
  }
}
