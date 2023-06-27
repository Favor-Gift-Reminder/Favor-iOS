//
//  GiftFlow.swift
//  Favor
//
//  Created by 이창준 on 2023/05/25.
//

import OSLog
import UIKit

import FavorKit
import ImageViewer
import RxFlow

@MainActor
final class GiftFlow: Flow {

  // MARK: - Properties

  var root: Presentable {
    self.rootViewController
  }

  private let rootViewController: BaseNavigationController
  private var friendsBottomSheet: GiftFriendsBottomSheet?

  // MARK: - Initializer

  public init(rootViewController: BaseNavigationController) {
    self.rootViewController = rootViewController
  }

  // MARK: - Navigate

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }

    switch step {
    case .giftDetailIsRequired(let gift):
      return self.navigateToGiftDetail(with: gift)

    case let .giftDetailPhotoIsRequired(selectedItem, total):
      return self.navigateToGiftDetailPhoto(with: selectedItem, total: total)

    case .giftDetailIsComplete(let gift):
      return self.popToHome(with: gift)

    case .giftManagementIsRequired(let gift):
      return self.navigateToGiftManagement(with: gift)

    case .searchEmotionResultIsRequired(let emotion):
      return self.navigateToSearchEmotionResult(with: emotion)

    case .searchCategoryResultIsRequired(let category):
      return self.navigateToSearchCategoryResult(with: category)

    case .giftDetailFriendsBottomSheetIsRequired(let friends):
      return self.navigateToFriends(with: friends)

    case .friendPageIsRequired(let friend):
      return self.navigateToFriendPage(with: friend)

    case .giftManagementIsCompleteWithNoChanges:
      return self.popToGiftDetail()

    case .newGiftIsComplete:
      return self.popToGiftDetail()

    case .editGiftIsComplete(let gift):
      return self.popToGiftDetail(with: gift)

    case .giftShareIsRequired(let gift):
      return self.navigateToGiftShare(with: gift)

    default:
      return .none
    }
  }
}

// MARK: - Privates

private extension GiftFlow {
  func navigateToGiftDetail(with gift: Gift) -> FlowContributors {
    let giftDetailVC = GiftDetailViewController()
    let giftDetailReactor = GiftDetailViewReactor(gift: gift)
    giftDetailVC.reactor = giftDetailReactor
    giftDetailVC.hidesBottomBarWhenPushed = true

    self.rootViewController.pushViewController(giftDetailVC, animated: true)

    return .one(flowContributor: .contribute(
      withNextPresentable: giftDetailVC,
      withNextStepper: giftDetailReactor
    ))
  }

  func navigateToGiftDetailPhoto(with item: Int, total: Int) -> FlowContributors {
    guard
      let giftDetailVC = self.rootViewController.topViewController as? GiftDetailViewController
    else { return .none }

    let galleryVC = GalleryViewController(
      startIndex: item,
      itemsDataSource: giftDetailVC,
      configuration: giftDetailVC.galleryConfiguration()
    )
    let headerView = GiftDetailPhotoHeaderView()
    headerView.total = total
    
    galleryVC.headerView = headerView
    galleryVC.landedPageAtIndexCompletion = { index in
      headerView.currentIndex = index
    }

    giftDetailVC.presentImageGallery(galleryVC)

    return .none
  }

  func popToHome(with gift: Gift) -> FlowContributors {
    self.rootViewController.popViewController(animated: true)
    guard let homeVC = self.rootViewController.topViewController as? HomeViewController else { return .none }
//    homeVC.presentToast(.giftDeleted(gift.name), duration: .short)

    return .end(forwardToParentFlowWithStep: AppStep.tabBarIsRequired)
  }

  func navigateToGiftManagement(with gift: Gift?) -> FlowContributors {
    guard let gift = gift else { return .none }
    let giftManagementVC = GiftManagementViewController()
    let giftManagementReactor = GiftManagementViewReactor(
      .edit, with: gift, pickerManager: PHPickerManager()
    )
    giftManagementVC.reactor = giftManagementReactor

    self.rootViewController.pushViewController(giftManagementVC, animated: true)

    return .one(flowContributor: .contribute(
      withNextPresentable: giftManagementVC,
      withNextStepper: giftManagementReactor
    ))
  }

  func navigateToSearchEmotionResult(with emotion: FavorEmotion) -> FlowContributors {
    let searchEmotionVC = SearchEmotionViewController()
    let searchEmotionReactor = SearchTagViewReactor()
    searchEmotionVC.reactor = searchEmotionReactor
    searchEmotionVC.title = "선물 감정"

    DispatchQueue.main.async {
      self.rootViewController.pushViewController(searchEmotionVC, animated: true)
      searchEmotionVC.requestEmotion(emotion)
    }

    return .one(flowContributor: .contribute(
      withNextPresentable: searchEmotionVC,
      withNextStepper: searchEmotionReactor
    ))
  }

  func navigateToSearchCategoryResult(with category: FavorCategory) -> FlowContributors {
    let searchCategoryVC = SearchCategoryViewController()
    let searchCategoryReactor = SearchTagViewReactor()
    searchCategoryVC.reactor = searchCategoryReactor
    searchCategoryVC.title = "선물 카테고리"

    DispatchQueue.main.async {
      self.rootViewController.pushViewController(searchCategoryVC, animated: true)
      searchCategoryVC.requestCategory(category)
    }

    return .one(flowContributor: .contribute(
      withNextPresentable: searchCategoryVC,
      withNextStepper: searchCategoryReactor
    ))
  }

  func navigateToFriends(with friends: [Friend]) -> FlowContributors {
    let friendsBottomSheet = GiftFriendsBottomSheet()
    friendsBottomSheet.modalPresentationStyle = .overFullScreen

    DispatchQueue.main.async {
      self.rootViewController.present(friendsBottomSheet, animated: false)
      friendsBottomSheet.friends = friends
      self.friendsBottomSheet = friendsBottomSheet
    }

    return .one(flowContributor: .contribute(
      withNextPresentable: friendsBottomSheet,
      withNextStepper: friendsBottomSheet
    ))
  }

  func navigateToFriendPage(with friend: Friend) -> FlowContributors {
    let friendPageVC = FriendPageViewController()
    let friendPageReactor = FriendPageViewReactor(friend)
    friendPageVC.reactor = friendPageReactor

    DispatchQueue.main.async {
      self.friendsBottomSheet?.dismissBottomSheet()
      self.rootViewController.pushViewController(friendPageVC, animated: true)
    }

    return .one(flowContributor: .contribute(
      withNextPresentable: friendPageVC,
      withNextStepper: friendPageReactor
    ))
  }

  func popToGiftDetail(with gift: Gift? = nil) -> FlowContributors {
    // TODO: 메모리 해제
    DispatchQueue.main.async {
      self.rootViewController.popViewController(animated: true)
      if
        let gift,
        let giftDetailVC = self.rootViewController.topViewController as? GiftDetailViewController {
        giftDetailVC.update(gift: gift)
      }
    } 

    return .none
  }

  func navigateToGiftShare(with gift: Gift) -> FlowContributors {
    let giftShareVC = GiftShareViewController()
    let giftShareReactor = GiftShareViewReactor(gift: gift)
    giftShareVC.reactor = giftShareReactor
    giftShareVC.title = "선물 한 컷"

    self.rootViewController.pushViewController(giftShareVC, animated: true)

    return .one(flowContributor: .contribute(
      withNextPresentable: giftShareVC,
      withNextStepper: giftShareReactor
    ))
  }
}
