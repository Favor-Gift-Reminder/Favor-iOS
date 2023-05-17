//
//  AnniversaryListVC.swift
//  Favor
//
//  Created by 이창준 on 2023/05/16.
//

import OSLog
import UIKit

import FavorKit
import ReactorKit
import SnapKit

final class AnniversaryListViewController: BaseViewController, View {
  typealias AnniversaryListDataSource = UICollectionViewDiffableDataSource<AnniversaryListSection, AnniversaryListSectionItem>

  // MARK: - Constants

  public enum ViewState {
    case list
    case edit
  }

  // MARK: - Properties

  private lazy var dataSource: AnniversaryListDataSource = {
    let dataSource = AnniversaryListDataSource(
      collectionView: self.collectionView,
      cellProvider: { [weak self] collectionView, indexPath, item in
        switch item {
        case .empty:
          let cell = collectionView.dequeueReusableCell(for: indexPath) as FavorEmptyCell
          cell.bindEmptyData(image: nil, text: "내 기념일을 등록해보세요.")
          return cell
        case .anniversary(let reactor):
          let cell = collectionView.dequeueReusableCell(for: indexPath) as AnniversaryListCell
          cell.reactor = reactor

          cell.rx.rightButtonDidTap
            .asDriver(onErrorRecover: { _ in return .empty()})
            .drive(with: cell, onNext: { owner, _ in
              guard
                let self = self,
                let viewReeactor = self.reactor
              else { return }
              viewReeactor.action.onNext(.rightButtonDidTap(reactor.currentState.anniversary))
            })
            .disposed(by: cell.disposeBag)
          return cell
        }
      }
    )
    dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
      switch kind {
      case UICollectionView.elementKindSectionHeader:
        let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          for: indexPath
        ) as AnniversaryListSectionHeaderView
        let currentSnapshot = self.dataSource.snapshot()
        let section = currentSnapshot.sectionIdentifiers[indexPath.section]
        let numberOfItems = currentSnapshot.numberOfItems(inSection: section)
        let title = indexPath.section == .zero ? "고정됨" : "전체"
        header.bind(title: title, numberOfFriends: numberOfItems)
        return header
      default:
        return UICollectionReusableView()
      }
    }
    return dataSource
  }()

  private lazy var adapter: Adapter<AnniversaryListSection, AnniversaryListSectionItem> = {
    let adapter = Adapter(collectionView: self.collectionView, dataSource: self.dataSource)
    adapter.configuration = Adapter.Configuration(
      scrollDirection: .vertical,
      sectionSpacing: 40
    )
    return adapter
  }()

  // MARK: - UI Components

  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewLayout()
    )

    // Register
    collectionView.register(cellType: FavorEmptyCell.self)
    collectionView.register(cellType: AnniversaryListCell.self)
    collectionView.register(
      supplementaryViewType: AnniversaryListSectionHeaderView.self,
      ofKind: UICollectionView.elementKindSectionHeader
    )

    collectionView.showsHorizontalScrollIndicator = false
    collectionView.contentInset = UIEdgeInsets(top: 32, left: .zero, bottom: .zero, right: .zero)
    collectionView.contentInsetAdjustmentBehavior = .never
    return collectionView
  }()

  // MARK: - Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.adapter.adapt()
  }

  // MARK: - Binding

  func bind(reactor: AnniversaryListViewReactor) {
    // Action
    self.rx.viewDidLoad
      .map { Reactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { $0.viewState }
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, state in
        owner.convert(to: state)
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { (sections: $0.sections, items: $0.items) }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, sectionData in
        var snapshot = NSDiffableDataSourceSnapshot<AnniversaryListSection, AnniversaryListSectionItem>()
        snapshot.appendSections(sectionData.sections)
        sectionData.items.enumerated().forEach { idx, item in
          snapshot.appendItems(item, toSection: sectionData.sections[idx])
        }
        owner.dataSource.apply(snapshot, animatingDifferences: true)
        owner.collectionView.collectionViewLayout.invalidateLayout()
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  // MARK: - UI Setups

  override func setupLayouts() {
    self.view.addSubview(self.collectionView)
  }

  override func setupConstraints() {
    self.collectionView.snp.makeConstraints { make in
      make.directionalVerticalEdges.equalTo(self.view.safeAreaLayoutGuide)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }
  }
}

// MARK: - Privates

private extension AnniversaryListViewController {
  func convert(to state: ViewState) {
    switch state {
    case .list:
      os_log(.debug, "리스트,편집 보기 전환 기능이 아직 구현되지 않았습니다.: List로 변환")
    case .edit:
      os_log(.debug, "리스트,편집 보기 전환 기능이 아직 구현되지 않았습니다.: Edit로 변환")
    }
  }
}
