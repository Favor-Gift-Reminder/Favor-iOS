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
import RxDataSources

final class NewGiftFriendViewController: BaseViewController, View {
  typealias DataSource = UICollectionViewDiffableDataSource<NewGiftFriendSection, NewGiftFriendItem>
  
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
          let cell = collectionView.dequeueReusableCell(for: indexPath) as NewGiftFriendEmptyCell
          return cell
        case .friend(let reactor):
          let cell = collectionView.dequeueReusableCell(for: indexPath) as NewGiftFriendCell
          cell.reactor = reactor
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
        ) as NewGiftFriendHeaderView
        let section = self.dataSource.sectionIdentifier(for: indexPath.section) ?? .friends
        let friends = section == .friends ?
        reactor.allFriends :
        reactor.currentState.selectedFriends
        header.reactor = NewGiftFriendHeaderViewReactor(section, friends: friends)
        // 서치바 이벤트
        header.textFieldChanged = { [weak self] in
          self?.reactor?.action.onNext(.textFieldDidChange($0))
        }
        
        return header
      case UICollectionView.elementKindSectionFooter:
        let footer = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          for: indexPath
        ) as NewGiftFriendFooterView
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
  private let finishButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 4)
    config.attributedTitle = AttributedString(
      "완료",
      attributes: .init([.font: UIFont.favorFont(.bold, size: 18)])
    )
    let btn = UIButton(configuration: config)
    btn.configurationUpdateHandler = {
      switch $0.state {
      case .disabled:
        config.baseForegroundColor = .favorColor(.line2)
      case .normal:
        config.baseForegroundColor = .favorColor(.icon)
      default:
        break
      }
    }
    btn.isEnabled = false
    return btn
  }()
  
  // View Items
  private lazy var collectionView: UICollectionView = {
    let cv = UICollectionView(
      frame: .zero,
      collectionViewLayout: self.setupCollectionViewLayout()
    )
    cv.backgroundColor = .favorColor(.white)
    cv.register(cellType: NewGiftFriendEmptyCell.self)
    cv.register(cellType: NewGiftFriendCell.self)
    cv.register(
      supplementaryViewType: NewGiftFriendHeaderView.self,
      ofKind: UICollectionView.elementKindSectionHeader
    )
    cv.register(
      supplementaryViewType: NewGiftFriendFooterView.self,
      ofKind: UICollectionView.elementKindSectionFooter
    )
    return cv
  }()
  
  private lazy var tapGestureRecongnizer: UITapGestureRecognizer = {
    let tg = UITapGestureRecognizer()
    tg.addTarget(self, action: #selector(self.didTapBackgroundView))
    tg.cancelsTouchesInView = false
    return tg
  }()

  private let mainView: UIView = {
    let view = UIView()
    view.backgroundColor = .favorColor(.black)
    return view
  }()
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    self.navigationItem.rightBarButtonItem = self.finishButton.toBarButtonItem()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    self.view.addSubview(self.collectionView)
    self.view.addSubview(self.mainView)
    self.view.addGestureRecognizer(self.tapGestureRecongnizer)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  // MARK: - Bind
  
  func bind(reactor: NewGiftFriendViewReactor) {
    // Action
    self.rx.viewDidLoad
      .map { NewGiftFriendViewReactor.Action.viewDidLoad }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.collectionView.rx.itemSelected
      .withUnretained(self)
      .map { owner, indexPath in
        guard let cell = owner.collectionView.cellForItem(
          at: indexPath
        ) as? NewGiftFriendCell
        else {
          return (IndexPath(row: -1, section: 0), .done)
        }
        return (indexPath, cell.currentButtonType)
      }
      .map { NewGiftFriendViewReactor.Action.cellDidTap($0, $1) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { $0.items }
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: [])
      .drive(with: self, onNext: { owner, items in
        var snapShot = NSDiffableDataSourceSnapshot<NewGiftFriendSection, NewGiftFriendItem>()
        let sections: [NewGiftFriendSection] = [.selectedFriends, .friends]
        snapShot.appendSections(sections)
        snapShot.reloadSections([.selectedFriends])
        items.enumerated().forEach { index, items in
          snapShot.appendItems(items, toSection: sections[index])
        }
        owner.dataSource.apply(snapShot, animatingDifferences: false)
      })
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.isLoading }
      .bind(to: self.rx.isLoading)
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
}

// MARK: - Privates

private extension NewGiftFriendViewController {
  func setupCollectionViewLayout() -> UICollectionViewCompositionalLayout {
    return UICollectionViewCompositionalLayout(
      sectionProvider: { sectionIndex, _ in
        let sections: [NewGiftFriendSection] = [.selectedFriends, .friends]
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
    sectionType: NewGiftFriendSection,
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
      section.boundarySupplementaryItems.append(contentsOf: [self.createFooter()])
    }
    return section
  }
  
  // 헤더 생성
  func createHeader(
    section: NewGiftFriendSection
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
