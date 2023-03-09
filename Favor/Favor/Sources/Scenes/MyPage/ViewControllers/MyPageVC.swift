//
//  MyPageVC.swift
//  Favor
//
//  Created by 이창준 on 2023/01/11.
//

import UIKit

import FavorUIKit
import ReactorKit
import Reusable
import RxDataSources
import RxGesture
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

  let dataSource = MyPageDataSource(configureCell: { _, collectionView, indexPath, items in
    switch items {
    case .giftStats(let reactor):
      let cell = collectionView.dequeueReusableCell(for: indexPath) as FavorGiftStatsCell
      cell.reactor = reactor
      return cell
    case .setupProfile(let reactor):
      let cell = collectionView.dequeueReusableCell(for: indexPath) as FavorSetupProfileCell
      cell.reactor = reactor
      return cell
    case .prefers(let reactor):
      let cell = collectionView.dequeueReusableCell(for: indexPath) as FavorPrefersCell
      cell.reactor = reactor
      return cell
    case .anniversary(let reactor):
      let cell = collectionView.dequeueReusableCell(for: indexPath) as FavorAnniversaryCell
      cell.reactor = reactor
      return cell
    case .friend(let reactor):
      let cell = collectionView.dequeueReusableCell(for: indexPath) as FriendCell
      cell.reactor = reactor
      return cell
    }
  }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
    let header = collectionView.dequeueReusableSupplementaryView(
      ofKind: kind,
      for: indexPath
    ) as MyPageSectionHeaderView
    let section = dataSource[indexPath.section]
    header.reactor = MyPageSectionHeaderViewReactor(section: section)
    return header
  })

  // MARK: - UI Components

  private lazy var tempNav: UIView = {
    let view = UIView()
    let backgroundView = UIView()
    view.addSubview(backgroundView)
    backgroundView.backgroundColor = .favorColor(.icon)
    backgroundView.layer.opacity = 0.1
    backgroundView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    return view
  }()

  private lazy var tempEditButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.image = UIImage(named: "ic_Edit")
    config.baseForegroundColor = .favorColor(.icon)

    let button = UIButton(configuration: config)
    return button
  }()

  private lazy var headerView = MyPageHeaderView()

  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: self.view.bounds,
      collectionViewLayout: self.setupCollectionViewLayout()
    )
    
    // CollectionViewCell
    collectionView.register(cellType: FavorGiftStatsCell.self)
    collectionView.register(cellType: FavorSetupProfileCell.self)
    collectionView.register(cellType: FavorPrefersCell.self)
    collectionView.register(cellType: FavorAnniversaryCell.self)
    collectionView.register(cellType: FriendCell.self)
    
    // SupplementaryView
    collectionView.register(
      supplementaryViewType: MyPageSectionHeaderView.self,
      ofKind: UICollectionView.elementKindSectionHeader
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
    return collectionView
  }()
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupCollectionView()
  }
  
  // MARK: - Binding
  
  func bind(reactor: MyPageViewReactor) {
    // Action
    self.tempEditButton.rx.tap
      .map { Reactor.Action.profileDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
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
      self.collectionView,
      self.tempNav
    ].forEach {
      self.view.addSubview($0)
    }

    self.tempNav.addSubview(self.tempEditButton)
  }
  
  override func setupConstraints() {
    self.tempNav.snp.makeConstraints { make in
      make.top.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(84)
    }

    self.tempEditButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().offset(-20)
      make.bottom.equalToSuperview().offset(-9)
      make.height.width.equalTo(39)
    }

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
      guard let sectionType = self?.dataSource[sectionIndex] else { fatalError("Failed getting dataSource.") }
      return self?.createCollectionViewLayoutSection(sectionType: sectionType, sectionIndex: sectionIndex)
    })
    // Background
    layout.register(BackgroundView.self, forDecorationViewOfKind: BackgroundView.reuseIdentifier)
    return layout
  }
  
  func createCollectionViewLayoutSection(
    sectionType: MyPageSection,
    sectionIndex: Int
  ) -> NSCollectionLayoutSection {
    let isHorizontalScrollable = sectionType.widthStretchingDirection == .horizontal

    // Item
    let item = NSCollectionLayoutItem(
      layoutSize: .init(
        widthDimension: isHorizontalScrollable ? sectionType.cellSize.widthDimension : .fractionalWidth(1.0),
        heightDimension: .fractionalHeight(1.0)
      )
    )
    
    // Group
    var widthDimension: NSCollectionLayoutDimension {
      isHorizontalScrollable ? .fractionalWidth(1.0) : sectionType.cellSize.widthDimension
    }
    let group = CompositionalLayoutFactory.shared.makeCompositionalGroup(
      direction: .horizontal,
      layoutSize: NSCollectionLayoutSize(
        widthDimension: widthDimension,
        heightDimension: sectionType.cellSize.heightDimension
      ),
      subItem: item,
      count: sectionType.columns
    )
    group.interItemSpacing = .fixed(sectionType.spacing)
    
    // Section
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = sectionType.sectionInset
    section.interGroupSpacing = sectionType.spacing
    section.orthogonalScrollingBehavior = sectionType.orthogonalScrollingBehavior

    // Header & Background
    let sectionItem = self.dataSource[sectionIndex]
    switch sectionType {
    case .giftStats: break
    default:
      section.boundarySupplementaryItems.append(
        CompositionalLayoutFactory.shared.make(
          .header,
          layoutSize: sectionType.headerSize,
          kind: UICollectionView.elementKindSectionHeader
        )
      )
      section.decorationItems = [
        NSCollectionLayoutDecorationItem.background(elementKind: BackgroundView.reuseIdentifier)
      ]
    }
    
    return section
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
