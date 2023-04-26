//
//  NewGiftFriendEmptyCell.swift
//  Favor
//
//  Created by 김응철 on 2023/04/14.
//

import UIKit

import FavorKit
import Reusable
import SnapKit

final class NewGiftFriendEmptyCell: BaseCollectionViewCell, Reusable {
  
  // MARK: - Properties
  
  private let imageView: UIImageView = {
    let iv = UIImageView()
    iv.image = .favorIcon(.couple)?.withTintColor(.favorColor(.line3))
    return iv
  }()
  
  private let label: UILabel = {
    let lb = UILabel()
    lb.text = "친구를 선택해주세요"
    lb.textColor = .favorColor(.line2)
    lb.font = .favorFont(.regular, size: 16)
    return lb
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

extension NewGiftFriendEmptyCell: BaseView {
  func setupStyles() {}
  
  func setupLayouts() {
    [
      self.imageView,
      self.label
    ].forEach {
      self.contentView.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.imageView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.width.height.equalTo(40)
      make.top.equalToSuperview().inset(32)
    }
    
    self.label.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.imageView.snp.bottom).offset(16)
    }
  }
}
