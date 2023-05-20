//
//  BaseAnniversaryListVC.swift
//  Favor
//
//  Created by 이창준 on 2023/05/17.
//

import UIKit

import FavorKit

public class BaseAnniversaryListViewController: BaseViewController {
  public typealias AnniversaryListDataSource = UICollectionViewDiffableDataSource<AnniversaryListSection, AnniversaryListSectionItem>

  // MARK: - Properties
  
  public lazy var dataSource: AnniversaryListDataSource = {
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
          cell.cellType = .anniversary

          cell.rx.rightButtonDidTap
            .asDriver(onErrorRecover: { _ in return .empty()})
            .drive(with: cell, onNext: { _, _ in
              guard let self = self else { return }
              self.handleAnniversaryData(reactor.currentState.anniversary)
            })
            .disposed(by: cell.disposeBag)

          return cell
        }
      }
    )
    dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
      guard let self = self else { return UICollectionReusableView() }
      switch kind {
      case UICollectionView.elementKindSectionHeader:
        let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          for: indexPath
        ) as FavorSectionHeaderView
        let currentSnapshot = self.dataSource.snapshot()
        let section = currentSnapshot.sectionIdentifiers[indexPath.section]
        let numberOfItems = currentSnapshot.numberOfItems(inSection: section)
        let title = indexPath.section == .zero ? "고정됨" : "전체"
        header.bind(title: title, digit: numberOfItems)
        return header
      default:
        return UICollectionReusableView()
      }
    }
    return dataSource
  }()

  // MARK: - UI Components

  public lazy var adapter: Adapter<AnniversaryListSection, AnniversaryListSectionItem> = {
    let adapter = Adapter(collectionView: self.collectionView, dataSource: self.dataSource)
    adapter.configuration = Adapter.Configuration(
      scrollDirection: .vertical,
      sectionSpacing: 40
    )
    return adapter
  }()

  public lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewLayout()
    )

    // Register
    collectionView.register(cellType: FavorEmptyCell.self)
    collectionView.register(cellType: AnniversaryListCell.self)
    collectionView.register(
      supplementaryViewType: FavorSectionHeaderView.self,
      ofKind: UICollectionView.elementKindSectionHeader
    )

    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    collectionView.contentInset = UIEdgeInsets(top: 32, left: .zero, bottom: .zero, right: .zero)
    collectionView.contentInsetAdjustmentBehavior = .never
    return collectionView
  }()

  // MARK: - Life Cycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.adapter.adapt()
  }

  // MARK: - Functions

  public func handleAnniversaryData(_ anniversary: Anniversary) { }

  // MARK: - UI Setups

  public override func setupLayouts() {
    self.view.addSubview(self.collectionView)
  }

  public override func setupConstraints() {
    self.collectionView.snp.makeConstraints { make in
      make.directionalVerticalEdges.equalTo(self.view.safeAreaLayoutGuide)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }
  }
}
