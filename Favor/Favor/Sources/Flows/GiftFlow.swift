//
//  GiftFlow.swift
//  Favor
//
//  Created by 이창준 on 2023/05/25.
//

import UIKit

import FavorKit
import ImageViewer
import RxFlow

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

    DispatchQueue.main.async {
      self.rootViewController.pushViewController(giftDetailVC, animated: true)
    }

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

    DispatchQueue.main.async {
      giftDetailVC.presentImageGallery(galleryVC)
    }

    return .none
  }
}
