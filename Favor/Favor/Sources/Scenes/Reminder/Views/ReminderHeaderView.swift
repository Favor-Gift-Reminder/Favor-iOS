//
//  ReminderHeaderView.swift
//  Favor
//
//  Created by 이창준 on 2023/03/30.
//

import UIKit

import FavorKit
import Reusable

final class ReminderHeaderView: UICollectionReusableView, Reusable {

  // MARK: - Constants

  // MARK: - Properties

  // MARK: - UI Components

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 22)
    label.textAlignment = .left
    label.text = "헤더"
    return label
  }()

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  func updateTitle(_ title: String) {
    self.titleLabel.text = title
  }

  // MARK: - UI Setups

}

extension ReminderHeaderView: BaseView {
  func setupStyles() {
    //
  }

  func setupLayouts() {
    self.addSubview(self.titleLabel)
  }

  func setupConstraints() {
    self.titleLabel.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview()
      make.centerY.equalToSuperview()
    }
  }
}
