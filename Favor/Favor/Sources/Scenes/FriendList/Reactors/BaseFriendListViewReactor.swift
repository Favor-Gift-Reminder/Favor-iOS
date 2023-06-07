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

  public let workbench = try! RealmWorkbench()
  public let friendFetcher = Fetcher<Friend>()

  // MARK: - Initializer

  public init() {
    self.setupFriendFetcher()
  }

  // MARK: - Fetcher

  public func setupFriendFetcher() {
    // onRemote
    self.friendFetcher.onRemote = {
      let networking = UserNetworking()
      let friends = networking.request(.getAllFriendList(userNo: UserInfoStorage.userNo))
        .flatMap { friends -> Observable<[Friend]> in
          do {
            let responseDTO: ResponseDTO<[FriendResponseDTO]> = try APIManager.decode(friends.data)
            let friends = responseDTO.data.map { Friend(dto: $0) }
            return .just(friends)
          } catch {
            print(error)
            return .just([])
          }
        }
        .asSingle()
      return friends
    }
    // onLocal
    self.friendFetcher.onLocal = {
      return await self.workbench.values(FriendObject.self)
        .map { Friend(realmObject: $0) }
    }
    // onLocalUpdate
    self.friendFetcher.onLocalUpdate = { _, remoteFriends in
      try await self.workbench.write { transaction in
        transaction.update(remoteFriends.map { $0.realmObject() })
      }
    }
  }
}
