//
//  BaseFriendListViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/05/11.
//

import FavorKit
import FavorNetworkKit
import RealmSwift
import RxSwift

public class BaseFriendListViewReactor {

  // MARK: - Properties

  public let friendsFetcher = Fetcher<Friend>()

  // MARK: - Initializer

  public init() {
    self.setupFriendFetcher()
  }

  // MARK: - Fetcher

  public func setupFriendFetcher() {
    // onRemote
    self.friendsFetcher.onRemote = {
      let networking = UserNetworking()
      let friends = networking.request(.getAllFriendList(userNo: UserInfoStorage.userNo))
        .flatMap { friends -> Observable<[Friend]> in
          let friendsData = friends.data
          do {
            let remote: ResponseDTO<[FriendResponseDTO]> = try APIManager.decode(friendsData)
            let remoteFriends = remote.data
            let decodedFriends = remoteFriends.map { friend -> Friend in
              return Friend(
                friendNo: friend.friendNo,
                name: friend.friendName,
                profilePhoto: nil,
                memo: friend.friendMemo,
                friendUserNo: friend.friendUserNo,
                isUser: friend.isUser
              )
            }
            return .just(decodedFriends)
          } catch {
            print(error)
            return .just([])
          }
        }
        .asSingle()
      return friends
    }
    // onLocal
    self.friendsFetcher.onLocal = {
      return try await RealmManager.shared.read(Friend.self)
    }
    // onLocalUpdate
    self.friendsFetcher.onLocalUpdate = { _, remoteFriends in
      try await RealmManager.shared.delete(remoteFriends)
      try await RealmManager.shared.updateAll(remoteFriends, update: .modified)
    }
  }
}
