//
//  AnniversaryListSectionHeaderView.swift
//  Favor
//
//  Created by 이창준 on 2023/05/16.
//

import UIKit

import FavorKit
import Reusable
import SnapKit

final class AnniversaryListSectionHeaderView: BaseSectionHeader, Reusable {

  // MARK: - UI Components

  private let numberOfAnniversariesLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 18)
    return label
  }()

  // MARK: - Functions

  public func bind(title: String, numberOfFriends: Int) {
    self.titleLabel.text = title
    self.numberOfAnniversariesLabel.text = "\(numberOfFriends)"
  }

  // MARK: - UI Setups

  override func setupStyles() {
    super.setupStyles()
  }

  override func setupLayouts() {
    super.setupLayouts()

    self.addSubview(self.numberOfAnniversariesLabel)
  }

  override func setupConstraints() {
    super.setupConstraints()

    self.numberOfAnniversariesLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.titleLabel.snp.trailing).offset(8)
      make.centerY.equalTo(self.titleLabel.snp.centerY)
    }
  }
}
