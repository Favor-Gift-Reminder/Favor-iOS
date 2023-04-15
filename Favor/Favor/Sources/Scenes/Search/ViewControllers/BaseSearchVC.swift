//
//  BaseSearchVC.swift
//  Favor
//
//  Created by 이창준 on 2023/04/15.
//

import UIKit

import FavorKit
import ReactorKit
import SnapKit

class BaseSearchViewController: BaseViewController, View {

  // MARK: - UI Components

  // SearchBar
  public lazy var searchTextField: FavorSearchBar = {
    let searchBar = FavorSearchBar()
    searchBar.searchBarHeight = 40
    searchBar.placeholder = "선물, 유저 ID를 검색해보세요"
    return searchBar
  }()

  // SearchRecent
  public lazy var recentSearchCollectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: self.makeSearchRecentCompositionalLayout()
    )

    // Register
    collectionView.register(cellType: SearchRecentCell.self)
    collectionView.register(
      supplementaryViewType: SearchRecentHeader.self,
      ofKind: SearchRecentCell.reuseIdentifier
    )

    // Setup
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    collectionView.isHidden = true
    return collectionView
  }()

  // MARK: - Binding

  func bind(reactor: SearchViewReactor) {
    // Action
    self.searchTextField.rx.editingDidBegin
      .debug("editingDidBegin")
      .map { Reactor.Action.editingDidBegin }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.searchTextField.rx.text
      .distinctUntilChanged()
      .debug("text")
      .map { Reactor.Action.textDidChanged($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.searchTextField.rx.editingDidEnd
      .debug("editingDidEnd")
      .map { Reactor.Action.editingDidEnd }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

//    Observable.combineLatest(self.rx.viewWillDisappear, self.searchTextField.rx.backButtonDidTap)
    self.searchTextField.rx.backButtonDidTap
      .throttle(.nanoseconds(500), scheduler: MainScheduler.asyncInstance)
      .debug("viewWillDisappear")
      .map { _ in Reactor.Action.viewWillDisappear }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
  }
}

// MARK: - CollectionView

private extension BaseSearchViewController {
  func makeSearchRecentCompositionalLayout() -> UICollectionViewCompositionalLayout {
    let item = NSCollectionLayoutItem(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .fractionalHeight(1.0)
      )
    )
    let group = UICollectionViewCompositionalLayout.group(
      direction: .vertical,
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(28)
      ),
      subItem: item,
      count: 1
    )
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 16

    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(21)
      ),
      elementKind: SearchRecentCell.reuseIdentifier,
      alignment: .topLeading
    )
    section.boundarySupplementaryItems = [header]

    section.contentInsets = NSDirectionalEdgeInsets(
      top: 16,
      leading: 20,
      bottom: 16,
      trailing: 20
    )

    let layout = UICollectionViewCompositionalLayout(section: section)
    return layout
  }
}
