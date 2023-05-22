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

final class AnniversaryListViewController: BaseAnniversaryListViewController, View {

  // MARK: - Constants

  // MARK: - Properties

  // MARK: - UI Components

  private let editButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.background.backgroundColor = .clear
    config.baseForegroundColor = .favorColor(.icon)
    config.updateAttributedTitle("편집", font: .favorFont(.bold, size: 18))

    let button = UIButton(configuration: config)
    return button
  }()

  // MARK: - Life Cycle

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.setupNavigationBar()
  }

  // MARK: - Binding

  func bind(reactor: AnniversaryListViewReactor) {
    // Action
    self.rx.viewDidLoad
      .map { Reactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.editButton.rx.tap
      .map { Reactor.Action.editButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { (sections: $0.sections, items: $0.items) }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, sectionData in
        // initial Snapshot과 final Snapshot 생성
        let initialSnapshot = owner.dataSource.snapshot()
        var finalSnapshot = NSDiffableDataSourceSnapshot<AnniversaryListSection, AnniversaryListSectionItem>()
        finalSnapshot.appendSections(sectionData.sections)
        if sectionData.sections.contains(.pinned) {
          finalSnapshot.reloadSections([.pinned])
        }
        sectionData.items.enumerated().forEach { idx, item in
          finalSnapshot.appendItems(item, toSection: sectionData.sections[idx])
        }

        // 고정된 Section이 보일때만 animate
        let visibleSections: [AnniversaryListSection] = owner.collectionView.indexPathsForVisibleItems
          .compactMap { owner.dataSource.sectionIdentifier(for: $0.section) }
        let isPinnedSectionVisibleBefore = !initialSnapshot.sectionIdentifiers.contains(.pinned)
        DispatchQueue.main.async {
          owner.dataSource.apply(
            finalSnapshot,
            animatingDifferences: visibleSections.contains(.pinned) || isPinnedSectionVisibleBefore
          )
          owner.collectionView.collectionViewLayout.invalidateLayout()
        }
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  override func transfer(_ model: (any CellModel)?, from cell: UICollectionViewCell) {
    guard
      let model = model as? AnniversaryListCellModel,
      let reactor = self.reactor
    else { return }
    reactor.action.onNext(.pinButtonDidTap(model.item))
  }

  // MARK: - UI Setups

}

// MARK: - Privates

private extension AnniversaryListViewController {
  func setupNavigationBar() {
    self.navigationItem.setRightBarButton(self.editButton.toBarButtonItem(), animated: false)
  }
}
