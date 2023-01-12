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
  
  private let mainImageView: UIImageView = {
    let iv = UIImageView()
    
    return iv
  }()
  
  private let mainLabel: UILabel = {
    let lb = UILabel()
    
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
    sv.axis = .horizontal
    
    return sv
  }()
  
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
  
  func setupStyles() {}
  
  func setupLayouts() {
    contentView.addSubview(mainStack)
  }
  
  func setupConstraints() {
    mainStack.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
}
