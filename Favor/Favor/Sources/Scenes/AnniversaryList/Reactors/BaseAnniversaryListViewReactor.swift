//
//  BaseAnniversaryListViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/05/19.
//

import FavorKit
import FavorNetworkKit
import RxSwift

public class BaseAnniversaryListViewReactor {
  
  // MARK: - Properties

  private let workbench = RealmWorkbench()
  let userFetcher = Fetcher<User>()
  let friendFetcher = Fetcher<Friend>()
  
  init() {
    self.setupUserFetcher()
  }

  // MARK: - Functions
  
  func setupFriendFetcher(with friend: Friend) {
    // onRemote
    self.friendFetcher.onRemote = {
      let networking = FriendNetworking()
      return networking.request(.getFriend(friendNo: friend.identifier))
        .flatMap { response -> Observable<[Friend]> in
          let responseDTO: ResponseDTO<FriendResponseDTO> = try APIManager.decode(response.data)
          return .just([Friend(dto: responseDTO.data)])
        }
        .asSingle()
    }
    // onLocal
    self.friendFetcher.onLocal = {
      await self.workbench.values(FriendObject.self)
        .where { $0.friendNo.in([friend.identifier]) }
        .map { Friend(realmObject: $0) }
    }
    // onLocalUpdate
    self.friendFetcher.onLocalUpdate = { _, remoteFriend in
      guard let friend = remoteFriend.first else {
        fatalError("해당 친구가 존재하지 않습니다.")
      }
      try await self.workbench.write { transaction in
        transaction.update(friend.realmObject())
      }
    }
  }
  
  func setupUserFetcher() {
    // onRemote
    self.userFetcher.onRemote = {
      let networking = UserNetworking()
      let user = networking.request(.getUser)
        .flatMap { user -> Observable<[User]> in
          let userData = user.data
          do {
            let responseDTO: ResponseDTO<UserResponseDTO> = try APIManager.decode(userData)
            let user = User(dto: responseDTO.data)
            return .just([user])
          } catch {
            print(error)
            return .just([])
          }
        }
        .asSingle()
      return user
    }
    // onLocal
    self.userFetcher.onLocal = {
      return await self.workbench.values(UserObject.self)
        .map { User(realmObject: $0) }
    }
    // onLocalUpdate
    self.userFetcher.onLocalUpdate = { _, remoteUser in
      guard let remoteUser = remoteUser.first else { return }
      try await self.workbench.write { transaction in
        transaction.update(remoteUser.realmObject())
      }
    }
  }
}
