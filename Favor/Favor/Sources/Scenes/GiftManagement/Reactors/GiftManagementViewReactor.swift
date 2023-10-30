//
//  GiftManagementViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/05/29.
//

import OSLog
import UIKit

import FavorKit
import FavorNetworkKit
import Kingfisher
import ReactorKit
import RxCocoa
import RxFlow

final class GiftManagementViewReactor: Reactor, Stepper {
  typealias Section = GiftManagementSection
  typealias Item = GiftManagementSectionItem

  // MARK: - Properties
  
  var initialState: State
  var steps = PublishRelay<Step>()
  private var pickerManager: PHPickerManager?
  
  enum Action {
    /// 화면 최초 접속
    case viewDidLoad
    /// 취소 버튼 클릭
    case cancelButtonDidTap
    case doneButtonDidTap
    case giftTypeButtonDidTap(isGiven: Bool)
    case itemSelected(IndexPath)
    case titleDidUpdate(String?)
    case categoryDidUpdate(FavorCategory)
    case photoDidSelected(Item)
    case friendsSelectorButtonDidTap
    case dateDidUpdate(Date?)
    case memoDidUpdate(String?)
    case pinButtonDidTap(Bool)
    /// 회원/비회원 친구 추가
    case friendsDidAdd([Friend])
    /// 사진이 갤러리에서 추가 되었음
    case photoAdded(UIImage?)
    /// 선택된 사진 삭제
    case removeButtonTapped(UIImage?)
    case doNothing
  }
  
  enum Mutation {
    case updateGiftType(isGiven: Bool)
    case updateTitle(String?)
    case updateCategory(FavorCategory)
    case updateDate(Date?)
    case updateMemo(String?)
    case updateFriends([Friend])
    case updateIsPinned(Bool)
    case updateImageList([UIImage?])
  }
  
  struct State {
    var viewType: GiftManagementViewController.ViewType
    var giftType: GiftManagementViewController.GiftType = .received
    var isEnabledDoneButton: Bool = false
    var gift: Gift
    var imageList: [UIImage?] = []
    
    var sections: [Section] = [
      .title,
      .category,
      .photos,
      .date,
      .friends(isGiven: false),
      .memo,
      .pin
    ]
    var items: [[Item]] = []
  }
  
  // MARK: - Initializer

  init(_ viewType: GiftManagementViewController.ViewType) {
    self.initialState = State(
      viewType: viewType,
      gift: Gift()
    )
  }

  init(
    _ viewType: GiftManagementViewController.ViewType,
    with gift: Gift
  ) {
    self.initialState = State(
      viewType: viewType,
      gift: gift
    )
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      var imageList: [UIImage?] = []
      self.currentState.gift.photos.forEach { photo in
        guard let url = URL(string: photo.remote) else { return }
        var image: UIImage?
        ImageDownloaderManager.downloadImage(from: url) { image = $0 }
        imageList.append(image)
      }
      return .just(.updateImageList(imageList))
      
    case .cancelButtonDidTap:
      self.steps.accept(AppStep.giftManagementIsCompleteWithNoChanges)
      return .empty()

    case .doneButtonDidTap:
      switch self.currentState.viewType {
      case .new:
        return self.requestPostGift(self.currentState.gift)
          .asObservable()
          .flatMap { gift -> Observable<Mutation> in
            self.steps.accept(AppStep.newGiftIsComplete(gift))
            return .empty()
          }
          .catch { error in
            os_log(.error, "🚨 Failure: \(error)")
            return .empty()
          }
      case .edit:
        return self.requestPatchGift(self.currentState.gift)
          .asObservable()
          .flatMap { gift -> Observable<Mutation> in
            self.steps.accept(AppStep.editGiftIsComplete(gift))
            return .empty()
          }
          .catch { error in
            os_log(.error, "🚨 Failure: \(error)")
            return .empty()
          }
      }
      
    case .giftTypeButtonDidTap(let isGiven):
      return .just(.updateGiftType(isGiven: isGiven))

    case .itemSelected:
      return .empty()

    case .titleDidUpdate(let title):
      return .just(.updateTitle(title))
      
    case .categoryDidUpdate(let category):
      return .just(.updateCategory(category))
      
    case let .photoDidSelected(item):
      if case Item.photo(let image) = item, image == nil {
        let pickerManager = PHPickerManager()
        self.pickerManager = pickerManager
        let selectionLimit = 5 - self.currentState.imageList.count
        // 사진 선택은 5개까지가 최대입니다.
        if selectionLimit > 0 {
          self.steps.accept(AppStep.imagePickerIsRequired(pickerManager, selectionLimit: selectionLimit))
        }
      }
      return .empty()
      
    case .friendsSelectorButtonDidTap:
      self.steps.accept(AppStep.friendSelectorIsRequired(self.currentState.gift.relatedFriends))
      return .empty()

    case .dateDidUpdate(let date):
      return .just(.updateDate(date))

    case .memoDidUpdate(let memo):
      return .just(.updateMemo(memo))

    case .pinButtonDidTap(let isPinned):
      return .just(.updateIsPinned(isPinned))
      
    case .friendsDidAdd(let friends):
      return .just(.updateFriends(friends))
      
    case .photoAdded(let image):
      self.pickerManager = nil
      var imageList = self.currentState.imageList
      imageList.append(image)
      return .just(.updateImageList(imageList))
      
    case .removeButtonTapped(let image):
      var imageList = self.currentState.imageList
      guard let removeIndex = imageList.firstIndex(of: image) else { return .empty() }
      imageList.remove(at: removeIndex)
      return .just(.updateImageList(imageList))

    case .doNothing:
      return .empty()
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .updateGiftType(let isGiven):
      if let index = newState.sections.firstIndex(of: .friends(isGiven: !isGiven)) {
        let newFriendsSection: Section = .friends(isGiven: isGiven)
        newState.sections[index] = newFriendsSection
      }
      newState.giftType = isGiven ? .given : .received
      
    case .updateTitle(let title):
      newState.gift.name = title ?? ""
      
    case .updateCategory(let category):
      newState.gift.category = category
      
    case .updateDate(let date):
      newState.gift.date = date

    case .updateMemo(let memo):
      newState.gift.memo = memo
      
    case .updateFriends(let friends):
      newState.gift.relatedFriends = friends
      
    case .updateIsPinned(let isPinned):
      newState.gift.isPinned = isPinned
      
    case .updateImageList(let imageList):
      newState.imageList = imageList
    }

    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      
      let photoItems: [Item] = [.photo(nil)] + state.imageList.map { .photo($0) }
      newState.items = [
        [.title],
        [.category],
        photoItems,
        [.date],
        [.friends(state.gift.relatedFriends)],
        [.memo],
        [.pin]
      ]
      
      if !state.gift.name.isEmpty,
         !(state.gift.date == nil),
         !state.imageList.isEmpty {
        newState.isEnabledDoneButton = true
      } else {
        newState.isEnabledDoneButton = false
      }
      
      return newState
    }
  }
}

// MARK: - Network

private extension GiftManagementViewReactor {
  func requestPostGift(_ gift: Gift) -> Single<Gift> {
    return Single<Gift>.create { single in
      let networking = GiftNetworking()
      let requestDTO = gift.requestDTO()
      
      let disposable = networking.request(.postGift(requestDTO))
        .asSingle()
        .subscribe(with: self, onSuccess: { _, response in
          do {
            let responseDTO: ResponseDTO<GiftSingleResponseDTO> = try APIManager.decode(response.data)
            single(.success(Gift(singleDTO: responseDTO.data)))
          } catch {
            single(.failure(error))
          }
        })

      return Disposables.create {
        disposable.dispose()
      }
    }
  }
  
  func requestPatchGift(_ gift: Gift) -> Single<Gift> {
    return Single<Gift>.create { single in
      let networking = GiftNetworking()
      let requestDTO = gift.updateRequestDTO()

      let disposable = networking.request(.patchGift(requestDTO, giftNo: gift.identifier))
        .asSingle()
        .subscribe(with: self, onSuccess: { _, response in
          do {
            let responseDTO: ResponseDTO<GiftSingleResponseDTO> = try APIManager.decode(response.data)
            single(.success(Gift(singleDTO: responseDTO.data)))
          } catch {
            single(.failure(error))
          }
        })

      return Disposables.create {
        disposable.dispose()
      }
    }
  }
}
