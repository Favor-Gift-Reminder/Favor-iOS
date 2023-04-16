//
//  SearchRecentHeader.swift
//  Favor
//
//  Created by 이창준 on 2023/04/11.
//

import UIKit

import FavorKit
import Reusable
import SnapKit

final class SearchRecentHeader: UICollectionReusableView, Reusable {

  // MARK: - UI Components

  private let headerLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 18)
    label.text = "최근 검색어"
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
}

extension SearchRecentHeader: BaseView {
  func setupStyles() {
    self.backgroundColor = .clear
  }

  func setupLayouts() {
    self.addSubview(self.headerLabel)
  }

  func setupConstraints() {
    self.headerLabel.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
