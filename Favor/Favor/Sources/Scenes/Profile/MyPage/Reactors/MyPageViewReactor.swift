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
    case headerRightButtonDidTap(ProfileSection)
  }
  
  enum Mutation {
    case updateUser(User)
    case updateUserName(String)
    case updateUserID(String)
    case updateFavorSection([Favor])
    case updateAnniversarySection([Anniversary])
    case updateFriendSection([Friend])
    case updateLoading(Bool)
  }
  
  struct State {
    var user = User()
    var userName: String = ""
    var userID: String = ""
    /// 0: 새 프로필
    /// 1: 취향
    /// 2: 기념일
    /// 3: 친구
    var sections: [ProfileSection] = []
    var items: [[ProfileSectionItem]] = []
    var profileSetupHelperItems: [ProfileSectionItem] = []
    var favorItems: [ProfileSectionItem] = []
    var anniversaryItems: [ProfileSectionItem] = []
    var friendItems: [ProfileSectionItem] = []
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
          guard let user = user.toArray().first else { return .empty() }
          return .concat([
            .just(.updateUser(user)),
            .just(.updateUserName(user.name)),
            .just(.updateUserID(user.userID)),
            .just(.updateFavorSection(user.favorList.map { Favor(rawValue: $0) ?? .cute })),
            .just(.updateAnniversarySection(user.anniversaryList.toArray())),
            .just(.updateFriendSection(user.friendList.toArray())),
            .just(.updateLoading(status == .inProgress))
          ])
        }

    case .editButtonDidTap:
      self.steps.accept(AppStep.editMyPageIsRequired(self.currentState.user))
      return .empty()

    case .settingButtonDidTap:
      self.steps.accept(AppStep.settingIsRequired)
      return .empty()

    case .headerRightButtonDidTap(let section):
      switch section {
      case .friends:
        self.steps.accept(AppStep.friendListIsRequired)
      default: break
      }
      return .empty()
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updateUser(let user):
      newState.user = user

    case .updateUserName(let name):
      newState.userName = name

    case .updateUserID(let id):
      newState.userID = id

    case .updateFavorSection(let favors):
      let favorSection = favors.map { favor -> ProfileSectionItem in
        return .favors(ProfileFavorCellReactor(favor: favor))
      }
      newState.favorItems = favorSection

    case .updateAnniversarySection(let anniversaries):
      let anniversarySection = anniversaries.map { anniversary -> ProfileSectionItem in
        return .anniversaries(ProfileAnniversaryCellReactor(anniversary: anniversary))
      }
      newState.anniversaryItems = anniversarySection

    case .updateFriendSection(let friends):
      let friendSection = friends.map { friend -> ProfileSectionItem in
        return .friends(ProfileFriendCellReactor(friend: friend))
      }
      newState.friendItems = friendSection

    case .updateLoading(let isLoading):
      newState.isLoading = isLoading
    }

    return newState
  }

  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      var newSections: [ProfileSection] = []
      var newItems: [[ProfileSectionItem]] = []
      var profileSetupHelperItems: [ProfileSectionItem] = []

      // 취향
      if !state.favorItems.isEmpty {
        newSections.append(.favors)
        newItems.append(state.favorItems)
      } else {
        profileSetupHelperItems.append(.profileSetupHelper(ProfileSetupHelperCellReactor(.favor)))
      }
      // 기념일
      if !state.anniversaryItems.isEmpty {
        newSections.append(.anniversaries)
        newItems.append(state.anniversaryItems)
      } else {
        profileSetupHelperItems.append(.profileSetupHelper(ProfileSetupHelperCellReactor(.anniversary)))
      }
      // 친구
      // 친구 맨 앞에 친구 추가
      let newFriend = Friend()
      newState.friendItems.insert(
        .friends(ProfileFriendCellReactor(friend: newFriend, isNewFriendCell: true)),
        at: .zero
      )
      newSections.append(.friends)
      newItems.append(newState.friendItems)
      // 새 프로필
      if !profileSetupHelperItems.isEmpty {
        newSections.insert(.profileSetupHelper, at: .zero)
        newItems.insert(profileSetupHelperItems, at: .zero)
      }

      newState.sections = newSections
      newState.items = newItems
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
