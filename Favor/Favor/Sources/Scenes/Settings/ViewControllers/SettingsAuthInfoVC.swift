//
//  SettingsAuthInfoVC.swift
//  Favor
//
//  Created by 이창준 on 6/29/23.
//

import UIKit

import Composer
import FavorKit
import ReactorKit
import SnapKit

public final class SettingsAuthInfoViewController: BaseViewController, View {
  typealias SettingsAuthInfoDataSource = UICollectionViewDiffableDataSource<SettingsAuthInfoSection, SettingsAuthInfoSectionItem>

  // MARK: - Constants

  // MARK: - Properties

  private var dataSource: SettingsAuthInfoDataSource?

  private lazy var composer: Composer<SettingsAuthInfoSection, SettingsAuthInfoSectionItem> = {
    let composer = Composer(collectionView: self.collectionView, dataSource: self.dataSource)
    return composer
  }()

  // MARK: - UI Components

  private let collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewLayout()
    )

    return collectionView
  }()

  // MARK: - Life Cycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.setupDataSource()
    self.composer.compose()
  }

  // MARK: - Binding

  public func bind(reactor: SettingsAuthInfoViewReactor) {
    // Action

    // State

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

private extension SettingsAuthInfoViewController {
  func setupDataSource() {
    let cellRegistration = UICollectionView.CellRegistration
    <UICollectionViewCell, SettingsAuthInfoSectionItem> { [weak self] cell, indexPath, item in

    }

    self.dataSource = SettingsAuthInfoDataSource(
      collectionView: self.collectionView,
      cellProvider: { [weak self] collectionView, indexPath, item in
        return collectionView.dequeueConfiguredReusableCell(
          using: cellRegistration, for: indexPath, item: item)
      }
    )
  }
}
