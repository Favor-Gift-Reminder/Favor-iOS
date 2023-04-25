//
//  FriendVC.swift
//  Favor
//
//  Created by 이창준 on 2023/04/25.
//

import UIKit

import FavorKit
import ReactorKit
import SnapKit

final class FriendViewController: BaseViewController, View {

  // MARK: - Constants

  // MARK: - Properties

  // MARK: - UI Components

  private let editButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.background.backgroundColor = .clear
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

  func bind(reactor: FriendViewReactor) {
    // Action

    // State

  }

  // MARK: - Functions

  private func setupNavigationBar() {
    self.navigationItem.setRightBarButton(self.editButton.toBarButtonItem(), animated: false)
  }

  // MARK: - UI Setups

}
