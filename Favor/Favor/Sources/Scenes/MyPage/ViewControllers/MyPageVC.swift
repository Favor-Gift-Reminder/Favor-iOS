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
  
  // MARK: - Properties
  
  let dataSource = MyPageDataSource(
    configureCell: { _, collectionView, indexPath, items -> UICollectionViewCell in
      switch items {
      case .giftCount:
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: GiftCountCell.reuseIdentifier,
          for: indexPath
        ) as? GiftCountCell else { return UICollectionViewCell() }
        // cell.reactor = reactor
        return cell
      case .newProfile:
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: NewProfileCell.reuseIdentifier,
          for: indexPath
        ) as? NewProfileCell else { return UICollectionViewCell() }
        // cell.reactor = reactor
        return cell
      case .favor:
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: FavorCell.reuseIdentifier,
          for: indexPath
        ) as? FavorCell else { return UICollectionViewCell() }
        // cell.reactor = reactor
        return cell
      case .anniversary:
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: AnniversaryCell.reuseIdentifier,
          for: indexPath
        ) as? AnniversaryCell else { return UICollectionViewCell() }
        // cell.reactor = reactor
        return cell
      }
    }
    , configureSupplementaryView: { _, _, _, _ in
      return MyPageHeaderView()
    }
  )
  
  // MARK: - UI Components
  
  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: self.view.bounds,
      collectionViewLayout: self.setupCollectionViewLayout()
    )
    collectionView.register(
      GiftCountCell.self,
      forCellWithReuseIdentifier: GiftCountCell.reuseIdentifier
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
    collectionView.backgroundColor = .clear
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
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
      .do(onNext: {
        print("⬆️ Section: \($0)")
      })
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
      make.top.equalTo(self.view.safeAreaLayoutGuide)
      make.leading.trailing.equalTo(self.view.layoutMarginsGuide)
      make.bottom.equalToSuperview()
    }
  }
  
  private func setupCollectionView() {
    Observable.just([])
      .bind(to: self.collectionView.rx.items(dataSource: self.dataSource))
      .disposed(by: self.disposeBag)
  }
}

// MARK: - CollectionView

private extension MyPageViewController {
  func setupCollectionViewLayout() -> UICollectionViewCompositionalLayout {
    return .init(sectionProvider: { [weak self] sectionIndex, _ in
      guard
        let sectionType = self?.dataSource[sectionIndex]
      else { fatalError("Fatal error occured while setting up section datas.") }
      return self?.createCollectionViewLayout(sectionType: sectionType)
    })
  }
  
  func createCollectionViewLayout(
    sectionType: MyPageSection
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
    
    return section
  }
}
