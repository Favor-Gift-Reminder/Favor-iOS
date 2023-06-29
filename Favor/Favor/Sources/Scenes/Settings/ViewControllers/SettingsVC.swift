//
//  SettingsVC.swift
//  Favor
//
//  Created by 이창준 on 6/28/23.
//

import UIKit

import Composer
import FavorKit
import ReactorKit
import SnapKit

public final class SettingsViewController: BaseViewController, View {
  typealias SettingsDataSource = UICollectionViewDiffableDataSource<SettingsSection, SettingsSectionItem>

  // MARK: - Constants

  // MARK: - Properties

  private var dataSource: SettingsDataSource?

  private lazy var composer: Composer<SettingsSection, SettingsSectionItem> = {
    let composer = Composer(collectionView: self.collectionView, dataSource: self.dataSource)
    composer.configuration = Composer.Configuration(
      scrollDirection: .vertical,
      sectionSpacing: 32.0
    )
    return composer
  }()

  // MARK: - UI Components

  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewLayout()
    )

    collectionView.contentInset = UIEdgeInsets(top: 32.0, left: .zero, bottom: 32.0, right: .zero)
    collectionView.showsHorizontalScrollIndicator = false
    return collectionView
  }()

  // MARK: - Life Cycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.setupDataSource()
    self.composer.compose()
  }

  // MARK: - Binding

  public func bind(reactor: SettingsViewReactor) {
    // Action
    self.rx.viewDidLoad
      .map { Reactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.collectionView.rx.itemSelected
      .map { indexPath -> Reactor.Action in
        guard let item = self.dataSource?.itemIdentifier(for: indexPath) else { return .doNothing }
        return .itemSelected(item)
      }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { $0.items }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self, onNext: { owner, items in
        var snapshot = NSDiffableDataSourceSnapshot<SettingsSection, SettingsSectionItem>()
        snapshot.appendSections([.userInfo, .notification, .appInfo])
        items.forEach { item in
          switch item {
          case
            let .selectable(section, _, _, _),
            let .switchable(section, _, _),
            let .info(section, _, _, _):
            snapshot.appendItems([item], toSection: section)
          }
        }

        DispatchQueue.main.async {
          owner.dataSource?.apply(snapshot)
        }
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  // MARK: - UI Setups

  public override func setupLayouts() {
    self.view.addSubview(self.collectionView)
  }

  public override func setupConstraints() {
    self.collectionView.snp.makeConstraints { make in
      make.directionalVerticalEdges.equalTo(self.view.safeAreaLayoutGuide)
      make.directionalHorizontalEdges.equalToSuperview()
    }
  }
}

// MARK: - Privates

private extension SettingsViewController {
  func setupDataSource() {
    let cellRegistration = UICollectionView.CellRegistration
    <SettingsCell, SettingsSectionItem> { [weak self] cell, _, item in
      guard self != nil else { return }
      cell.bind(with: item)
    }

    self.dataSource = SettingsDataSource(
      collectionView: self.collectionView,
      cellProvider: { [weak self] collectionView, indexPath, item in
        guard self != nil else { return UICollectionViewCell() }
        return collectionView.dequeueConfiguredReusableCell(
          using: cellRegistration, for: indexPath, item: item)
      }
    )

    let headerRegistration: UICollectionView.SupplementaryRegistration<SettingsHeaderView> =
    UICollectionView.SupplementaryRegistration(
      elementKind: UICollectionView.elementKindSectionHeader
    ) { [weak self] header, _, indexPath in
      guard
        let self = self,
        let sections = self.dataSource?.snapshot().sectionIdentifiers
      else { return }
      header.bind(with: sections[indexPath.section].header)
    }

    let footerRegistration: UICollectionView.SupplementaryRegistration<FavorSectionFooterView> =
    UICollectionView.SupplementaryRegistration(
      elementKind: UICollectionView.elementKindSectionFooter
    ) { [weak self] _, _, _ in
      guard self != nil else { return }
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
