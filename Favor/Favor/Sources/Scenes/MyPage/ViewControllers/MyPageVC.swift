//
//  MyPageVC.swift
//  Favor
//
//  Created by 이창준 on 2023/01/11.
//

import UIKit

import ReactorKit
import RxDataSources
import SnapKit

final class MyPageViewController: BaseViewController, View {
  typealias MyPageDataSource = RxCollectionViewSectionedReloadDataSource<MyPageSection>
  
  // MARK: - Constants

  private enum Metric {
    static let headerHeight = 333.0
    /// 헤더와 컬렉션뷰가 겹치는 높이
    static let collectionViewCovereringHeaderHeight = 30.0
  }
  
  // MARK: - Properties
  
  let dataSource = MyPageDataSource(
    configureCell: { _, collectionView, indexPath, items -> UICollectionViewCell in
      switch items {
      case .giftStat(let reactor):
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: GiftStatCell.reuseIdentifier,
          for: indexPath
        ) as? GiftStatCell else { return UICollectionViewCell() }
        cell.reactor = reactor
        cell.layer.zPosition = 1
        return cell
      case .newProfile(let reactor):
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: NewProfileCell.reuseIdentifier,
          for: indexPath
        ) as? NewProfileCell else { return UICollectionViewCell() }
        cell.reactor = reactor
        return cell
      case .favor(let reactor):
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: FavorCell.reuseIdentifier,
          for: indexPath
        ) as? FavorCell else { return UICollectionViewCell() }
        cell.reactor = reactor
        return cell
      case .anniversary(let reactor):
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: AnniversaryCell.reuseIdentifier,
          for: indexPath
        ) as? AnniversaryCell else { return UICollectionViewCell() }
        cell.reactor = reactor
        return cell
      }
    }
    , configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
      guard let header = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: MyPageSectionHeaderView.reuseIdentifier,
        for: indexPath
      ) as? MyPageSectionHeaderView else { return UICollectionReusableView() }
      let section = dataSource[indexPath.section]
      header.reactor = MyPageSectionHeaderReactor(section: section)
      return header
    }
  )
  
  // MARK: - UI Components

  private lazy var headerView: MyPageHeaderView = {
    let headerView = MyPageHeaderView()
    headerView.layer.zPosition = 0
    return headerView
  }()

  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: self.view.bounds,
      collectionViewLayout: self.setupCollectionViewLayout()
    )
    
    // CollectionViewCell
    collectionView.register(
      GiftStatCell.self,
      forCellWithReuseIdentifier: GiftStatCell.reuseIdentifier
    )
    collectionView.register(
      NewProfileCell.self,
      forCellWithReuseIdentifier: NewProfileCell.reuseIdentifier
    )
    collectionView.register(
      FavorCell.self,
      forCellWithReuseIdentifier: FavorCell.reuseIdentifier
    )
    collectionView.register(
      AnniversaryCell.self,
      forCellWithReuseIdentifier: AnniversaryCell.reuseIdentifier
    )
    
    // SupplementaryView
    collectionView.register(
      MyPageSectionHeaderView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: MyPageSectionHeaderView.reuseIdentifier
    )
    
    collectionView.backgroundColor = .clear
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    collectionView.contentInsetAdjustmentBehavior = .never
    collectionView.contentInset = UIEdgeInsets(
      top: Metric.headerHeight - Metric.collectionViewCovereringHeaderHeight,
      left: .zero,
      bottom: .zero,
      right: .zero
    )
    collectionView.layer.zPosition = 1
    return collectionView
  }()
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupCollectionView()
  }
  
  // MARK: - Binding
  
  func bind(reactor: MyPageReactor) {
    // Action
    
    // State
    reactor.state.map { $0.sections }
      .bind(to: self.collectionView.rx.items(dataSource: self.dataSource))
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions
  
  // MARK: - UI Setups
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func setupLayouts() {
    [
      self.headerView,
      self.collectionView
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.headerView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(Metric.headerHeight)
    }

    self.collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func setupCollectionView() {
    Observable.just([])
      .bind(to: self.collectionView.rx.items(dataSource: self.dataSource))
      .disposed(by: self.disposeBag)

    self.collectionView.rx.contentOffset
      .skip(1)
      .bind(with: self, onNext: { owner, offset in
        owner.updateHeaderConstraintAndOpacity(offset: offset)
      })
      .disposed(by: self.disposeBag)
  }
}

// MARK: - CollectionView

private extension MyPageViewController {
  func setupCollectionViewLayout() -> UICollectionViewCompositionalLayout {
    // Layout
    let layout = UICollectionViewCompositionalLayout.init(sectionProvider: { [weak self] sectionIndex, _ in
      guard
        let sectionType = self?.dataSource[sectionIndex]
      else { fatalError("Fatal error occured while setting up section datas.") }
      return self?.createCollectionViewLayout(sectionType: sectionType, sectionIndex: sectionIndex)
    })
    // Background
    layout.register(BackgroundView.self, forDecorationViewOfKind: BackgroundView.reuseIdentifier)
    return layout
  }
  
  func createCollectionViewLayout(
    sectionType: MyPageSection,
    sectionIndex: Int
  ) -> NSCollectionLayoutSection {
    // Item
    let item = NSCollectionLayoutItem(
      layoutSize: .init(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .fractionalHeight(1.0)
      )
    )
    
    // Group
    var group: NSCollectionLayoutGroup
    if #available(iOS 16.0, *) {
      group = NSCollectionLayoutGroup.horizontal(
        layoutSize: .init(
          widthDimension: sectionType.cellSize.widthDimension,
          heightDimension: sectionType.cellSize.heightDimension
        ),
        repeatingSubitem: item,
        count: sectionType.columns
      )
    } else {
      group = NSCollectionLayoutGroup.horizontal(
        layoutSize: .init(
          widthDimension: sectionType.cellSize.widthDimension,
          heightDimension: sectionType.cellSize.heightDimension
        ),
        subitem: item,
        count: sectionType.columns
      )
    }
    group.interItemSpacing = .fixed(sectionType.spacing)
    
    // Section
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = sectionType.sectionInset
    section.interGroupSpacing = sectionType.spacing
    section.orthogonalScrollingBehavior = sectionType.orthogonalScrollingBehavior

    // Header & Background
    let sectionItem = self.dataSource[sectionIndex]
    switch sectionType {
    case .giftStat: break
    default:
      section.boundarySupplementaryItems.append(self.createHeader(section: sectionItem))
      section.decorationItems = [
        NSCollectionLayoutDecorationItem.background(elementKind: BackgroundView.reuseIdentifier)
      ]
    }
    
    return section
  }
  
  func createHeader(section: MyPageSection) -> NSCollectionLayoutBoundarySupplementaryItem {
    return NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: section.headerSize,
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top
    )
  }

  func updateHeaderConstraintAndOpacity(offset: CGPoint) {
    let remainingTopSpace = abs(offset.y) + Metric.collectionViewCovereringHeaderHeight
    let isScrollViewBelowTopOfScreen = offset.y < 0
    let isScrollViewExceedingHeaderBottom = offset.y > -Metric.headerHeight

    if isScrollViewExceedingHeaderBottom, isScrollViewBelowTopOfScreen {
      self.collectionView.contentInset = UIEdgeInsets(
        top: remainingTopSpace,
        left: .zero,
        bottom: .zero,
        right: .zero
      )
      self.headerView.snp.updateConstraints { make in
        make.height.equalTo(remainingTopSpace)
      }
      self.headerView.updateBackgroundAlpha(to: remainingTopSpace / Metric.headerHeight)
    } else if !isScrollViewBelowTopOfScreen {
      self.collectionView.contentInset = .zero
      self.headerView.snp.updateConstraints { make in
        make.height.equalTo(0)
      }
      self.headerView.updateBackgroundAlpha(to: 0)
    } else {
      self.headerView.snp.updateConstraints { make in
        make.height.equalTo(remainingTopSpace)
      }
      self.headerView.updateBackgroundAlpha(to: 1)
    }
  }
}
