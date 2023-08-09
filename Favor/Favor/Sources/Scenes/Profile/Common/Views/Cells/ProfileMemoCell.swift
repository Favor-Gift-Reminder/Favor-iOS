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
  
  private let memoLabel: FavorVerticalAlignmentLabel = {
    let label = FavorVerticalAlignmentLabel()
    label.numberOfLines = 0
    label.textAlignment = .justified
    label.lineBreakMode = .byWordWrapping
    label.font = .favorFont(.regular, size: 16.0)
    return label
  }()
  
  private let containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .favorColor(.card)
    view.layer.cornerRadius = 24.0
    return view
  }()
  
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
    guard let memo else { return }
    if memo.isEmpty {
      self.memoLabel.text = "친구의 관심사나 특징을 기록해보세요!"
      self.memoLabel.textColor = .favorColor(.explain)
    } else {
      self.memoLabel.text = memo
      self.memoLabel.textColor = .favorColor(.icon)
    }
    if self.memoLabel.intrinsicContentSize.height > self.defaultLabelHeight {
      self.labelHeight?.update(offset: self.memoLabel.intrinsicContentSize.height + 24.0)
    } else {
      self.labelHeight?.update(offset: self.defaultLabelHeight + 16.0)
    }
    print("Height: \(self.memoLabel.intrinsicContentSize.height)")
  }
}

// MARK: - Setup

extension ProfileMemoCell: BaseView {
  func setupStyles() {}
  
  func setupLayouts() {
    self.contentView.addSubview(self.containerView)
    self.containerView.addSubview(self.memoLabel)
  }
  
  func setupConstraints() {
    self.containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.height.greaterThanOrEqualTo(130.0)
    }
    
    self.memoLabel.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(12.0)
    }
  }
}
