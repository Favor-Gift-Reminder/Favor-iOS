//
//  EditFriendCell.swift
//  Favor
//
//  Created by 이창준 on 2023/05/11.
//

import UIKit

import FavorKit
import Reusable
import SnapKit

final class EditFriendCell: BaseFriendCell, Reusable {

  // MARK: - Constants

  private enum Metric {
    static let rightImageViewSize = 28.0
  }

  // MARK: - Properties

  // MARK: - UI Components

  public let deleteButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.image = .favorIcon(.remove)?
      .withRenderingMode(.alwaysTemplate)
      .resize(newWidth: 16)
      .withTintColor(.favorColor(.line2))

    let button = UIButton(configuration: config)
    button.contentMode = .center
    button.isUserInteractionEnabled = true
    return button
  }()

  // MARK: - UI Setups

  override func setupLayouts() {
    super.setupLayouts()

    self.containerView.addSubview(self.deleteButton)
  }

  override func setupConstraints() {
    super.setupConstraints()

    self.deleteButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview()
      make.centerY.equalToSuperview()
      make.width.height.equalTo(Metric.rightImageViewSize)
    }
  }
}
