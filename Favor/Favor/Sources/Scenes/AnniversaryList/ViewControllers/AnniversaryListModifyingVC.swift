//
//  EditAnniversaryListVC.swift
//  Favor
//
//  Created by 이창준 on 2023/05/17.
//

import UIKit

import FavorKit
import ReactorKit
import SnapKit

final class AnniversaryListModifyingViewController: BaseAnniversaryListViewController, View {

  // MARK: - Constants

  // MARK: - Properties

  // MARK: - UI Components

  // MARK: - Life Cycle
  
  // MARK: - Binding

  func bind(reactor: AnniversaryListModifyingViewReactor) {
    // Action
    Observable.combineLatest(self.rx.viewDidLoad, self.rx.viewWillAppear)
      .map { _ in Reactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { (section: $0.section, items: $0.items) }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, sectionData in
        var snapshot = NSDiffableDataSourceSnapshot<AnniversaryListSection, AnniversaryListSectionItem>()
        snapshot.appendSections([sectionData.section])
        snapshot.reloadSections([sectionData.section])
        snapshot.appendItems(sectionData.items, toSection: sectionData.section)
        owner.dataSource.apply(snapshot, animatingDifferences: true)
        owner.collectionView.collectionViewLayout.invalidateLayout()
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  override func viewNeedsLoaded(with toast: ToastMessage? = nil) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.viewNeedsLoaded)
  }

  override func transfer(_ model: (any CellModel)?, from cell: UICollectionViewCell) {
    guard
      let model = model as? AnniversaryListCellModel,
      let reactor = self.reactor
    else { return }
    reactor.action.onNext(.editButtonDidTap(model.item))
  }
}
