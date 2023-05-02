//
//  EditMyPageVC.swift
//  Favor
//
//  Created by 이창준 on 2023/02/22.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import RxDataSources
import SnapKit

final class EditMyPageViewController: BaseViewController, View {
  typealias EditMyPageDataSource = RxCollectionViewSectionedReloadDataSource<EditMyPageSection>

  // MARK: - Constants

  private enum Metric {
    static let profileImageViewSize = 120.0
  }

  // MARK: - Properties

  private let dataSource: EditMyPageDataSource = EditMyPageDataSource(
    configureCell: { _, collectionView, indexPath, item in
      switch item {
      case .textField(let placeholder):
        let cell = collectionView.dequeueReusableCell(for: indexPath) as FavorTextFieldCell
        cell.bind(placeholder: placeholder)
        return cell
      case .favor(let reactor):
        let cell = collectionView.dequeueReusableCell(for: indexPath) as EditMyPagePreferenceCell
        cell.reactor = reactor
        return cell
      }
    }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
      switch kind {
      case EditMyPageCollectionHeaderView.reuseIdentifier:
        let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          for: indexPath
        ) as EditMyPageCollectionHeaderView
        return header
      case UICollectionView.elementKindSectionHeader:
        let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          for: indexPath
        ) as FavorSectionHeaderView
        let headerTitle = dataSource[indexPath.section].header
        header.updateTitle(headerTitle)
        return header
      case UICollectionView.elementKindSectionFooter:
        let footer = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          for: indexPath
        ) as FavorSectionFooterView
        footer.footerDescription = dataSource[indexPath.section].footer
        return footer
      default:
        return UICollectionReusableView()
      }
    }
  )
  private lazy var adapter = Adapter(dataSource: self.dataSource)

  // MARK: - UI Components

  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: self.adapter.build(
        scrollDirection: .vertical,
        sectionSpacing: 40,
        header: FavorCompositionalLayout.BoundaryItem.header(
          height: .absolute(400),
          contentInsets: NSDirectionalEdgeInsets(
            top: .zero,
            leading: .zero,
            bottom: 40,
            trailing: .zero
          ),
          kind: EditMyPageCollectionHeaderView.reuseIdentifier
        )
      )
    )

    // Register
    collectionView.register(cellType: FavorTextFieldCell.self)
    collectionView.register(cellType: EditMyPagePreferenceCell.self)
    collectionView.register(
      supplementaryViewType: EditMyPageCollectionHeaderView.self,
      ofKind: EditMyPageCollectionHeaderView.reuseIdentifier
    )
    collectionView.register(
      supplementaryViewType: FavorSectionHeaderView.self,
      ofKind: UICollectionView.elementKindSectionHeader
    )
    collectionView.register(
      supplementaryViewType: FavorSectionFooterView.self,
      ofKind: UICollectionView.elementKindSectionFooter
    )

    collectionView.showsVerticalScrollIndicator = false
//    collectionView.showsHorizontalScrollIndicator = false
    collectionView.contentInsetAdjustmentBehavior = .never
    return collectionView
  }()

  // MARK: - Life Cycle

  // MARK: - Binding

  override func bind() {
    guard let reactor = self.reactor else { return }

    // Action
    self.collectionView.rx.itemSelected
      .map { Reactor.Action.favorDidSelected($0.item) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { $0.sections }
      .bind(to: self.collectionView.rx.items(dataSource: self.dataSource))
      .disposed(by: self.disposeBag)
  }

  public func bind(reactor: EditMyPageViewReactor) {
    // Action
    self.rx.viewDidLoad
      .map { Reactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State

  }

  // MARK: - Functions

  // MARK: - UI Setups

  override func setupLayouts() {
    self.view.addSubview(self.collectionView)
  }

  override func setupConstraints() {
    self.collectionView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(60)
      make.directionalHorizontalEdges.equalToSuperview()
    }
  }
}

// MARK: - Privates

private extension EditMyPageViewController {
  
}
