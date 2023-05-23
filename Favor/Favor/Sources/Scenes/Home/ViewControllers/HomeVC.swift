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
  typealias HomeDataSource = UICollectionViewDiffableDataSource<HomeSection, HomeSectionItem>
  
  // MARK: - Constants
  
  // MARK: - Properties

  private lazy var dataSource: HomeDataSource = {
    let dataSource = HomeDataSource(
      collectionView: self.collectionView,
      cellProvider: { [weak self] collectionView, indexPath, item in
        switch item {
        case .upcoming(let upcomingData):
          switch upcomingData {
          case let .empty(image, title):
            let cell = collectionView.dequeueReusableCell(for: indexPath) as FavorEmptyCell
            cell.bindEmptyData(image: image, text: title)
            return cell
          case let .reminder(reminder):
            let cell = collectionView.dequeueReusableCell(for: indexPath) as HomeUpcomingCell
            return cell
          }
        case .timeline(let giftData):
          switch giftData {
          case let .empty(image, title):
            let cell = collectionView.dequeueReusableCell(for: indexPath) as FavorEmptyCell
            cell.bindEmptyData(image: image, text: title)
            return cell
          case let .gift(gift):
            let cell = collectionView.dequeueReusableCell(for: indexPath) as HomeTimelineCell
            return cell
          }
        }
      })
    dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
      switch kind {
      case UICollectionView.elementKindSectionHeader:
        let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          for: indexPath
        ) as HomeHeaderView
        return header
      case UICollectionView.elementKindSectionFooter:
        let footer = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          for: indexPath
        ) as FavorLoadingFooterView
        return footer
      default:
        return UICollectionReusableView()
      }
    }
    return dataSource
  }()
  
  // MARK: - UI Components

  private let searchButton = FavorBarButtonItem(.search)

  private lazy var adapter: Adapter<HomeSection, HomeSectionItem> = {
    let adapter = Adapter(collectionView: self.collectionView, dataSource: self.dataSource)
    return adapter
  }()

  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewLayout()
    )

    // register
    collectionView.register(cellType: FavorEmptyCell.self)
    collectionView.register(cellType: HomeUpcomingCell.self)
    collectionView.register(cellType: HomeTimelineCell.self)
    collectionView.register(
      supplementaryViewType: HomeHeaderView.self,
      ofKind: UICollectionView.elementKindSectionHeader
    )
    collectionView.register(
      supplementaryViewType: FavorLoadingFooterView.self,
      ofKind: UICollectionView.elementKindSectionFooter
    )

    collectionView.backgroundColor = .clear
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    return collectionView
  }()
  
  // MARK: - Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.adapter.adapt()
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
  
  override func bind() {
//    self.collectionView.rx.didEndDisplayingCell
//      .asDriver(onErrorRecover: { _ in return .empty()})
//      .drive(with: self, onNext: { _, endDisplayingCell in
//        let (cell, _) = endDisplayingCell
//        guard let cell = cell as? BaseCollectionViewCell else { return }
//        cell.disposeBag = DisposeBag()
//      })
//      .disposed(by: self.disposeBag)
//
//    self.collectionView.rx.didEndDisplayingSupplementaryView
//      .asDriver(onErrorRecover: { _ in return .empty()})
//      .drive(with: self, onNext: { _, endDisplayingView in
//        let (view, _, _) = endDisplayingView
//        guard let view = view as? HomeHeaderView else { return }
//        view.disposeBag = DisposeBag()
//      })
//      .disposed(by: self.disposeBag)
    
    // State

  }
  
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
    
    // State
    reactor.state.map { (sections: $0.sections, items: $0.items) }
      .debug()
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, sectionData in
        var snapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeSectionItem>()
        snapshot.appendSections(sectionData.sections)
        sectionData.items.enumerated().forEach { idx, item in
          snapshot.appendItems(item, toSection: sectionData.sections[idx])
        }
        
        DispatchQueue.main.async {
          owner.dataSource.apply(snapshot)
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
}
