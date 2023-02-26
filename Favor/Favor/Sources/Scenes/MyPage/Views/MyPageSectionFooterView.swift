//
//  MyPageSectionFooterView.swift
//  Favor
//
//  Created by 이창준 on 2023/02/24.
//

import UIKit

import Reusable
import SnapKit

final class MyPageSectionFooterView: UICollectionReusableView, Reusable {

  // MARK: - UI Components

  private lazy var dividerView: UIView = {
    let view = UIView()
    view.backgroundColor = .favorColor(.divider)
    return view
  }()

  private lazy var descriptionLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .left
    label.font = .favorFont(.regular, size: 12)
    label.textColor = .favorColor(.explain)
    label.text = "설명"
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

  func setupDescription(_ text: String) {
    self.descriptionLabel.text = text
  }
}

extension MyPageSectionFooterView: BaseView {
  func setupStyles() {
    self.layoutMargins = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
  }

  func setupLayouts() {
    [
      self.dividerView,
      self.descriptionLabel
    ].forEach {
      self.addSubview($0)
    }
  }

  func setupConstraints() {
    self.dividerView.snp.makeConstraints { make in
      make.top.directionalHorizontalEdges.equalTo(self.layoutMarginsGuide)
      make.height.equalTo(1)
    }

    self.descriptionLabel.snp.makeConstraints { make in
      make.bottom.directionalHorizontalEdges.equalToSuperview()
    }
  }
}
