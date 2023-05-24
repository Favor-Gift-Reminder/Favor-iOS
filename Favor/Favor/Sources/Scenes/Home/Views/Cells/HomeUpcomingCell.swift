//
//  HomeUpcomingCell.swift
//  Favor
//
//  Created by 이창준 on 2023/01/31.
//

import UIKit

import FavorKit
import Reusable
import SnapKit

final class HomeUpcomingCell: BaseCardCell, Reusable {
  
  // MARK: - Properties
  
  // MARK: - UI Components

  private let toggleSwitch = FavorSwitch()

  // MARK: - Functions

  // MARK: - UI Setup

  override func setupLayouts() {
    super.setupLayouts()

    self.addSubview(self.toggleSwitch)
  }

  override func setupConstraints() {
    super.setupConstraints()

    self.toggleSwitch.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(16)
      make.centerY.equalToSuperview()
      make.width.equalTo(40)
      make.height.equalTo(24)
    }
  }
}
