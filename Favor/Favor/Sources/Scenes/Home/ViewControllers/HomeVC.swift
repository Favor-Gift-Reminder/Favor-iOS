//
//  HomeVC.swift
//  Favor
//
//  Created by 이창준 on 2022/12/30.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import RxCocoa
import RxDataSources
import RxSwift
import SnapKit

final class HomeViewController: BaseViewController, View {
  typealias HomeDataSource = RxCollectionViewSectionedReloadDataSource<HomeSection>
  
  // MARK: - Constants
  
  // MARK: - Properties
  
  let dataSource: HomeDataSource = HomeDataSource(
    configureCell: { _, collectionView, indexPath, item -> UICollectionViewCell in
      switch item {
      // Empty
      case .emptyCell(let text, let image):
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: FavorEmptyCell.reuseIdentifier,
          for: indexPath
        ) as? FavorEmptyCell else { return UICollectionViewCell() }
        cell.text = text
        cell.image = image
        return cell
        
      // 다가오는 이벤트
      case .upcomingCell(let reactor):
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: UpcomingCell.reuseIdentifier,
          for: indexPath
        ) as? UpcomingCell else { return UICollectionViewCell() }
        cell.reactor = reactor
        return cell
        
      // 타임라인
      case .timelineCell(let reactor):
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: TimelineCell.reuseIdentifier,
          for: indexPath
        ) as? TimelineCell else { return UICollectionViewCell() }
        cell.reactor = reactor
        return cell
      }
    },
    configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
      guard let header = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: HeaderView.reuseIdentifier,
        for: indexPath
      ) as? HeaderView else { return UICollectionReusableView() }
      let section = dataSource[indexPath.section]
      header.reactor = HeaderViewReactor(section: section)
      return header
    }
  )
  
  // MARK: - UI Components

  private lazy var searchButton = FavorBarButtonItem(.search)
  private lazy var newGiftButton = FavorBarButtonItem(.newGift)
  
  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: self.view.bounds,
      collectionViewLayout: self.setupCollectionViewLayout()
    )

    // register
    collectionView.register(cellType: UpcomingCell.self)
    collectionView.register(cellType: TimelineCell.self)
    collectionView.register(cellType: FavorEmptyCell.self)
    collectionView.register(
      supplementaryViewType: HeaderView.self,
      ofKind: HeaderView.reuseIdentifier
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

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.setupNavigationBar()
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
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
      make.bottom.equalToSuperview()
    }
  }
  
  func setupCollectionView() {
    Observable.just([])
      .bind(to: self.collectionView.rx.items(dataSource: self.dataSource))
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Binding
  
  func bind(reactor: HomeViewReactor) {
    // Action
    self.searchButton.rx.tap
      .map { Reactor.Action.searchButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.newGiftButton.rx.tap
      .map { Reactor.Action.newGiftButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

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

// MARK: - Privates

private extension HomeViewController {
  func setupNavigationBar() {
    self.navigationItem.rightBarButtonItems = [
      self.searchButton,
      self.newGiftButton
    ]
    self.navigationController?.navigationBar.backgroundColor = .systemYellow
  }
  
  func setupCollectionViewLayout() -> UICollectionViewCompositionalLayout {
    return .init(sectionProvider: { [weak self] sectionIndex, _ in
      guard
        let sectionType = self?.dataSource[sectionIndex],
        let sectionItem = self?.dataSource[sectionIndex].items.first
      else { fatalError("Fatal error occured while setting up section datas.") }
      
      switch sectionItem {
      case .emptyCell:
        return self?.createCollectionViewLayout(sectionType: sectionType, isEmpty: true)
      default:
        return self?.createCollectionViewLayout(sectionType: sectionType)
      }
    })
  }
  
  func getSectionSize(sectionType: HomeSection) -> (NSCollectionLayoutSize, Int, CGFloat) {
    return (sectionType.cellSize, sectionType.columns, sectionType.spacing)
  }
  
  func createCollectionViewLayout(
    sectionType: HomeSection,
    isEmpty: Bool = false
  ) -> NSCollectionLayoutSection {
    let (cellSize, columns, spacing) = (isEmpty == true)
    ? (.init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(305.0)), 1, 0)
    : self.getSectionSize(sectionType: sectionType)
    
    // item
    let item = NSCollectionLayoutItem(
      layoutSize: .init(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .fractionalHeight(1.0)
      )
    )
    
    // group
    var group: NSCollectionLayoutGroup
    if #available(iOS 16.0, *) {
      group = NSCollectionLayoutGroup.horizontal(
        layoutSize: .init(
          widthDimension: cellSize.widthDimension,
          heightDimension: cellSize.heightDimension
        ),
        repeatingSubitem: item,
        count: columns
      )
    } else {
      group = NSCollectionLayoutGroup.horizontal(
        layoutSize: .init(
          widthDimension: cellSize.widthDimension,
          heightDimension: cellSize.heightDimension
        ),
        subitem: item,
        count: columns
      )
    }
    group.interItemSpacing = .fixed(spacing)
    
    // section
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = spacing
    
    // header
    section.boundarySupplementaryItems = [self.createHeader(sectionType: sectionType)]
    
    return section
  }
  
  // 헤더
  func createHeader(sectionType: HomeSection) -> NSCollectionLayoutBoundarySupplementaryItem {
    let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: .init(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: sectionType.headerHeight
      ),
      elementKind: HeaderView.reuseIdentifier,
      alignment: .top
    )
    return sectionHeader
  }
}
