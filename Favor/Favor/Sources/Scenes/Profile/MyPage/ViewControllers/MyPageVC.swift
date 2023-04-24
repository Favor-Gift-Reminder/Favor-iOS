//
//  MyPageVC.swift
//  Favor
//
//  Created by 이창준 on 2023/01/11.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import RxDataSources
import RxGesture
import SnapKit

final class MyPageViewController: BaseProfileViewController, View {
  
  // MARK: - Constants
  
  // MARK: - Properties

  // MARK: - UI Components

  private let editButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.image = .favorIcon(.edit)?.withRenderingMode(.alwaysTemplate)
    config.background.backgroundColor = .clear
    config.baseForegroundColor = .favorColor(.white)

    let button = UIButton(configuration: config)
    return button
  }()

  private let settingButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.image = .favorIcon(.setting)?.withRenderingMode(.alwaysTemplate)
    config.background.backgroundColor = .clear
    config.baseForegroundColor = .favorColor(.white)

    let button = UIButton(configuration: config)
    return button
  }()
  
  // MARK: - Life Cycle
  
  // MARK: - Binding

  override func bind() {
    guard let reactor = self.reactor else { return }

    // Action
    self.collectionView.rx.contentOffset
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, offset in
        owner.updateProfileViewLayout(by: offset)
      })
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { $0.sections }
      .bind(to: self.collectionView.rx.items(dataSource: self.dataSource))
      .disposed(by: self.disposeBag)
  }
  
  func bind(reactor: MyPageViewReactor) {
    // Action
    Observable.combineLatest(self.rx.viewDidLoad, self.rx.viewWillAppear)
      .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)
      .map { _ in Reactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.editButton.rx.tap
      .map { Reactor.Action.editButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.settingButton.rx.tap
      .map { Reactor.Action.settingButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { $0.userName }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, name in
        owner.profileView.rx.name.onNext(name)
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.userID }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, id in
        owner.profileView.rx.id.onNext(id)
      })
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions

  override func setupNavigationBar() {
    super.setupNavigationBar()

    let rightBarItems = [self.settingButton.toBarButtonItem(), self.editButton.toBarButtonItem()]
    self.navigationItem.setRightBarButtonItems(rightBarItems, animated: false)
    self.navigationController?.hidesBarsOnSwipe = true
  }

  override func injectReactor(to view: UICollectionReusableView) {
    guard
      let view = view as? ProfileGiftStatsCollectionHeader,
      let reactor = self.reactor
    else { return }
    view.reactor = ProfileGiftStatsCollectionHeaderReactor(
      gift: reactor.currentState.user.giftList.toArray()
    )
  }

  // MARK: - UI Setups

}

// MARK: - Privates

private extension MyPageViewController {

}
