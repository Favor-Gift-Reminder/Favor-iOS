//
//  OnboardingCell.swift
//  Favor
//
//  Created by 김응철 on 2023/01/12.
//

import UIKit

import SnapKit

final class OnboardingCell: UICollectionViewCell, ReuseIdentifying {
  
  // MARK: - Properties

  private let imageView: UIImageView = {
    let iv = UIImageView()
    iv.backgroundColor = .favorColor(.line3)
    
    return iv
  }()
  
  private let label: UILabel = {
    let lb = UILabel()
    lb.text = "안녕하세요"
    
    return lb
  }()
    
  private lazy var mainStack: UIStackView = {
    let sv = UIStackView()
    [
      self.imageView,
      self.label
    ].forEach {
      sv.addArrangedSubview($0)
    }
    sv.spacing = 48
    sv.axis = .vertical
    sv.alignment = .center
    
    return sv
  }()
  
  // MARK: - Initialize
  
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

extension OnboardingCell: BaseView {
  
  func setupStyles() {}
  
  func setupLayouts() {
    self.contentView.addSubview(self.mainStack)
  }
  
  func setupConstraints() {
    self.imageView.snp.makeConstraints { make in
      make.width.height.equalTo(180)
    }

    self.mainStack.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
}
