//
//  OnboardingCell.swift
//  Favor
//
//  Created by 김응철 on 2023/01/12.
//

import UIKit

import FavorKit
import Reusable
import SnapKit

final class OnboardingCell: UICollectionViewCell, Reusable {
  
  // MARK: - UI COMPONENTS

  private let imageView: UIImageView = {
    let iv = UIImageView()
    iv.backgroundColor = .favorColor(.card)
    
    return iv
  }()
  
  private let label: UILabel = {
    let lb = UILabel()
    lb.numberOfLines = 2
    lb.textAlignment = .center
    
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
    sv.spacing = 32
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

// MARK: - SETUP

extension OnboardingCell: BaseView {
  
  /// 명시적으로 호출되어야 합니다.
  func configure(with slide: OnboardingSlide) {
    let attributedText = NSMutableAttributedString(string: slide.text)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 4
    paragraphStyle.alignment = .center
    attributedText.addAttribute(
      .paragraphStyle,
      value: paragraphStyle,
      range: NSRange(location: 0, length: attributedText.length)
    )
    self.label.attributedText = attributedText
    self.imageView.image = slide.image
  }
  
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
