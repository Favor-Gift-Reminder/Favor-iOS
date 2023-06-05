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

    case .giftManagementIsCompleteWithNoChanges:
      return self.popToGiftDetail()

    case .newGiftIsComplete(let gift):
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
    homeVC.presentToast(.giftDeleted(gift.name), duration: .short)

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

  func popToGiftDetail(with gift: GiftEditor? = nil) -> FlowContributors {
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
