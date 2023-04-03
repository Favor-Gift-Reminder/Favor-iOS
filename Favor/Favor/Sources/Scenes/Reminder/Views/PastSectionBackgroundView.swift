//
//  ReminderBackgroundView.swift
//  Favor
//
//  Created by 이창준 on 2023/03/31.
//

import UIKit

import FavorKit
import Reusable
import SnapKit

final class PastSectionBackgroundView: UICollectionReusableView, Reusable {

  // MARK: - UI Components

  private lazy var roundedView = FavorRoundedTopView()

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
}

extension PastSectionBackgroundView: BaseView {
  func setupStyles() {
    self.backgroundColor = .clear
  }

  func setupLayouts() {
    self.addSubview(self.roundedView)
  }

  func setupConstraints() {
    self.roundedView.snp.makeConstraints { make in
      make.top.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(130)
    }
  }
}
