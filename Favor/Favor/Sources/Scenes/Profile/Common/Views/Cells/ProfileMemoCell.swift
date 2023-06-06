//
//  ProfileMemoCell.swift
//  Favor
//
//  Created by 김응철 on 2023/05/28.
//

import UIKit

import FavorKit
import Reusable
import SnapKit
import Then

final class ProfileMemoCell: UICollectionViewCell, Reusable {
  
  // MARK: - UI Components
  
  private let memoLabel: UILabel = UILabel().then {
    $0.numberOfLines = 0
    $0.textAlignment = .justified
    $0.lineBreakMode = .byWordWrapping
    $0.font = .favorFont(.regular, size: 16.0)
  }
  
  private let containerView: UIView = {
    let view = UIView()
    return view
  }()
  
  private let divider = FavorDivider()
  
  // MARK: - Properties
  
  private var labelHeight: Constraint?
  private let defaultLabelHeight: CGFloat = 130.0
  
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
    if self.memoLabel.intrinsicContentSize.height > self.defaultLabelHeight {
      print(self.memoLabel.intrinsicContentSize.height)
      self.labelHeight?.update(offset: self.memoLabel.intrinsicContentSize.height)
    } else {
      self.labelHeight?.update(offset: self.defaultLabelHeight)
    }
  }
}

// MARK: - Setup

extension ProfileMemoCell: BaseView {
  func setupStyles() {}
  
  func setupLayouts() {
    self.contentView.addSubview(self.containerView)
    
    [
      self.memoLabel,
      self.divider
    ].forEach {
      self.containerView.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      self.labelHeight = make.height.equalTo(self.defaultLabelHeight).constraint
    }
    
    self.memoLabel.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
    }
    
    self.divider.snp.makeConstraints { make in
      make.top.equalTo(self.containerView.snp.bottom).offset(16.0)
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(1.0)
    }
  }
}
