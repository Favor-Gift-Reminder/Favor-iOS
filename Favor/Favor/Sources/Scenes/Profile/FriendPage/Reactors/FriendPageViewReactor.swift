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
  
  var initialState: State = State()
  var steps = PublishRelay<Step>()
  private var friend: Friend
  private let workbench = RealmWorkbench()
  private let friendPatchFetcher = Fetcher<Friend>()
  private let friendGetFetcher = Fetcher<Friend>()

  /// 친구가 유저인지 판별해주는 계산 프로퍼티입니다.
  private var isUser: Bool { self.friend.isUser }
  
  enum Action {
    case viewNeedsLoaded
    case doNothing
    case memoCellDidTap(String?)
    case anniversarySetupHelperCellDidTap
    case memoDidChange(String?)
    case moreAnniversaryDidTap
  }
  
  enum Mutation {
    case setFavorSection([Favor])
    case setMemoSection(String?)
    case setAnniversarySection([Anniversary])
    case setMemo(String?)
    case setFriendName(String)
    case setLoading(Bool)
    case setFriend(Friend)
  }
  
  struct State {
    var friendName: String = ""
    var friendMemo: String?
    var sections: [ProfileSection] = []
    var items: [[ProfileSectionItem]] = []
    var anniversarySetupHelperItems: [ProfileSectionItem] = []
    var favorItems: [ProfileSectionItem] = []
    var anniversaryItems: [ProfileSectionItem] = []
    var memoItems: [ProfileSectionItem] = []
    var isLoading: Bool = false
  }
  
  // MARK: - Initializer
  
  init(_ friend: Friend) {
    self.friend = friend
    self.setupFriendPatchFetcher()
    self.setupFriendGetFetcher()
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      return self.friendGetFetcher.fetch()
        .flatMap { (status, friend) -> Observable<Mutation> in
          guard let friend = friend.first else {
            fatalError("해당 친구가 존재하지 않습니다.")
          }
          return .concat([
            .just(.setLoading(status == .inProgress)),
            .just(.setMemo(friend.memo)),
            .just(.setMemoSection(friend.memo)),
            .just(.setFriendName(friend.name)),
            .just(.setFavorSection(friend.favorList)),
            .just(.setAnniversarySection(friend.anniversaryList)),
            .just(.setFriend(friend))
          ])
        }

    case .memoCellDidTap(let memo):
      self.steps.accept(AppStep.memoBottomSheetIsRequired(memo))
      return .empty()
      
    case .anniversarySetupHelperCellDidTap:
      self.steps.accept(AppStep.newAnniversaryIsRequired)
      return .empty()
      
    case .memoDidChange(let memo):
      return .concat([
        .just(.setLoading(true)),
        self.friendPatchFetcher.fetch()
          .debug()
          .flatMap { (status, _) -> Observable<Mutation> in
            return .concat([
              .just(.setLoading(status == .inProgress)),
              .just(.setMemoSection(memo)),
              .just(.setMemo(memo))
            ])
          }
      ])
      
    case .moreAnniversaryDidTap:
      self.steps.accept(AppStep.anniversaryListIsRequired(AnniversaryListType.friend(friend: self.friend)))
      return .empty()
      
    case .doNothing:
      return .empty()
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setMemoSection(let memo):
      newState.memoItems = [.memo(memo)]
      
    case .setFavorSection(let favors):
      let favorSection = favors.map {
        ProfileSectionItem.favors(ProfileFavorCellReactor(favor: $0))
      }
      newState.favorItems = favorSection
      
    case .setAnniversarySection(let anniversaries):
      let anniversarySection = anniversaries.map {
        ProfileSectionItem.anniversaries(ProfileAnniversaryCellReactor(anniversary: $0))
      }
      newState.anniversaryItems = anniversarySection
      
    case .setMemo(let memo):
      newState.friendMemo = memo
      
    case .setFriendName(let name):
      newState.friendName = name
      
    case .setLoading(let isLoading):
      newState.isLoading = isLoading
      
    case .setFriend(let friend):
      self.friend = friend
    }
    
    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      var newSection: [ProfileSection] = []
      var newItems: [[ProfileSectionItem]] = []
      
      // 새 기념일 도움 섹션
      // 유저가 아닌 친구 & 기념일 목록이 비어 있는 조건을 모두 만족해야합니다.
      if !self.isUser, self.friend.anniversaryList.isEmpty {
        newSection.append(.anniversarySetupHelper)
        newItems.append([.anniversarySetupHelper])
      }
      
      // 취향
      if !state.favorItems.isEmpty {
        newSection.append(.favors)
        newItems.append(state.favorItems)
      }
      
      // 기념일
      if !state.anniversaryItems.isEmpty {
        newSection.append(.anniversaries)
        // TODO: 고정된 기념일이 없으면 최근 3개 or 고정된 기념일 보여주기
        newItems.append(state.anniversaryItems.prefix(3).wrap())
      }
      
      // 메모
      newSection.append(.memo)
      newItems.append(state.memoItems)
      
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
      return networking.request(.getFriend(friendNo: self.friend.identifier))
        .flatMap { response -> Observable<[Friend]> in
          let responseDTO: ResponseDTO<FriendResponseDTO> = try APIManager.decode(response.data)
          return .just([Friend(dto: responseDTO.data)])
        }
        .asSingle()
    }
    // onLocal
    self.friendGetFetcher.onLocal = {
      return await self.workbench.values(FriendObject.self)
        .where { $0.friendNo.in([self.friend.identifier]) }
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
      let friend = networking.request(.patchFriend(
        friendName: self.currentState.friendName,
        friendMemo: self.currentState.friendMemo ?? "",
        friendNo: self.friend.identifier
      ))
        .flatMap { response -> Observable<[Friend]> in
          let responseDTO: ResponseDTO<FriendResponseDTO> = try APIManager.decode(response.data)
          return .just([Friend(dto: responseDTO.data)])
        }
        .asSingle()
      return friend
    }
    // onLocal
    self.friendPatchFetcher.onLocal = {
      return await self.workbench.values(FriendObject.self)
        .where { $0.friendNo.in([self.friend.identifier]) }
        .map { Friend(realmObject: $0) }
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
