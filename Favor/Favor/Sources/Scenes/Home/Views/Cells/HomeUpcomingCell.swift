//
//  HomeUpcomingCell.swift
//  Favor
//
//  Created by 이창준 on 2023/01/31.
//

import UIKit

import FavorKit
import SnapKit

final class HomeUpcomingCell: BaseCardCell {
  
  // MARK: - Properties
  
  // MARK: - UI Components

  private let toggleSwitch = FavorSwitch()

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

  // MARK: - Functions

  public func bind(with reminder: Reminder) {
    self.cardCellType = .reminder
    self.title = reminder.title
    self.subtitle = reminder.date.toDday()
  }
}
