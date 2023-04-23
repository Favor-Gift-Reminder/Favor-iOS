//
//  MyPageViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/10.
//

import OSLog
import UIKit

import FavorKit
import FavorNetworkKit
import ReactorKit
import RxCocoa
import RxFlow

/// 필요한 데이터
/// 유저 프로필 사진, 이름, 아이디
/// 총 선물, 준 선물, 받은 선물
/// 취향
/// 기념일
/// 친구 목록

final class MyPageViewReactor: Reactor, Stepper {
  
  // MARK: - Properties
  
  var initialState: State
  var steps = PublishRelay<Step>()
  let userFetcher = Fetcher<User>()
  
  enum Action {
    case viewNeedsLoaded
    case editButtonDidTap
    case settingButtonDidTap
  }
  
  enum Mutation {
    case updateUser(User)
    case updateLoading(Bool)
  }
  
  struct State {
    var user = User()
    var sections: [ProfileSection]
    var isLoading: Bool = false
  }
  
  // MARK: - Initializer
  
  init() {
    self.initialState = State(
      sections: MyPageViewReactor.setupMockSection()
    )
    self.setupUserFetcher()
  }
  
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      return self.userFetcher.fetch()
        .flatMap { (status, user) -> Observable<Mutation> in
          return .concat([
            .just(.updateUser(user)),
            .just(.updateLoading(status == .inProgress))
          ])
        }


    case .editButtonDidTap:
      os_log(.debug, "Edit button did tap.")
      return .empty()

    case .settingButtonDidTap:
      os_log(.debug, "Setting button did tap.")
      return .empty()
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updateUser(let user):
      newState.user = user

    case .updateLoading(let isLoading):
      newState.isLoading = isLoading
    }

    return newState
  }
}

// MARK: - Fetcher

private extension MyPageViewReactor {
  func setupUserFetcher() {
    // onRemote
    self.userFetcher.onRemote = {
      let networking = UserNetworking()
      let user = networking.request(.getUser(userNo: 1)) // TODO: UserNo 변경
        .flatMap { user -> Observable<User> in
          let userData = user.data
          do {
            let remote: ResponseDTO<UserResponseDTO> = try APIManager.decode(userData)
            let remoteUser = remote.data
            return .just(
              User(
                userNo: remoteUser.userNo,
                email: remoteUser.email,
                userID: remoteUser.userID,
                name: remoteUser.name,
                favorList: remoteUser.favorList
              )
            )
          } catch {
            return .just(User())
          }
        }
        .asSingle()
      return user
    }
    // onLocal
    self.userFetcher.onLocal = {
      let user = try await RealmManager.shared.read(User.self)
      return await user.toValue()
    }
    // onLocalUpdate
    self.userFetcher.onLocalUpdate = { user in
      os_log(.debug, "💽 ♻️ LocalDB REFRESH: \(user)")
      try await RealmManager.shared.update(user)
    }
  }
}

// MARK: - Privates

private extension MyPageViewReactor {
  
}

// MARK: - Temporaries

extension MyPageViewReactor {
  static func setupMockSection() -> [ProfileSection] {
    let newProfile1 = ProfileSectionItem.profileSetupHelper(FavorSetupProfileCellReactor())
    let newProfile2 = ProfileSectionItem.profileSetupHelper(FavorSetupProfileCellReactor())
    let newProfileSection = ProfileSection.profileSetupHelper([newProfile1, newProfile2])
    
    let favor1 = ProfileSectionItem.preferences(FavorPrefersCellReactor())
    let favor2 = ProfileSectionItem.preferences(FavorPrefersCellReactor())
    let favor3 = ProfileSectionItem.preferences(FavorPrefersCellReactor())
    let favorSection = ProfileSection.preferences([favor1, favor2, favor3])
    
    let anniversary1 = ProfileSectionItem.anniversaries(FavorAnniversaryCellReactor())
    let anniversary2 = ProfileSectionItem.anniversaries(FavorAnniversaryCellReactor())
    let anniversary3 = ProfileSectionItem.anniversaries(FavorAnniversaryCellReactor())
    let anniversarySection = ProfileSection.anniversaries([anniversary1, anniversary2, anniversary3])

    let friendSection = ProfileSection.friends(
      (1...10).map { _ in ProfileSectionItem.friends(ProfileFriendCellReactor()) }
    )
    
    return [newProfileSection, favorSection, anniversarySection, friendSection]
  }
}
