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
    case photoDidAdd(UIImage?)
    /// 선택된 사진 삭제
    case removeButtonDidTap(GiftManagementPhotoModel)
    /// 동작 없음
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
    case updateImageList([GiftManagementPhotoModel])
    case updateRemoveTargetUrls(String)
  }
  
  struct State {
    var viewType: GiftManagementViewController.ViewType
    var giftType: GiftManagementViewController.GiftType = .received
    var isEnabledDoneButton: Bool = false
    var gift: Gift
    /// 최초의 핀 상태를 저장합니다. (네트워크 요청을 위한)
    var initialPinState: Bool = false
    /// 현재 보여지는 이미지들입니다.
    var imageList: [GiftManagementPhotoModel] = []
    /// 기존에 저장되어 있는 있는 사진을 삭제할 URL 모음입니다.
    var removeTargetUrls: [String] = []
    var sections: [Section] = []
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
      giftType: gift.isGiven ? .given : .received,
      gift: gift,
      initialPinState: gift.isPinned
    )
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      if self.currentState.viewType == .edit {
        return .just(.updateImageList(self.currentState.gift.photos
          .map { .init(url: $0.remote, isNew: false, image: nil) }
        ))
      } else {
        return .empty()
      }
      
    case .cancelButtonDidTap:
      self.steps.accept(AppStep.giftManagementIsCompleteWithNoChanges)
      return .empty()

    case .doneButtonDidTap:
      switch self.currentState.viewType {
      case .new:
        return self.requestPostGift(self.currentState.gift)
          .asObservable()
          .flatMap { _ -> Observable<Mutation> in
            self.steps.accept(AppStep.newGiftIsComplete)
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
      self.steps.accept(AppStep.friendSelectorIsRequired(self.currentState.gift.friends))
      return .empty()

    case .dateDidUpdate(let date):
      return .just(.updateDate(date))
      
    case .memoDidUpdate(let memo):
      return .just(.updateMemo(memo))

    case .pinButtonDidTap(let isPinned):
      return .just(.updateIsPinned(isPinned))
      
    case .friendsDidAdd(let friends):
      return .just(.updateFriends(friends))
      
    case .photoDidAdd(let image):
      self.pickerManager = nil
      var imageList = self.currentState.imageList
      imageList.append(.init(url: nil, isNew: true, image: image))
      return .just(.updateImageList(imageList))
      
    case .removeButtonDidTap(let photoModel):
      var imageList = self.currentState.imageList
      guard let removeIndex = imageList.firstIndex(where: { $0 == photoModel })
      else { return .empty() }
      let photoModel = imageList.remove(at: removeIndex)
      if let url = photoModel.url {
        // 기존에 존재했던 사진
        return .concat([
          .just(.updateRemoveTargetUrls(url)),
          .just(.updateImageList(imageList))
        ])
      } else {
        // 갤러리에서 첨부한 사진
        return .just(.updateImageList(imageList))
      }
      
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
      newState.gift.isGiven = isGiven
      
    case .updateTitle(let title):
      newState.gift.name = title ?? ""
      
    case .updateCategory(let category):
      newState.gift.category = category
      
    case .updateDate(let date):
      newState.gift.date = date

    case .updateMemo(let memo):
      newState.gift.memo = memo
      
    case .updateFriends(let friends):
      newState.gift.relatedFriends = friends.filter { $0.identifier > 0 }
      newState.gift.tempFriends = friends.filter { $0.identifier < 0 }.map { $0.friendName }
      
    case .updateIsPinned(let isPinned):
      newState.gift.isPinned = isPinned
      
    case .updateImageList(let imageList):
      newState.imageList = imageList
      
    case .updateRemoveTargetUrls(let urlString):
      newState.removeTargetUrls.append(urlString)
    }

    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      
      let photoItems: [Item] = [.photo(nil)] + state.imageList.map { .photo($0) }
      
      newState.sections = [
        .title,
        .category,
        .photos,
        .date,
        .friends(isGiven: state.gift.isGiven),
        .memo,
        .pin
      ]
      newState.items = [
        [.title], [.category], photoItems, [.date], [.friends(state.gift.friends)], [.memo], [.pin]
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

// MARK: - Privates

private extension GiftManagementViewReactor {
  func loadImages(_ gift: Gift) -> Single<[GiftManagementPhotoModel]> {
    return Single<[GiftManagementPhotoModel]>.create { single in
      Task {
        var imageList: [GiftManagementPhotoModel] = []
        for photo in gift.photos {
          guard let url = URL(string: photo.remote) else { break }
          do {
            let image = try await ImageDownloadManager.downloadImage(with: url)
            imageList.append(.init(url: photo.remote, isNew: false, image: image))
            if imageList.count == gift.photos.count {
              single(.success(imageList))
            }
          } catch {
            print(error)
          }
        }
      }
      return Disposables.create()
    }
  }
}

// MARK: - Network

private extension GiftManagementViewReactor {
  func requestPostGift(_ gift: Gift) -> Observable<Void> {
    let giftNetworking = GiftNetworking()
    let requestDTO = gift.requestDTO()
    let imageList = self.currentState.imageList
    return giftNetworking.request(.postGift(requestDTO))
      .map(ResponseDTO<GiftSingleResponseDTO>.self)
      .map { $0.data.giftNo }
      .flatMap { giftNo in
        if gift.isPinned {
          return giftNetworking.request(.patchPinGift(giftNo: giftNo)).map { _ in giftNo }
        } else {
          return Observable<Int>.just(giftNo)
        }
      }
      .flatMap { self.requestPostGiftPhoto(imageList, giftNo: $0) }
  }
  
  func requestPatchGift(_ gift: Gift) -> Observable<Gift> {
    let giftNetworking = GiftNetworking()
    let requestDTO = gift.updateRequestDTO()
    let giftNo = gift.identifier
    let removeTargetUrls = self.currentState.removeTargetUrls
    let imageList = self.currentState.imageList
    let initialPinState = self.currentState.initialPinState
    
    return self.requestDeleteGiftPhoto(removeTargetUrls, giftNo: giftNo)
      .flatMap { _ in self.requestPostGiftPhoto(imageList, giftNo: giftNo) }
      .flatMap { _ in
        giftNetworking.request(.patchTempFriendList(giftNo: giftNo, tempFriendList: gift.tempFriends))
      }
      .flatMap { _ in
        if initialPinState != gift.isPinned {
          return giftNetworking.request(.patchPinGift(giftNo: giftNo)).map { _ in Void() }
        } else {
          return .just(Void())
        }
      }
      .flatMap { _ in giftNetworking.request(.patchGift(requestDTO, giftNo: giftNo)) }
      .map(ResponseDTO<GiftSingleResponseDTO>.self)
      .map { Gift(singleDTO: $0.data) }
  }
  
  func requestPatchPinGift(_ giftNo: Int) -> Observable<Int> {
    let gift = self.currentState.gift
    if gift.isPinned == self.currentState.initialPinState {
      return .just(giftNo)
    } else {
      let networking = GiftNetworking()
      return networking.request(.patchPinGift(giftNo: giftNo))
        .flatMap { _ in return Observable.just(giftNo) }
    }
  }
  
  func requestPostGiftPhoto(_ imageList: [GiftManagementPhotoModel], giftNo: Int) -> Observable<Void> {
    let networking = GiftPhotoNetworking()
    let imageList = imageList.filter { $0.isNew }
    if imageList.isEmpty {
      return .just(Void())
    } else {
      return Observable<Void>.create { observer in
        var completeCount: Int = 0
        _ = Observable.from(imageList)
          .concatMap { item in
            let file = APIManager.createMultiPartForm(item.image)
            return networking.request(.postGiftPhotos(file: file, giftNo: giftNo))
          }
          .subscribe { _ in
            completeCount += 1
            if completeCount == imageList.count {
              observer.onNext(Void())
              observer.onCompleted()
            }
          }
        return Disposables.create()
      }
    }
  }
  
  func requestDeleteGiftPhoto(_ urls: [String], giftNo: Int) -> Observable<Void> {
    let networking = GiftPhotoNetworking()
    if urls.isEmpty {
      return .just(Void())
    } else {
      return Observable<Void>.create { observer in
        var completeCount: Int = 0
        _ = Observable.from(urls)
          .concatMap { url in
            return networking.request(.deleteGiftPhotos(fileUrl: url, giftNo: giftNo))
          }
          .subscribe { _ in
            completeCount += 1
            if completeCount == urls.count {
              observer.onNext(Void())
              observer.onCompleted()
            }
          }
        return Disposables.create()
      }
    }
  }
}
