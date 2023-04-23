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
    case updatePreferenceSection([String])
//    case updateAnniversarySection([String])
    case updateFriendSection([Friend])
    case updateLoading(Bool)
  }
  
  struct State {
    var user = User()
    /// 0: 새 프로필
    /// 1: 취향
    /// 2: 기념일
    /// 3: 친구
    var sections: [ProfileSection] = []
    var profileSetupHelperSection: ProfileSection = .profileSetupHelper([])
    var preferencesSection: ProfileSection = .preferences([])
    var anniversarySection: ProfileSection = .anniversaries([])
    var friendSection: ProfileSection = .friends([])
    var isLoading: Bool = false
  }
  
  // MARK: - Initializer
  
  init() {
    self.initialState = State()
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
            .just(.updatePreferenceSection(user.favorList.toArray())),
            .just(.updateFriendSection(user.friendList.toArray())),
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

    case .updatePreferenceSection(let preferences):
      let preferenceSection = ProfileSection.preferences(
        preferences.map { preference -> ProfileSectionItem in
          return .preferences(ProfilePreferenceCellReactor(preference: preference))
        }
      )
      newState.preferencesSection = preferenceSection

    case .updateFriendSection(let friends):
      let friendSection = ProfileSection.friends(
        friends.map { _ -> ProfileSectionItem in
          return .friends(ProfileFriendCellReactor())
        }
      )
      newState.friendSection = friendSection

    case .updateLoading(let isLoading):
      newState.isLoading = isLoading
    }

    return newState
  }

  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      var newSections: [ProfileSection] = []
      var profileSetupHelpers: [ProfileSectionItem] = []

      // 취향
      if !state.preferencesSection.items.isEmpty {
        newSections.append(state.preferencesSection)
      } else {
        profileSetupHelpers.append(.profileSetupHelper(ProfileSetupHelperCellReactor(.preference)))
      }
      // 기념일
      if !state.anniversarySection.items.isEmpty {
        newSections.append(state.anniversarySection)
      } else {
        profileSetupHelpers.append(.profileSetupHelper(ProfileSetupHelperCellReactor(.anniversary)))
      }
      // 친구
      if state.friendSection.items.isEmpty { // 친구가 없을 때의 처리
        let emptyFriendSection = ProfileSection.friends([.friends(ProfileFriendCellReactor())])
        newSections.append(emptyFriendSection)
      } else { // 친구가 있을 때는 다른 섹션과 동일하게 추가
        newSections.append(state.friendSection)
      }
      // 새 프로필
      if !profileSetupHelpers.isEmpty {
        newSections.insert(.profileSetupHelper(profileSetupHelpers), at: .zero)
      }

      newState.sections = newSections
      return newState
    }
  }
}

// MARK: - Fetcher

private extension MyPageViewReactor {
  func setupUserFetcher() {
    // onRemote
    self.userFetcher.onRemote = {
      let networking = UserNetworking()
      let user = networking.request(.getUser(userNo: UserInfoStorage.userNo))
        .flatMap { user -> Observable<User> in
          let userData = user.data
          do {
            let remote: ResponseDTO<UserResponseDTO> = try APIManager.decode(userData)
            let remoteUser = remote.data
            let decodedUser = User(
              userNo: remoteUser.userNo,
              email: remoteUser.email,
              userID: remoteUser.userID,
              name: remoteUser.name,
              favorList: remoteUser.favorList
            )
            return .just(decodedUser)
          } catch {
            print(error)
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
      try await RealmManager.shared.update(user)
    }
  }
}
