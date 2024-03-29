//
//  NewGiftFriendVC.swift
//  Favor
//
//  Created by 김응철 on 2023/04/14.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable

final class FriendSelectorViewController: BaseViewController, View {
  typealias DataSource = UICollectionViewDiffableDataSource<FriendSelectorSectionItem, FriendSelectorSection>
  
  private enum Metric {
    // Cell
    static let emptyCellHeight: CGFloat = 93.0
    static let friendCellHeight: CGFloat = 48.0

    // SupplementaryView
    static let footerHeight: CGFloat = 91.0
    static let selectedFriendsHeaderHeight: CGFloat = 54.0
    static let friendsHeaderHeight: CGFloat = 100.0
    
    // Inset
    static let interGroupSpacing: CGFloat = 8.0
    static let topContentsInset: CGFloat = 16.0
  }
  
  // MARK: - Properties
  
  private lazy var dataSource: DataSource = {
    let dataSource = DataSource(
      collectionView: self.collectionView,
      cellProvider: { collectionView, indexPath, item in
        switch item {
        case .empty:
          let cell = collectionView.dequeueReusableCell(for: indexPath) as FriendSelectorEmptyCell
          return cell
        case let .friend(friend, buttonType):
          let cell = collectionView.dequeueReusableCell(for: indexPath) as FriendSelectorCell
          cell.configure(with: friend, buttonType: buttonType)
          return cell
        }
      }
    )
    dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
      guard let self = self, let reactor = self.reactor else {
        return UICollectionReusableView()
      }
      switch kind {
      case UICollectionView.elementKindSectionHeader:
        let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          for: indexPath
        ) as FriendSelectorHeaderView
        let section = self.dataSource.sectionIdentifier(for: indexPath.section) ?? .friends
        let friends = section == .friends ?
        reactor.currentState.currentFriends : reactor.currentState.selectedFriends
        header.configure(section: section, friendsCount: friends.count)
        self.setupSearchBar()
        return header
      case UICollectionView.elementKindSectionFooter:
        let footer = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          for: indexPath
        ) as FriendSelectorFooterView
        // 탭 이벤트
        footer.tapCompletion = { [weak self] in
          self?.reactor?.action.onNext(.addFriendDidTap)
        }
        return footer
      default:
        return UICollectionReusableView()
      }
    }
    return dataSource
  }()
  
  // MARK: - UI Components
  
  // Navigation Items
  private let finishButton: FavorButton = {
    let button = FavorButton("완료")
    button.baseBackgroundColor = .white
    button.font = .favorFont(.bold, size: 18.0)
    button.contentInset = .zero
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      guard let button = button as? FavorButton else { return }
      switch button.state {
      case .disabled:
        button.baseForegroundColor = .favorColor(.line2)
        button.configuration?.background.backgroundColor = .white
      default:
        button.baseForegroundColor = .favorColor(.main)
      }
    }
    button.configurationUpdateHandler = handler
    return button
  }()
  
  // View Items
  private lazy var collectionView: UICollectionView = {
    let cv = UICollectionView(
      frame: .zero,
      collectionViewLayout: self.setupCollectionViewLayout()
    )
    cv.backgroundColor = .favorColor(.white)
    cv.register(cellType: FriendSelectorEmptyCell.self)
    cv.register(cellType: FriendSelectorCell.self)
    cv.register(
      supplementaryViewType: FriendSelectorHeaderView.self,
      ofKind: UICollectionView.elementKindSectionHeader
    )
    cv.register(
      supplementaryViewType: FriendSelectorFooterView.self,
      ofKind: UICollectionView.elementKindSectionFooter
    )
    return cv
  }()
  
  private let searchBar: FavorSearchBar = {
    let searchBar = FavorSearchBar()
    searchBar.hasBackButton = false
    return searchBar
  }()
  
  private lazy var tapGestureRecongnizer: UITapGestureRecognizer = {
    let tg = UITapGestureRecognizer()
    tg.addTarget(self, action: #selector(self.didTapBackgroundView))
    tg.cancelsTouchesInView = false
    return tg
  }()
  
  // MARK: - LifeCycle
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()

    self.navigationItem.rightBarButtonItem = self.finishButton.toBarButtonItem()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    self.view.addSubview(self.collectionView)
    self.view.addSubview(self.searchBar)
    self.view.addGestureRecognizer(self.tapGestureRecongnizer)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.collectionView.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
      make.top.bottom.equalToSuperview()
    }
  }
  
  private func setupSearchBar() {
    guard let header = self.collectionView.supplementaryView(
      forElementKind: UICollectionView.elementKindSectionHeader,
      at: IndexPath(row: 0, section: 1)
    ) else { return }
    DispatchQueue.main.async {
      self.searchBar.snp.makeConstraints { make in
        make.directionalHorizontalEdges.equalToSuperview().inset(24.0)
        make.top.equalTo(header.snp.bottom).offset(-28.0)
      }
    }
  }
  
  // MARK: - Bind
  
  func bind(reactor: FriendSelectorViewReactor) {
    // Action
    self.rx.viewDidLoad
      .map { FriendSelectorViewReactor.Action.viewDidLoad }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.collectionView.rx.itemSelected
      .withUnretained(self)
      .map { owner, indexPath in
        guard let cell = owner.collectionView.cellForItem(
          at: indexPath
        ) as? FriendSelectorCell
        else {
          return (IndexPath(row: -1, section: 0), .done)
        }
        return (indexPath, cell.currentButtonType)
      }
      .map { FriendSelectorViewReactor.Action.cellDidTap($0, $1) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.finishButton.rx.tap
      .map { FriendSelectorViewReactor.Action.finishButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.searchBar.rx.text.orEmpty
      .map { FriendSelectorViewReactor.Action.textFieldDidChange($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { (sections: $0.sections, items: $0.items) }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self, onNext: { owner, sectionItems in
        var snapshot = NSDiffableDataSourceSnapshot<FriendSelectorSectionItem, FriendSelectorSection>()
        snapshot.appendSections(sectionItems.sections)
        snapshot.reloadSections([.selectedFriends])
        sectionItems.items.enumerated().forEach { index, items in
          snapshot.appendItems(items, toSection: sectionItems.sections[index])
        }
        DispatchQueue.main.async {
          owner.dataSource.apply(snapshot, animatingDifferences: false)
        }
      })
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.isEnabledFinishButton }
      .bind(to: self.finishButton.rx.isEnabled)
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions
  
  @objc
  private func didTapBackgroundView() {
    self.view.endEditing(true)
  }
  
  func tempFriendAdded(_ friendName: String) {
    self.reactor?.action.onNext(.tempFriendDidAdd(friendName))
  }
}

// MARK: - Privates

private extension FriendSelectorViewController {
  func setupCollectionViewLayout() -> UICollectionViewCompositionalLayout {
    return UICollectionViewCompositionalLayout(
      sectionProvider: { sectionIndex, _ in
        let sections: [FriendSelectorSectionItem] = [.selectedFriends, .friends]
        let sectionType = sections[sectionIndex]
        let isEmptySelectedFriends: Bool = self.reactor?.currentState.selectedFriends.isEmpty ?? false
        return self.createCollectionViewLayout(
          sectionType: sectionType,
          isEmptySelectedFriends: isEmptySelectedFriends
        )
      }
    )
  }
  
  func createCollectionViewLayout(
    sectionType: FriendSelectorSectionItem,
    isEmptySelectedFriends: Bool
  ) -> NSCollectionLayoutSection {
    let emptyItemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .absolute(Metric.emptyCellHeight)
    )
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .absolute(Metric.friendCellHeight)
    )
    let activeItemSize: NSCollectionLayoutSize
    let topContentInset: CGFloat
    let bottomContentInset: CGFloat
    
    switch sectionType {
    case .selectedFriends:
      activeItemSize = isEmptySelectedFriends ? emptyItemSize : itemSize
      topContentInset = 16.0
      bottomContentInset = isEmptySelectedFriends ? 48.0 : 8.0
    case .friends:
      activeItemSize = itemSize
      topContentInset = 32.0
      bottomContentInset = 16.0
    }
    
    let item = NSCollectionLayoutItem(layoutSize: activeItemSize)
    let group = NSCollectionLayoutGroup.vertical(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(50.0) // Auto Height
      ),
      subitems: [item]
    )
    
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = Metric.interGroupSpacing
    section.contentInsets = NSDirectionalEdgeInsets(
      top: topContentInset,
      leading: 0,
      bottom: bottomContentInset,
      trailing: 0
    )
    section.boundarySupplementaryItems = [self.createHeader(section: sectionType)]
    
    if sectionType == .friends {
      if self.reactor?.currentState.viewType == .gift {
        section.boundarySupplementaryItems.append(contentsOf: [self.createFooter()])
      }
    }
    return section
  }
  
  // 헤더 생성
  func createHeader(
    section: FriendSelectorSectionItem
  ) -> NSCollectionLayoutBoundarySupplementaryItem {
    let height: CGFloat
    switch section {
    case .selectedFriends: height = Metric.selectedFriendsHeaderHeight
    case .friends: height = Metric.friendsHeaderHeight
    }
    
    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(height)
      ),
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top
    )
    return header
  }
  
  // 푸터 생성
  func createFooter() -> NSCollectionLayoutBoundarySupplementaryItem {
    let footerSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .absolute(Metric.footerHeight)
    )
    let footer = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: footerSize,
      elementKind: UICollectionView.elementKindSectionFooter,
      alignment: .bottom
    )
    return footer
  }
}
