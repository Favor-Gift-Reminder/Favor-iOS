//
//  FavorSectionHeaderView.swift
//  Favor
//
//  Created by 이창준 on 2023/05/01.
//

import UIKit

import Reusable
import SnapKit

open class FavorSectionHeaderView: UICollectionReusableView, Reusable {

  // MARK: - UI Components

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 18)
    label.text = "섹션 헤더"
    return label
  }()

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  public func updateTitle(_ title: String) {
    self.titleLabel.text = title
  }
}

// MARK: - UI Setups

extension FavorSectionHeaderView: BaseView {
  public func setupStyles() {
    //
  }

  public func setupLayouts() {
    self.addSubview(self.titleLabel)
  }

  public func setupConstraints() {
    self.titleLabel.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
