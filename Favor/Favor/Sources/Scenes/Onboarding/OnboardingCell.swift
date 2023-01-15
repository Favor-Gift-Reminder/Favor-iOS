//
//  OnboardingCell.swift
//  Favor
//
//  Created by 김응철 on 2023/01/12.
//

import UIKit

import SnapKit

final class OnboardingCell: UICollectionViewCell, BaseView {
  
  // MARK: - Properties
  
  static let identifier = "OnboardingCell"
  
  private let mainImageView: UIImageView = {
    let iv = UIImageView()
    iv.backgroundColor = FavorStyle.Color.box1.value
    
    return iv
  }()
  
  private let mainLabel: UILabel = {
    let lb = UILabel()
    lb.text = "안녕하세요"
    
    return lb
  }()
    
  private lazy var mainStack: UIStackView = {
    let sv = UIStackView()
    [
      mainImageView,
      mainLabel
    ].forEach {
      sv.addArrangedSubview($0)
    }
    sv.spacing = 48
    sv.axis = .vertical
    sv.alignment = .center
    
    return sv
  }()
  
  let startBtn = UIFactory.favorButton(with: .large, title: "시작하기")
  private let mainContainerView = UIView()
  
  // MARK: - Initialize
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupStyles()
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  func setupStyles() {
  }
  
  func setupLayouts() {
    mainContainerView.addSubview(mainStack)
    
    [
      mainContainerView,
      startBtn
    ].forEach {
      contentView.addSubview($0)
    }
  }
  
  func setupConstraints() {
    mainContainerView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.bottom.equalTo(startBtn.snp.top)
    }
    
    mainStack.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
    mainImageView.snp.makeConstraints { make in
      make.width.height.equalTo(100)
    }
    
    startBtn.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.height.equalTo(56)
      make.bottom.equalToSuperview().inset(53)
    }
  }
}
