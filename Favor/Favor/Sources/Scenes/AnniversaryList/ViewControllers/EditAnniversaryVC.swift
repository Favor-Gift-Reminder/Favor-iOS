//
//  EditAnniversaryVC.swift
//  Favor
//
//  Created by 이창준 on 2023/05/18.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import SnapKit

final class EditAnniversaryViewController: BaseViewController, View {

  // MARK: - Constants

  // MARK: - Properties

  // MARK: - UI Components

  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewLayout()
    )

    collectionView.register(
      supplementaryViewType: FavorSectionHeaderView.self,
      ofKind: UICollectionView.elementKindSectionHeader
    )

    return collectionView
  }()

  // MARK: - Life Cycle

  // MARK: - Binding

  func bind(reactor: EditAnniversaryViewReactor) {
    // Action

    // State

  }

  // MARK: - Functions

  // MARK: - UI Setups

}
