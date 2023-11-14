//
//  ProfilePreferenceCell.swift
//  Favor
//
//  Created by 이창준 on 2023/02/12.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import SnapKit

class ProfileFavorCell: UICollectionViewCell, Reusable {
  
  // MARK: - Properties
  
  var disposeBag = DisposeBag()
  
  // MARK: - UI Components
  
  private let favorLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 14)
    label.textColor = .favorColor(.icon)
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
  
  // MARK: - Functions
  
  func updateFavor(_ favor: Favor) {
    self.favorLabel.text = "# \(favor.rawValue)"
  }
}

// MARK: - Setup

extension ProfileFavorCell: BaseView {
  func setupStyles() {
    self.contentView.backgroundColor = .favorColor(.card)
    self.contentView.layer.cornerRadius = 16
  }
  
  func setupLayouts() {
    [
      self.favorLabel
    ].forEach {
      self.contentView.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.favorLabel.snp.makeConstraints { make in
      make.directionalVerticalEdges.equalToSuperview().inset(8)
      make.directionalHorizontalEdges.equalToSuperview().inset(16)
    }
  }
}
