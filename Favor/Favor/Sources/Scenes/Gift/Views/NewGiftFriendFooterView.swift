//
//  NewGiftFriendFooterView.swift
//  Favor
//
//  Created by 김응철 on 2023/04/19.
//

import UIKit

import FavorKit
import Reusable

final class NewGiftFriendFooterView: UICollectionReusableView, Reusable {
  
  // MARK: - UI Components

  private let label: UILabel = {
    let lb = UILabel()
    lb.text = "직접 추가하기"
    lb.textColor = .favorColor(.icon)
    lb.font = .favorFont(.regular, size: 16)
    return lb
  }()
  
  private let circleView: UIView = {
    let view = UIView()
    view.backgroundColor = .favorColor(.line3)
    view.layer.cornerRadius = 24.0
    return view
  }()
  
  private let addImageView: UIImageView = {
    let iv = UIImageView()
    iv.image = .favorIcon(.add)?.withTintColor(.favorColor(.white))
    return iv
  }()
  
  private let divider = FavorDivider()

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

extension NewGiftFriendFooterView: BaseView {
  func setupStyles() {
    self.backgroundColor = .favorColor(.white)
  }
  
  func setupLayouts() {
    [
      self.circleView,
      self.addImageView,
      self.label,
      self.divider
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.divider.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalToSuperview()
    }
    
    self.circleView.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.top.equalTo(self.divider.snp.bottom).offset(16)
      make.width.height.equalTo(48.0)
    }
    
    self.addImageView.snp.makeConstraints { make in
      make.width.height.equalTo(22.0)
      make.center.equalTo(self.circleView)
    }
    
    self.label.snp.makeConstraints { make in
      make.centerY.equalTo(self.circleView)
      make.leading.equalTo(self.circleView.snp.trailing).offset(16)
    }
  }
}
