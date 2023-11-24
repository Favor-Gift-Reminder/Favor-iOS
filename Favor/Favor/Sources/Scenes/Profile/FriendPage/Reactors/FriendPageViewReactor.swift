//
//  FriendPageViewReactor.swift
//  Favor
//
//  Created by 김응철 on 2023/05/28.
//

import FavorKit
import FavorNetworkKit
import ReactorKit
import RxCocoa
import RxFlow

final class FriendPageViewReactor: Reactor, Stepper {
  
  // MARK: - Properties
  
  var steps = PublishRelay<Step>()
  var initialState: State
  private let workbench = RealmWorkbench()
  private let friendPatchFetcher = Fetcher<Friend>()
  private let friendGetFetcher = Fetcher<Friend>()
  
  enum Action {
    case viewNeedsLoaded
    case doNothing
    case modfiyMemeButtonDidTap
    case addnotiButtonDidTap(Anniversary)
    case anniversarySetupHelperCellDidTap
    case memoDidChange(String)
    case moreAnniversaryDidTap
    case backButtonDidTap
  }
  
  enum Mutation {
    case setLoading(Bool)
    case setFriend(Friend)
  }
  
  struct State {
    var friend: Friend
    var sections: [ProfileSection] = []
    var items: [[ProfileSectionItem]] = []
    var isLoading: Bool = false
  }
  
  // MARK: - Initializer
  
  init(_ friend: Friend) {
    self.initialState = State(friend: friend)
    self.setupFriendPatchFetcher()
    self.setupFriendGetFetcher()
  }
  
  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      return self.friendGetFetcher.fetch()
        .flatMap { (status, friend) -> Observable<Mutation> in
          guard let friend = friend.first else { return .empty() }
          return .concat([
            .just(.setLoading(status == .inProgress)),
            .just(.setFriend(friend))
          ])
        }
      
    case .modfiyMemeButtonDidTap:
      self.steps.accept(AppStep.memoBottomSheetIsRequired(self.currentState.friend.memo))
      return .empty()
      
    case .anniversarySetupHelperCellDidTap:
      self.steps.accept(AppStep.newAnniversaryIsRequired)
      return .empty()
      
    case .memoDidChange(let memo):
      var friend = self.currentState.friend
      friend.memo = memo
      return .concat([
        .just(.setFriend(friend)),
        self.friendPatchFetcher.fetch()
          .flatMap { (status, friend) -> Observable<Mutation> in
            guard let friend = friend.first else { return .empty() }
            return .concat([
              .just(.setLoading(status == .inProgress)),
              .just(.setFriend(friend))
            ])
          }
      ])
      
    case .backButtonDidTap:
      self.steps.accept(AppStep.friendPageIsComplete)
      return .empty()
      
    case .moreAnniversaryDidTap:
      self.steps.accept(AppStep.anniversaryListIsRequired(.friend(friend: self.currentState.friend)))
      return .empty()
      
    case .addnotiButtonDidTap(let anniversary):
      self.steps.accept(AppStep.newReminderIsRequiredWithAnniversary(anniversary, self.currentState.friend))
      return .empty()
      
    case .doNothing:
      return .empty()
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setLoading(let isLoading):
      newState.isLoading = isLoading
      
    case .setFriend(let friend):
      newState.friend = friend
    }
    
    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      var newSection: [ProfileSection] = []
      var newItems: [[ProfileSectionItem]] = []
      
      // 취향
      if !state.friend.favorList.isEmpty {
        newSection.append(.favors)
        newItems.append(state.friend.favorList.map { ProfileSectionItem.favors($0) })
      }
      
      // 기념일
      if !state.friend.anniversaryList.isEmpty {
        newSection.append(.anniversaries)
        newItems.append(state.friend.anniversaryList.sort()
          .map { ProfileSectionItem.anniversaries($0, isMine: false) }
          .prefix(3)
          .wrap()
        )
      }
      
      // 메모
      newSection.append(.memo)
      newItems.append([ProfileSectionItem.memo(state.friend.memo)])

      newState.sections = newSection
      newState.items = newItems
      
      return newState
    }
  }
}

private extension FriendPageViewReactor {
  func setupFriendGetFetcher() {
    // onRemote
    self.friendGetFetcher.onRemote = {
      let networking = FriendNetworking()
      return networking.request(.getFriend(friendNo: self.currentState.friend.identifier))
        .map(ResponseDTO<FriendSingleResponseDTO>.self)
        .flatMap { responseDTO -> Observable<[Friend]> in
          return .just([Friend(singleDTO: responseDTO.data)])
        }
        .asSingle()
    }
    // onLocal
    self.friendGetFetcher.onLocal = {
      return await self.workbench.values(FriendObject.self)
        .where { $0.friendNo.in([self.currentState.friend.identifier]) }
        .map { Friend(realmObject: $0) }
    }
    // onLocalUpdate
    self.friendGetFetcher.onLocalUpdate = { _, remoteFriend in
      guard let friend = remoteFriend.first else {
        fatalError("해당 친구가 존재하지 않습니다.")
      }
      try await self.workbench.write { transaction in
        transaction.update(friend.realmObject())
      }
    }
  }
  
  func setupFriendPatchFetcher() {
    // onRemote
    self.friendPatchFetcher.onRemote = {
      let networking = FriendNetworking()
      let friend = networking.request(.patchFriendMemo(
        memo: self.currentState.friend.memo ?? "",
        friendNo: self.currentState.friend.identifier
      ))
        .flatMap { response -> Observable<[Friend]> in
          let responseDTO: ResponseDTO<FriendSingleResponseDTO> = try APIManager.decode(response.data)
          return .just([Friend(singleDTO: responseDTO.data)])
        }
        .asSingle()
      return friend
    }
    // onLocal
    self.friendPatchFetcher.onLocal = {
      return [self.currentState.friend]
    }
    // onLocalUpdate
    self.friendPatchFetcher.onLocalUpdate = { _, remoteFriend in
      guard let friend = remoteFriend.first else {
        fatalError("해당 친구가 존재하지 않습니다.")
      }
      try await self.workbench.write { transaction in
        transaction.update(friend.realmObject())
      }
    }
  }
}
