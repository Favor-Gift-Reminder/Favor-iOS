//
//  HomeVC.swift
//  Favor
//
//  Created by 이창준 on 2022/12/30.
//

import UIKit

import ReactorKit
import RxDataSources
import RxSwift
import SnapKit

final class HomeViewController: BaseViewController, View {
  typealias HomeDataSource = RxCollectionViewSectionedReloadDataSource<HomeSection>
  
  // MARK: - Constants
  
  private let sectionHeaderElementKind = "SectionHeader"
	
	// MARK: - Properties
  
  let dataSource: HomeDataSource = HomeDataSource(
    configureCell: { _, collectionView, indexPath, items -> UICollectionViewCell in
      switch items {
      case .upcomingCell(let reactor):
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: UpcomingCell.reuseIdentifier,
          for: indexPath
        ) as? UpcomingCell else { return UICollectionViewCell() }
        cell.reactor = reactor
        return cell
      case .timelineCell(let reactor):
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: TimelineCell.reuseIdentifier,
          for: indexPath
        ) as? TimelineCell else { return UICollectionViewCell() }
        cell.reactor = reactor
        return cell
      }
    },
    configureSupplementaryView: { _, collectionView, kind, indexPath in
      guard let header = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: HeaderView.reuseIdentifier,
        for: indexPath
      ) as? HeaderView else { return UICollectionReusableView() }
      header.reactor = HeaderReactor(section: HomeSectionType(rawValue: indexPath.section))
      return header
    }
  )
  
  // MARK: - UI Components
  
  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: self.view.bounds,
      collectionViewLayout: self.setupCollectionView()
    )
    collectionView.register(
      UpcomingCell.self,
      forCellWithReuseIdentifier: UpcomingCell.reuseIdentifier
    )
    collectionView.register(
      TimelineCell.self,
      forCellWithReuseIdentifier: TimelineCell.reuseIdentifier
    )
    collectionView.register(
      HeaderView.self,
      forSupplementaryViewOfKind: self.sectionHeaderElementKind,
      withReuseIdentifier: HeaderView.reuseIdentifier
    )
    collectionView.backgroundColor = .clear
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    return collectionView
  }()
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let test = [HomeSection.upcoming([]), HomeSection.timeline([])]
    Observable.just(test)
      .bind(to: self.collectionView.rx.items(dataSource: self.dataSource))
      .disposed(by: self.disposeBag)
  }
	
	// MARK: - Setup
  
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
	
	// MARK: - Binding
	
  func bind(reactor: HomeReactor) {
    // Action
    self.collectionView.rx.itemSelected
      .do(onNext: {
        print($0)
      })
      .map { Reactor.Action.itemSelected($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { $0.sections }
      .do(onNext: {
        print("⬆️ Section: \($0)")
      })
      .bind(to: self.collectionView.rx.items(dataSource: self.dataSource))
      .disposed(by: self.disposeBag)
  }
}

private extension HomeViewController {
  
  func setupCollectionView() -> UICollectionViewLayout {
    let layout = UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, _ in
      // section 0: 다가오는 이벤트, section 1: 타임라인
      let sectionType: HomeSectionType = HomeSectionType(rawValue: sectionIndex) ?? .upcoming
      let columns: CGFloat = sectionType == .upcoming ? 1.0 : 2.0
      let height: CGFloat = sectionType == .upcoming ? 95.0 : 165.0
      let cellSpacing: CGFloat = sectionType == .upcoming ? 10.0 : 5.0
      let headerHeight: CGFloat = sectionType == .upcoming ? 74 : 111

      // Group.horizontal(layoutSize:,subitem:,count)에서 override
      let itemSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .fractionalHeight(1.0)
      )
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
      let groupSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(height)
      )
      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: groupSize,
        subitem: item,
        count: Int(columns)
      )
      group.interItemSpacing = .fixed(cellSpacing)
      
      let section = NSCollectionLayoutSection(group: group)
      section.interGroupSpacing = cellSpacing
      
      let headerFooterSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(headerHeight)
      )
      let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: headerFooterSize,
        elementKind: self.sectionHeaderElementKind,
        alignment: .top
      )
      section.boundarySupplementaryItems = [sectionHeader]
      
      return section
    })
    
    return layout
  }
  
}
