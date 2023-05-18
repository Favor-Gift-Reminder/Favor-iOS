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

final class EditAnniversaryListViewController: BaseAnniversaryListViewController, View {

  // MARK: - Constants

  // MARK: - Properties

  // MARK: - UI Components

  // MARK: - Life Cycle

  // MARK: - Binding

  func bind(reactor: EditAnniversaryListViewReactor) {
    // Action
    self.rx.viewDidLoad
      .map { Reactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { (section: $0.section, items: $0.items) }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, sectionData in
        var snapshot = NSDiffableDataSourceSnapshot<AnniversaryListSection, AnniversaryListSectionItem>()
        snapshot.appendSections([sectionData.section])
        snapshot.appendItems(sectionData.items, toSection: sectionData.section)
        owner.dataSource.apply(snapshot)
        owner.collectionView.collectionViewLayout.invalidateLayout()
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  override func handleAnniversaryData(_ anniversary: Anniversary) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.editButtonDidTap(anniversary))
  }

  // MARK: - UI Setups

}
