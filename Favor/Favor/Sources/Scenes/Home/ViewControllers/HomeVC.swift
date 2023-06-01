//
//  HomeVC.swift
//  Favor
//
//  Created by 이창준 on 2022/12/30.
//

import UIKit

import Composer
import FavorKit
import ReactorKit
import Reusable
import RxCocoa
import SnapKit

final class HomeViewController: BaseViewController, View {
  typealias HomeDataSource = UICollectionViewDiffableDataSource<HomeSection, HomeSectionItem>
  
  // MARK: - Constants
  
  // MARK: - Properties

  private var dataSource: HomeDataSource?
  
  // MARK: - UI Components

  private let searchButton = FavorBarButtonItem(.search)

  private lazy var composer: Composer<HomeSection, HomeSectionItem> = {
    let composer = Composer(collectionView: self.collectionView, dataSource: self.dataSource)
    return composer
  }()

  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewLayout()
    )

    collectionView.backgroundColor = .clear
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    collectionView.contentInset = UIEdgeInsets(top: 16, left: .zero, bottom: 16, right: .zero)
    return collectionView
  }()
  
  // MARK: - Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.setupDataSource()
    self.composer.compose()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.setupNavigationBar()
  }
  
  // MARK: - Setup
  
  override func setupLayouts() {
    self.view.addSubview(self.collectionView)
  }
  
  override func setupConstraints() {
    self.collectionView.snp.makeConstraints { make in
      make.directionalVerticalEdges.equalTo(self.view.safeAreaLayoutGuide)
      make.directionalHorizontalEdges.equalToSuperview()
    }
  }

  // MARK: - Binding
  
  func bind(reactor: HomeViewReactor) {
    // Action
    Observable.combineLatest(self.rx.viewDidLoad, self.rx.viewWillAppear)
      .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)
      .map { _ in Reactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.searchButton.rx.tap
      .map { Reactor.Action.searchButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.collectionView.rx.itemSelected
      .map { indexPath in
        guard let dataSource = self.dataSource else { fatalError() }
        let currentSnapshot = dataSource.snapshot()
        let sections = currentSnapshot.sectionIdentifiers
        let items = currentSnapshot.itemIdentifiers(inSection: sections[indexPath.section])
        let selectedItem = items[indexPath.item]
        return Reactor.Action.itemSelected(selectedItem)
      }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // 스크롤 로드
    let maxTimelines = reactor.state
      .flatMap { state -> Observable<(current: Int, unit: Int)> in
        return .just(state.maxTimelineItems)
      }
    let willDisplayCell = self.collectionView.rx.willDisplayCell
    Observable.combineLatest(maxTimelines, willDisplayCell)
    .compactMap { maxTimelines, willDisplayCell in
      return (
        maxItems: maxTimelines.current, unit: maxTimelines.unit,
        cell: willDisplayCell.cell, indexPath: willDisplayCell.at
      )
    }
    .observe(on: MainScheduler.asyncInstance)
    .asDriver(onErrorRecover: { _ in return .empty()})
    .drive(with: self, onNext: { owner, data in
      let (maxItems, unit, _, indexPath) = (data.maxItems, data.unit, data.cell, data.indexPath)

      guard
        indexPath.item > 0,
        (indexPath.item + 1 - 4) / unit == maxItems / unit - 1,
        let reactor = owner.reactor
      else { return }

      if indexPath.item >= maxItems - 4 {
        reactor.action.onNext(.updateMaxTimelineItems((current: maxItems + unit, unit: unit)))
        reactor.action.onNext(.timelineNeedsLoaded(true))
      }
    })
    .disposed(by: self.disposeBag)
    
    // State
    let sectonData = reactor.state
      .flatMap { state -> Observable<(sections: [HomeSection], items: [[HomeSectionItem]])> in
        return .just((sections: state.sections, items: state.items))
      }
    let viewDidLoad = self.rx.viewDidLoad
    Observable.combineLatest(sectonData, viewDidLoad)
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, data in
        let sectionData = data.0
        guard let dataSource = owner.dataSource else { return }
        var snapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeSectionItem>()
        snapshot.appendSections(sectionData.sections)
        sectionData.items.enumerated().forEach { idx, item in
          snapshot.appendItems(item, toSection: sectionData.sections[idx])
        }
        
        DispatchQueue.main.async {
          dataSource.apply(snapshot)
        }
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.isLoading }
      .bind(to: self.rx.isLoading)
      .disposed(by: self.disposeBag)
  }
}

// MARK: - Privates

private extension HomeViewController {
  func setupNavigationBar() {
    self.navigationItem.setRightBarButton(self.searchButton, animated: false)
    self.navigationController?.setNavigationBarHidden(false, animated: false)
  }

  func setupDataSource() {
    let emptyCellRegistrationg = UICollectionView.CellRegistration
      <FavorEmptyCell, HomeSectionItem> { [weak self] cell, _, item in
        guard let self = self else { return }
        if case let HomeSectionItem.upcoming(.empty(image, title)) = item {
          cell.bindEmptyData(image: image, text: title)
        } else if case let HomeSectionItem.timeline(.empty(image, title)) = item {
          cell.bindEmptyData(image: image, text: title)
        }
    }

    let upcomingCellRegistration = UICollectionView.CellRegistration
      <HomeUpcomingCell, HomeSectionItem> { [weak self] cell, _, item in
        guard
          let self = self,
          case let HomeSectionItem.upcoming(.reminder(reminder)) = item
        else { return }
        cell.bind(with: reminder)
    }

    let timelineCellRegistration = UICollectionView.CellRegistration
      <HomeTimelineCell, HomeSectionItem> { [weak self] cell, indexPath, item in
        guard
          let self = self,
          case let HomeSectionItem.timeline(.gift(gift)) = item
        else { return }
        cell.bind(with: gift)
    }

    self.dataSource = HomeDataSource(
      collectionView: self.collectionView,
      cellProvider: { collectionView, indexPath, item in
        switch item {
        case .upcoming(let upcomingData):
          switch upcomingData {
          case .empty:
            return collectionView.dequeueConfiguredReusableCell(
              using: emptyCellRegistrationg, for: indexPath, item: item)
          case .reminder:
            return collectionView.dequeueConfiguredReusableCell(
              using: upcomingCellRegistration, for: indexPath, item: item)
          }
        case .timeline(let giftData):
          switch giftData {
          case .empty:
            return collectionView.dequeueConfiguredReusableCell(
              using: emptyCellRegistrationg, for: indexPath, item: item)
          case .gift:
            return collectionView.dequeueConfiguredReusableCell(
              using: timelineCellRegistration, for: indexPath, item: item)
          }
        }
      })

    let headerRegistration = UICollectionView.SupplementaryRegistration<HomeHeaderView>(
      elementKind: UICollectionView.elementKindSectionHeader
    ) { [weak self] header, _, indexPath in
      guard
        let self = self,
        let dataSource = self.dataSource
      else { return }
      header.delegate = self
      let currentSnapshot = dataSource.snapshot()
      header.section = currentSnapshot.sectionIdentifiers[indexPath.section]
    }

    let footerRegistration = UICollectionView.SupplementaryRegistration<FavorLoadingFooterView>(
      elementKind: UICollectionView.elementKindSectionFooter
    ) { [weak self] footer, _, indexPath in
      guard let self = self else { return }
    }

    self.dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
      guard self != nil else { return UICollectionReusableView() }
      switch kind {
      case UICollectionView.elementKindSectionHeader:
        return collectionView.dequeueConfiguredReusableSupplementary(
          using: headerRegistration, for: indexPath)
      case UICollectionView.elementKindSectionFooter:
        return collectionView.dequeueConfiguredReusableSupplementary(
          using: footerRegistration, for: indexPath)
      default:
        return UICollectionReusableView()
      }
    }
  }
}

// MARK: - HomeHeaderView

extension HomeViewController: HomeHeaderViewDelegate {
  func rightButtonDidTap(from view: HomeHeaderView, for section: HomeSection) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.rightButtonDidTap(section))
  }

  func filterDidSelected(from view: HomeHeaderView, to filterType: GiftFilterType) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.filterButtonDidSelected(filterType))
  }
}
