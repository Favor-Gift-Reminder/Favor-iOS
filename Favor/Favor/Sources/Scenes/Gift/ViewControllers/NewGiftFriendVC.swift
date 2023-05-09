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
    static let interGroupSpacing: CGFloat = 8.0
    static let footerHeight: CGFloat = 91.0
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
  
  private lazy var dataSource = DataSource(
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
      let sectionModel = dataSource[indexPath.section]
      if kind == UICollectionView.elementKindSectionHeader {
        let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          for: indexPath
        ) as NewGiftFriendHeaderView
        header.reactor = NewGiftFriendHeaderViewReactor(sectionModel: sectionModel)
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
        ) as? NewGiftFriendCell else {
          fatalError()
        }
        return (indexPath, cell.currentButtonType)
      }
      .map { NewGiftFriendViewReactor.Action.cellDidTap($0, $1) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { [$0.selectedSection, $0.friendListSection] }
      .bind(to: self.collectionView.rx.items(dataSource: dataSource))
      .disposed(by: self.disposeBag)
  }
}

// MARK: - Privates

private extension NewGiftFriendViewController {
  func setupCollectionViewLayout() -> UICollectionViewCompositionalLayout {
    return UICollectionViewCompositionalLayout(
      sectionProvider: { [weak self] sectionIndex, _ in
        guard
          let sectionModel = self?.dataSource[sectionIndex],
          let firstItem = sectionModel.items.first
        else { fatalError("Section을 설정하는 도중 치명적인 에러 발생") }
        
        var isEmptySelectedFriend: Bool = false
        if case NewGiftFriendSection.NewGiftFriendSectionItem.empty = firstItem {
          isEmptySelectedFriend = true
        }
        
        return self?.createCollectionViewLayout(
          sectionType: sectionModel.model,
          isEmptySelectedFriend: isEmptySelectedFriend
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
    let topContentInset: CGFloat
    let bottomContentInset: CGFloat
    
    switch sectionType {
    case .selectedFriends:
      activeItemSize = isEmptySelectedFriend ? emptyItemSize : itemSize
      topContentInset = 16.0
      bottomContentInset = isEmptySelectedFriend ? 48.0 : 8.0
    case .friendList:
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
    section.interGroupSpacing = Constants.interGroupSpacing
    section.contentInsets = NSDirectionalEdgeInsets(
      top: topContentInset,
      leading: 0,
      bottom: bottomContentInset,
      trailing: 0
    )
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
