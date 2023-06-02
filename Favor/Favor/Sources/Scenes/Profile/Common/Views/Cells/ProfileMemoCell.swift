//
//  ProfileMemoCell.swift
//  Favor
//
//  Created by 김응철 on 2023/05/28.
//

import UIKit

import FavorKit
import Reusable
import Then

final class ProfileMemoCell: UICollectionViewCell, Reusable {
  
  // MARK: - UI Components
  
  private let memoLabel: UILabel = UILabel().then {
    $0.numberOfLines = 0
    $0.textAlignment = .left
    $0.font = .favorFont(.regular, size: 16.0)
  }
  
  private let divider = FavorDivider()
  
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
  
  func configure(with memo: String?) {
    if memo == nil {
      self.memoLabel.text = "친구의 취향, 관심사, 특징을 기록해보세요!"
      self.memoLabel.textColor = .favorColor(.explain)
    } else {
      self.memoLabel.text = memo
      self.memoLabel.textColor = .favorColor(.icon)
    }
  }
}

// MARK: - Setup

extension ProfileMemoCell: BaseView {
  func setupStyles() {}
  
  func setupLayouts() {
    [
      self.memoLabel,
      self.divider
    ].forEach {
      self.contentView.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.memoLabel.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
    }
    
    self.divider.snp.makeConstraints { make in
      make.bottom.leading.trailing.equalToSuperview()
      make.height.equalTo(1.0)
    }
  }
}
