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

  // MARK: - Initializer

  public init() {
    self.setupUserFetcher()
  }

  // MARK: - Functions

  private func setupUserFetcher() {
    // onRemote
    self.userFetcher.onRemote = {
      let networking = UserNetworking()
      let user = networking.request(.getUser(userNo: UserInfoStorage.userNo))
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
