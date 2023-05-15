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

  private lazy var dataSource: AnniversaryListDataSource = AnniversaryListDataSource(
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

  // MARK: - UI Components

  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: self.view.bounds,
      collectionViewLayout: UICollectionViewFlowLayout()
    )

    // Register
    collectionView.register(cellType: AnniversaryListCell.self)

    return collectionView
  }()

  // MARK: - Life Cycle

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
