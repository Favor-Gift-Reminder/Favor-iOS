//
//  EmptyCollectionViewCell.swift
//  Favor
//
//  Created by 이창준 on 2023/02/04.
//

import UIKit

import SnapKit

final class EmptyCollectionViewCell: UICollectionViewCell, ReuseIdentifying {
  
  // MARK: - Properties
  
  /// descriptionLabel에 들어갈 텍스트
  var text: String = "Empty Cell" {
    willSet {
      self.descriptionLabel.text = newValue
    }
  }
  
  /// illustView에 들어갈 이미지
  var image: UIImage? {
    willSet {
      self.illustView.image = newValue
    }
  }
  
  // MARK: - UI Components
  
  private lazy var illustView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .favorColor(.background)
    return imageView
  }()
  
  private lazy var descriptionLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 18)
    label.textColor = .favorColor(.explain)
    label.textAlignment = .center
    label.text = self.text
    return label
  }()
  
  private lazy var containerView: UIView = {
    let view = UIView()
    return view
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

// MARK: - Setup

extension EmptyCollectionViewCell: BaseView {
  func setupStyles() {
    //
  }
  
  func setupLayouts() {
    [
      self.containerView
    ].forEach {
      self.addSubview($0)
    }
    [
      self.illustView,
      self.descriptionLabel
    ].forEach {
      self.containerView.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.containerView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.bottom.equalToSuperview()
    }
    
    self.illustView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.leading.trailing.lessThanOrEqualToSuperview().inset(96)
      make.top.equalToSuperview().inset(56)
      make.height.equalTo(self.illustView.snp.width)
    }
    
    self.descriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(self.illustView.snp.bottom).offset(32)
      make.centerX.equalToSuperview()
    }
  }
}
