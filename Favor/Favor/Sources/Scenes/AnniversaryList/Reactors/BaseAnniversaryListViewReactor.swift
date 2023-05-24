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

  let userFetcher = Fetcher<User>()

  // MARK: - Initializer

  public init() {
    self.setupUserFetcher()
  }

  // MARK: - Functions

  func setupUserFetcher() {
    // onRemote
    self.userFetcher.onRemote = {
      let networking = UserNetworking()
      let user = networking.request(.getUser(userNo: UserInfoStorage.userNo))
        .flatMap { user -> Observable<[User]> in
          let userData = user.data
          do {
            let remote: ResponseDTO<UserResponseDTO> = try APIManager.decode(userData)
            let remoteUser = remote.data
            let decodedUser = User(
              userNo: remoteUser.userNo,
              email: remoteUser.email,
              userID: remoteUser.userID,
              name: remoteUser.name,
              favorList: remoteUser.favorList,
              giftList: remoteUser.giftList.map { $0.toDomain() },
              anniversaryList: remoteUser.anniversaryList.map { $0.toDomain() },
              friendList: remoteUser.friendList.map { $0.toDomain() }
            )
            return .just([decodedUser])
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
      return try await RealmManager.shared.read(User.self)
    }
    // onLocalUpdate
    self.userFetcher.onLocalUpdate = { _, remoteUser in
      guard let remoteUser = remoteUser.first else { return }
      try await RealmManager.shared.update(remoteUser, update: .all)
    }
  }
}
