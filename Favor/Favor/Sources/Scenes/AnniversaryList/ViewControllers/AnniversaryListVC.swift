//
//  AnniversaryListVC.swift
//  Favor
//
//  Created by 이창준 on 2023/05/16.
//

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
      cellProvider: { collectionView, indexPath, item in
        switch item {
        case .anniversary(let reactor):
          let cell = collectionView.dequeueReusableCell(for: indexPath) as AnniversaryListCell
          cell.reactor = reactor
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
        ) as FavorSectionHeaderView
        return header
      default:
        return UICollectionReusableView()
      }
    }
    return dataSource
  }()

  private lazy var adapter: Adapter<AnniversaryListSection, AnniversaryListSectionItem> = {
    let adapter = Adapter(collectionView: self.collectionView, dataSource: self.dataSource)
    adapter.configuration = Adapter.Configuration(scrollDirection: .vertical)
    return adapter
  }()

  // MARK: - UI Components

  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: self.view.bounds,
      collectionViewLayout: UICollectionViewLayout()
    )

    // Register
    collectionView.register(cellType: AnniversaryListCell.self)
    collectionView.register(
      supplementaryViewType: FavorSectionHeaderView.self,
      ofKind: UICollectionView.elementKindSectionHeader
    )

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

    // State
    reactor.state.map { $0.viewState }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, state in
        owner.convert(to: state)
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { (sections: $0.sections, items: $0.items) }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, sectionData in
        var snapshot: NSDiffableDataSourceSnapshot<AnniversaryListSection, AnniversaryListSectionItem> = .init()
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
      print("List")
    case .edit:
      print("Edit")
    }
  }
}
