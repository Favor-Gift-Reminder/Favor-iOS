//
//  ProfileAnniversarySetupHelperCell.swift
//  Favor
//
//  Created by 김응철 on 2023/05/29.
//

import UIKit

import FavorKit
import Reusable
import SnapKit

final class ProfileAnniversarySetupHelperCell: UICollectionViewCell, Reusable {
  
  private enum Metric {
    static let shortCutButtonBottomInset: CGFloat = 52.0
    static let descriptionLabelBottomOffset: CGFloat = 40.0
    static let faovrImageViewBottomOffset: CGFloat = 18.5
    static let cornerRadius: CGFloat = 16.0
  }
  
  // MARK: - UI Components
  
  private let favorImageView: UIImageView = UIImageView().then {
    $0.image = .favorIcon(.favor)
  }
  
  private let descriptionLabel: UILabel = UILabel().then {
    $0.text = "챙겨주고 싶은 친구의 기념일을 등록해보세요."
    $0.font = .favorFont(.bold, size: 14.0)
    $0.textColor = .favorColor(.titleAndLine)
  }
  
  private let shortCutButton = FavorSmallButton(with: .dark("바로가기", image: nil))
  
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

extension ProfileAnniversarySetupHelperCell: BaseView {
  func setupStyles() {
    self.contentView.backgroundColor = .favorColor(.card)
    self.contentView.layer.cornerRadius = Metric.cornerRadius
    self.shortCutButton.isUserInteractionEnabled = false
  }
  
  func setupLayouts() {
    [
      self.favorImageView,
      self.descriptionLabel,
      self.shortCutButton
    ].forEach {
      self.contentView.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.shortCutButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalToSuperview().inset(Metric.shortCutButtonBottomInset)
    }
    
    self.descriptionLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(self.shortCutButton.snp.top).offset(-Metric.descriptionLabelBottomOffset)
    }
    
    self.favorImageView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(self.descriptionLabel.snp.top).offset(-Metric.faovrImageViewBottomOffset)
    }
  }
}
