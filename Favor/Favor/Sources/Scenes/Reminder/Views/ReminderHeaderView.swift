//
//  ReminderHeaderView.swift
//  Favor
//
//  Created by 이창준 on 2023/03/30.
//

import UIKit

import FavorKit
import Reusable
import SnapKit

final class ReminderHeaderView: UICollectionReusableView, Reusable {

  // MARK: - Constants

  // MARK: - Properties
  
  private var bottomConstraint: Constraint?

  // MARK: - UI Components

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 20)
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
    if title == "다가오는 기념일" {
      self.bottomConstraint?.update(inset: 20.0)
    } else {
      self.bottomConstraint?.update(inset: 52.0)
    }
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
      self.bottomConstraint = make.bottom.equalToSuperview().constraint
    }
  }
}
