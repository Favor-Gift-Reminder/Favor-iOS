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

  public let workbench = RealmWorkbench()
  public let userFetcher = Fetcher<User>()

  // MARK: - Initializer

  public init() {
    self.setupFriendFetcher()
  }
  
  // MARK: - Fetcher
  
  public func setupFriendFetcher() {
    // onRemote
    self.userFetcher.onRemote = {
      let networking = UserNetworking()
      let user = networking.request(.getUser)
        .map(ResponseDTO<UserSingleResponseDTO>.self)
        .map { [User(singleDTO: $0.data)] }
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
      try await self.workbench.write { transaction in
        transaction.update(remoteUser.map { $0.realmObject() })
      }
    }
  }
}
