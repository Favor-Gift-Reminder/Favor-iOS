//
//  GiftStatCell.swift
//  Favor
//
//  Created by 이창준 on 2023/02/12.
//

import UIKit

import ReactorKit
import SnapKit

final class GiftStatCell: UICollectionViewCell, ReuseIdentifying, View {
  
  // MARK: - Properties
  
  var disposeBag = DisposeBag()
  
  // MARK: - UI Components
  
  private lazy var countLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = .favorFont(.bold, size: 22)
    return label
  }()
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = .favorFont(.regular, size: 16)
    return label
  }()
  
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
//    self.setupLayouts()
//    self.setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Bind
  
  func bind(reactor: GiftStatCellReactor) {
    // Action
    
    // State
    
  }
}

// MARK: - Setup

extension GiftStatCell: BaseView {
  func setupStyles() {
    // TODO: 배경색 변경
    self.backgroundColor = .magenta
  }
  
  func setupLayouts() {
    [
      self.countLabel,
      self.titleLabel
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.countLabel.snp.makeConstraints { make in
      make.top.centerX.equalToSuperview()
      make.leading.trailing.equalToSuperview()
    }
    self.titleLabel.snp.makeConstraints { make in
      make.top.equalTo(self.countLabel.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
    }
  }
}
