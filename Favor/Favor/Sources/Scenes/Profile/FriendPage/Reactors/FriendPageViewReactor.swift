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
  
  // MARK: - Properties
  
  var initialState: State = State()
  var steps = PublishRelay<Step>()
  private let friend: Friend
  private let friendFetcher = Fetcher<Friend>()

  /// 친구가 유저인지 판별해주는 계산 프로퍼티입니다.
  private var isUser: Bool { self.friend.isUser }
  
  // MARK: - Initializer
  
  init(_ friend: Friend) {
    self.friend = friend
    self.setupFriendFetcher()
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      let commonEvent = Observable<Mutation>.concat(
        .just(.setMemo(self.friend.memo)),
        .just(.setMemoSection(self.friend.memo)),
        .just(.setFriendName(self.friend.name))
        // TODO: 친구가 유저일 때, 아이디 String 값 필요
      )
      
      if self.friend.isUser {
        return .concat([
          .just(.setFavorSection(self.friend.favorList.map { Favor(rawValue: $0) ?? .cute })),
          .just(.setAnniversarySection(self.friend.anniversaryList.toArray())),
          commonEvent
        ])
      } else {
        return commonEvent
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
        self.friendFetcher.fetch()
          .flatMap { (status, friend) -> Observable<Mutation> in
            guard let friend = friend.toArray().first else { return .empty() }
            return .concat([
              .just(.setLoading(status == .inProgress)),
              .just(.setMemoSection(memo)),
              .just(.setMemo(memo))
            ])
          }
      ])
      
    case .moreAnniversaryDidTap:
      self.steps.accept(AppStep.anniversaryListIsRequired)
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
      if !self.isUser, self.friend.anniversaryList.toArray().isEmpty {
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
        newItems.append(state.anniversaryItems)
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
  func setupFriendFetcher() {
    // onRemote
    self.friendFetcher.onRemote = {
      let networking = FriendNetworking()
      let friend = networking.request(.patchFriend(
        friendName: self.currentState.friendName,
        friendMemo: self.currentState.friendMemo ?? "",
        friendNo: self.friend.friendNo
      ))
        .flatMap { response -> Observable<[Friend]> in
          let friend: ResponseDTO<FriendResponseDTO> = try APIManager.decode(response.data)
          return .just([friend.data.toDomain()])
        }
        .asSingle()
      return friend
    }
    // onLocal
    self.friendFetcher.onLocal = {
      return try await RealmManager.shared.read(Friend.self).filter(
          "friendNo == %@",
          self.friend.friendNo
      )
    }
    // onLocalUpdate
    self.friendFetcher.onLocalUpdate = { _, remoteFriend in
      guard let friend = remoteFriend.first else {
        fatalError("해당 친구가 존재하지 않습니다.")
      }
      try await RealmManager.shared.update(friend)
    }
  }
}
