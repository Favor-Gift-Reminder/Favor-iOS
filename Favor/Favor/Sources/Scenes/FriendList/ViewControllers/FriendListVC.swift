//
//  FriendListVC.swift
//  Favor
//
//  Created by 이창준 on 2023/04/25.
//

import UIKit

import FavorKit
import ReactorKit
import SnapKit

final class FriendListViewController: BaseFriendListViewController, View {

  // MARK: - Constants

  // MARK: - Properties

  // MARK: - UI Components

  private let editButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.background.backgroundColor = .clear
    config.updateAttributedTitle("삭제", font: .favorFont(.bold, size: 18))

    let button = UIButton(configuration: config)
    return button
  }()

  private let searchBar: FavorSearchBar = {
    let searchBar = FavorSearchBar()
    searchBar.hasBackButton = false
    searchBar.placeholder = "친구를 검색해보세요"
    return searchBar
  }()

  // MARK: - Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.composer.compose()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.setupNavigationBar()
  }

  // MARK: - Binding

  func bind(reactor: FriendListViewReactor) {
    // Action
    Observable.combineLatest(self.rx.viewDidLoad, self.rx.viewWillAppear)
      .map { _ in Reactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.editButton.rx.tap
      .map { Reactor.Action.editButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.searchBar.rx.text
      .map { Reactor.Action.searchTextDidUpdate($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.collectionView.rx.itemSelected
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { _, indexPath in
        print(indexPath)
      })
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { (sections: $0.sections, items: $0.items) }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, sectionData in
        var snapshot: NSDiffableDataSourceSnapshot<FriendSection, FriendSectionItem> = .init()
        snapshot.appendSections(sectionData.sections)
        guard
          let friendItems = sectionData.items.first,
          let friendSection = sectionData.sections.first
        else { return }
        snapshot.appendItems(friendItems, toSection: friendSection)
        owner.dataSource.apply(snapshot, animatingDifferences: true)
        owner.collectionView.collectionViewLayout.invalidateLayout()

        // Update the header view
        if let headerView = owner.collectionView.supplementaryView(
          forElementKind: UICollectionView.elementKindSectionHeader,
          at: IndexPath(item: 0, section: 0)
        ) as? FavorSectionHeaderView {
          let numberOfFriends = friendItems.count
          headerView.bind(title: "전체", digit: numberOfFriends)
        }
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  private func setupNavigationBar() {
    self.navigationItem.setRightBarButton(self.editButton.toBarButtonItem(), animated: false)
  }

  // MARK: - UI Setups

  override func setupLayouts() {
    [
      self.searchBar,
      self.collectionView
    ].forEach {
      self.view.addSubview($0)
    }
  }

  override func setupConstraints() {
    self.searchBar.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide).inset(32)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }

    self.collectionView.snp.makeConstraints { make in
      make.top.equalTo(self.searchBar.snp.bottom).offset(16)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
      make.bottom.equalTo(self.view.safeAreaLayoutGuide)
    }
  }
}
