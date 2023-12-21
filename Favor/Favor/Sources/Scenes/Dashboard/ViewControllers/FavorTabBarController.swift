//
//  FavorTabBarController.swift
//  Favor
//
//  Created by 이창준 on 2023/03/10.
//

import UIKit

import FavorKit
import RxCocoa
import RxFlow
import RxSwift
import SnapKit

final class FavorTabBarController: UITabBarController, Stepper {
  
  // MARK: - Properties
  
  var steps = PublishRelay<Step>()
  let favorTabBar = FavorTabBar()
  private var disposeBag = DisposeBag()
  
  /// 현재 선택된 페이지를 감지하는 `Computed Property`입니다.
  override var selectedViewController: UIViewController? {
    willSet {
      guard
        let newValue = newValue,
        let index = self.viewControllers?.firstIndex(of: newValue)
      else { return }
      self.favorTabBar.selectedIndex = index
    }
  }
  
  // MARK: - Life Cycle
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    self.setupTabBar()
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    self.setupTabBarHeight()
  }
  
  // MARK: - Setup
  
  /// 전체적인 탭바의 설정을 부여해주는 메서드입니다.
  private func setupTabBar() {
    self.delegate = self
    self.setValue(self.favorTabBar, forKey: "tabBar")
    self.favorTabBar.selectedIndex = 0
    self.favorTabBar.eventDelegate = self
  }
  
  /// 탭 바의 높이를 조정해주는 메서드입니다.
  private func setupTabBarHeight() {
    var height: CGFloat = 48.0
    height += self.view.safeAreaInsets.bottom
    var tabBarFrame = self.tabBar.frame
    tabBarFrame.size.height = height
    self.favorTabBar.frame.size.height = height
    self.tabBar.clipsToBounds = false
  }  
  
  func requestInitialData() {
    guard let homeNavVC = self.viewControllers?.first as? BaseNavigationController else { return }
    guard let myPageNavVC = self.viewControllers?.last as? BaseNavigationController else { return }
    if let homeVC = homeNavVC.topViewController as? HomeViewController {
      homeVC.reactor?.action.onNext(.viewNeedsLoaded)
    }
    if let myPageVC = myPageNavVC.topViewController as? MyPageViewController {
      myPageVC.reactor?.action.onNext(.viewNeedsLoaded)
    }
  }
}

extension FavorTabBarController: UITabBarControllerDelegate {
  override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    HapticManager.haptic(style: .soft)
  }
}

extension FavorTabBarController: FavorTabBarDelegate {
  /// 중앙의 선물 추가 버튼을 누르면 실행되는 메서드입니다.
  func didTapAddGiftButton() {
    self.steps.accept(AppStep.giftManagementIsRequired())
  }
}
