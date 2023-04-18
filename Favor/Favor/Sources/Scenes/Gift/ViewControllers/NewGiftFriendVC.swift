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
  typealias DataSource = RxCollectionViewSectionedReloadDataSource<NewGiftFriendSection.NewGiftFriendSectionModel>
  
  private enum Constants {
    static let emptyCellHeight: CGFloat = 93.0
    static let friendCellHeight: CGFloat = 48.0
    static let interGroupSpacing: CGFloat = 40.0
    static let footerHeight: CGFloat = 65.0
  }
  
  // MARK: - UI Components
  
  // Navigation Items
  private let doneButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 4)
    config.attributedTitle = AttributedString(
      "완료",
      attributes: .init([
        .font: UIFont.favorFont(.bold, size: 18)
      ])
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
  
  // MARK: - Properties
  
  private let dataSource = DataSource(
    configureCell: { _, collectionView, indexPath, item in
      switch item {
      case .empty:
        let cell = collectionView.dequeueReusableCell(for: indexPath) as NewGiftFriendEmptyCell
        return cell
      case .friend(let reactor):
        let cell = collectionView.dequeueReusableCell(for: indexPath) as NewGiftFriendCell
        cell.reactor = reactor
        return cell
      }
    },
    configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
      let sectionItem = dataSource[indexPath.section]
      
      if kind == UICollectionView.elementKindSectionHeader {
        let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          for: indexPath
        ) as NewGiftFriendHeaderView
        header.reactor = NewGiftFriendHeaderViewReactor(section: sectionItem.model)
        return header
      } else {
        let footer = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          for: indexPath
        ) as NewGiftFriendFooterView
        return footer
      }
    }
  )
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.doneButton)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    self.view.addSubview(self.collectionView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    self.collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    self.reactor?.state.map { [$0.selectedSection, $0.friendListSection] }
    .bind(to: self.collectionView.rx.items(dataSource: self.dataSource))
    .disposed(by: self.disposeBag)
  }
  
  func bind(reactor: NewGiftFriendViewReactor) {
  }
}

// MARK: - Privates

private extension NewGiftFriendViewController {
  func setupCollectionViewLayout() -> UICollectionViewCompositionalLayout {
    return UICollectionViewCompositionalLayout(
      sectionProvider: { [weak self] sectionIndex, _ in
        return self?.createCollectionViewLayout(
          sectionType: self?.dataSource[sectionIndex].model ?? .friendList,
          isEmptySelectedFriend: true
        )
      }
    )
  }
  
  func createCollectionViewLayout(
    sectionType: NewGiftFriendSectionType,
    isEmptySelectedFriend: Bool
  ) -> NSCollectionLayoutSection {
    let emptyItemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .absolute(Constants.emptyCellHeight)
    )
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .absolute(Constants.friendCellHeight)
    )
    
    let activeItemSize: NSCollectionLayoutSize
    
    switch sectionType {
    case .selectedFriends:
      activeItemSize = isEmptySelectedFriend ? emptyItemSize : itemSize
    case .friendList:
      activeItemSize = itemSize
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
    section.interGroupSpacing = Constants.interGroupSpacing
    section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
    section.boundarySupplementaryItems = [self.createHeader(sectionType: sectionType)]
    
    if sectionType == .friendList {
      section.boundarySupplementaryItems.append(contentsOf: [self.createFooter()])
    }
    
    return section
  }
  
  // 헤더 생성
  func createHeader(
    sectionType: NewGiftFriendSectionType
  ) -> NSCollectionLayoutBoundarySupplementaryItem {
    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: sectionType.headerHeight
      ),
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top
    )
    return header
  }
  
  func createFooter() -> NSCollectionLayoutBoundarySupplementaryItem {
    let footerSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .absolute(Constants.footerHeight)
    )
    let footer = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: footerSize,
      elementKind: UICollectionView.elementKindSectionFooter,
      alignment: .bottom
    )
    return footer
  }
}
