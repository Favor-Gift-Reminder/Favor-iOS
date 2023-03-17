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
import SnapKit

final class HomeViewController: BaseViewController, View {
  typealias Reactor = HomeViewReactor
  typealias HomeDataSource = RxCollectionViewSectionedReloadDataSource<HomeSection.HomeSectionModel>
  
  // MARK: - Constants
  
  // MARK: - Properties

  private lazy var dataSource = HomeDataSource(
    configureCell: { _, collectionView, indexPath, item in
      switch item {
      case let .empty(image, text): // Empty Cell
        let cell = collectionView.dequeueReusableCell(for: indexPath) as FavorEmptyCell
        cell.bindEmptyData(image: image, text: text)
        return cell
      case .upcoming(let reactor): // 다가오는 이벤트
        let cell = collectionView.dequeueReusableCell(for: indexPath) as UpcomingCell
        cell.reactor = reactor
        return cell
      case .timeline(let reactor): // 타임라인
        let cell = collectionView.dequeueReusableCell(for: indexPath) as TimelineCell
        cell.reactor = reactor
        return cell
      }
    },
    configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
      let header = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        for: indexPath) as HeaderView
      let sectionItem = dataSource[indexPath.section]
      header.reactor = HeaderViewReactor(section: sectionItem.model)
      header.rx.rightButtonDidTap
        .map { Reactor.Action.rightButtonDidTap(sectionItem.identity) }
        .bind(to: self.reactor!.action)
        .disposed(by: self.disposeBag)
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
    collectionView.register(cellType: FavorEmptyCell.self)
    collectionView.register(cellType: UpcomingCell.self)
    collectionView.register(cellType: TimelineCell.self)
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

  // MARK: - Binding
  
  override func bind() {
    Observable.just([])
      .bind(to: self.collectionView.rx.items(dataSource: self.dataSource))
      .disposed(by: self.disposeBag)
  }
  
  func bind(reactor: HomeViewReactor) {
    // Action
    self.rx.viewDidLoad
      .map { Reactor.Action.viewDidLoad }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.searchButton.rx.tap
      .do(onNext: { // TODO: 토스트 메시지 테스트용 코드 삭제
        self.presentToast("🍞 토스트 메시지 🍞", duration: .short)
      })
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
    reactor.state.map { [$0.upcomingSection, $0.timelineSection] }
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
  }
  
  func setupCollectionViewLayout() -> UICollectionViewCompositionalLayout {
    return UICollectionViewCompositionalLayout(sectionProvider: { [weak self] sectionIndex, _ in
      guard
        let sectionType = self?.dataSource[sectionIndex].model,
        // dataSource는 절대로 비어있지 않습니다. 실제 값이 비어있더라도 reactor에서 .empty 값을 대체하여 넣어줍니다.
        let sectionFirstItem = self?.dataSource[sectionIndex].items.first
      else { fatalError("Fatal error occured while setting up section datas.") }

      var isSectionEmpty: Bool = false
      if case HomeSection.HomeSectionItem.empty(_, _) = sectionFirstItem {
        isSectionEmpty = true
      }
      return self?.createCollectionViewLayout(sectionType: sectionType, isEmpty: isSectionEmpty)
    })
  }

  func createCollectionViewLayout(
    sectionType: HomeSectionType,
    isEmpty: Bool
  ) -> NSCollectionLayoutSection {
    // 이대로는 그냥 무조건 첫 아이템이 Empty 자리에 박힌다.
    // 비어있느냐 아니냐에 따라 구분을 두어야할듯
    // item 타입이 .empty인지 구분해서 emptyItem을 넣을지 말지 선택?
    let emptyItem = NSCollectionLayoutItem(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(FavorEmptyCell.totalHeight))
    )

    let (cellSize, columns, spacing) = self.getSectionSize(sectionType: sectionType)
    let item = NSCollectionLayoutItem(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: cellSize.widthDimension,
        heightDimension: cellSize.heightDimension)
    )

    let contentsGroup = UICollectionViewCompositionalLayout.group(
      direction: .horizontal,
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: cellSize.heightDimension),
      subItem: item,
      count: columns
    )
    contentsGroup.interItemSpacing = .fixed(spacing)

    // CollectionView에 출력될 아이템 (비어있다면 emptyItem, 컨텐츠가 있다면 contentsGroup)
    let activeItems: [NSCollectionLayoutItem] = isEmpty ? [emptyItem] : [contentsGroup]
    let group = NSCollectionLayoutGroup.vertical(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(50) // Auto Height
      ),
      subitems: activeItems
    )

    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = spacing

    // header
    section.boundarySupplementaryItems = [self.createHeader(sectionType: sectionType)]

    return section
  }

  /// Section Type에 따라 지정된 Layout 값들을 불러오는 메서드
  func getSectionSize(sectionType: HomeSectionType) -> (NSCollectionLayoutSize, Int, CGFloat) {
    return (sectionType.cellSize, sectionType.columns, sectionType.spacing)
  }
  
  // 헤더 생성
  func createHeader(sectionType: HomeSectionType) -> NSCollectionLayoutBoundarySupplementaryItem {
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
