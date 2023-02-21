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
  
  // TODO: 전역적 Constants 분리
  private let backgroundElementKind = "BackgroundView"
  private let headerElementKind = "MyPageHeader"
  private let sectionHeaderElementKind = "SectionHeader"
  
  // MARK: - Properties
  
  let dataSource = MyPageDataSource(
    configureCell: { _, collectionView, indexPath, items -> UICollectionViewCell in
      switch items {
      case .header:
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: MyPageHeaderCell.reuseIdentifier,
          for: indexPath
        ) as? MyPageHeaderCell else { return UICollectionViewCell() }
        cell.layer.zPosition = 0
        return cell
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
      switch indexPath.section {
      case 0:
        guard let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: UICollectionView.elementKindSectionHeader,
          withReuseIdentifier: MyPageHeaderView.reuseIdentifier,
          for: indexPath
        ) as? MyPageHeaderView else { return UICollectionReusableView() }
        header.reactor = MyPageHeaderReactor()
        return header
      default:
        guard let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          withReuseIdentifier: MyPageSectionHeaderView.reuseIdentifier,
          for: indexPath
        ) as? MyPageSectionHeaderView else { return UICollectionReusableView() }
        let section = dataSource[indexPath.section]
        header.reactor = MyPageSectionHeaderReactor(section: section)
        return header
      }
    }
  )
  
  // MARK: - UI Components
  
  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: self.view.bounds,
      collectionViewLayout: self.setupCollectionViewLayout()
    )
    
    // CollectionViewCell
    collectionView.register(
      MyPageHeaderCell.self,
      forCellWithReuseIdentifier: MyPageHeaderCell.reuseIdentifier
    )
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
      MyPageHeaderView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: MyPageHeaderView.reuseIdentifier
    )
    collectionView.register(
      MyPageSectionHeaderView.self,
      forSupplementaryViewOfKind: self.sectionHeaderElementKind,
      withReuseIdentifier: MyPageSectionHeaderView.reuseIdentifier
    )
    
    collectionView.backgroundColor = .clear
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    collectionView.contentInsetAdjustmentBehavior = .never
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
      self.collectionView
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func setupCollectionView() {
    Observable.just([])
      .bind(to: self.collectionView.rx.items(dataSource: self.dataSource))
      .disposed(by: self.disposeBag)
    
    self.collectionView.rx.contentOffset
      .subscribe(onNext: {
        print($0)
      })
      .disposed(by: self.disposeBag)
  }
}

// MARK: - CollectionView

private extension MyPageViewController {
  func setupCollectionViewLayout() -> UICollectionViewCompositionalLayout {
    let layout = UICollectionViewCompositionalLayout.init(sectionProvider: { [weak self] sectionIndex, _ in
      guard
        let sectionType = self?.dataSource[sectionIndex]
      else { fatalError("Fatal error occured while setting up section datas.") }
      return self?.createCollectionViewLayout(sectionType: sectionType, sectionIndex: sectionIndex)
    })
    layout.register(BackgroundView.self, forDecorationViewOfKind: self.backgroundElementKind)
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
    
    let sectionItem = self.dataSource[sectionIndex]
    switch sectionType {
    case .giftStat: break
    default: section.boundarySupplementaryItems.append(self.createHeader(section: sectionItem))
    }
    
    return section
  }
  
  func createHeader(section: MyPageSection) -> NSCollectionLayoutBoundarySupplementaryItem {
    let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: section.headerSize,
      elementKind: section.headerElementKind,
      alignment: .top
    )
    return sectionHeader
  }
}
