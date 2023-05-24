//
//  PickPictureCell.swift
//  Favor
//
//  Created by 김응철 on 2023/02/08.
//

import UIKit

import FavorKit
import Reusable
import SnapKit

final class NewGiftEmptyCell: UICollectionViewCell, Reusable {
  
  // MARK: - UI
  
  private let photoImageView: UIImageView = {
    let image = UIImage.favorIcon(.gallery)?
      .resize(newWidth: 40)
      .withTintColor(.favorColor(.white), renderingMode: .alwaysOriginal)
    return UIImageView(image: image)
  }()
  
  // MARK: - Initalizer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupStyles()
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Setup

extension NewGiftEmptyCell: BaseView {
  func setupStyles() {
    self.backgroundColor = .favorColor(.line3)
    self.layer.cornerRadius = 8
  }
  
  func setupLayouts() {
    self.contentView.addSubview(self.photoImageView)
  }
  
  func setupConstraints() {
    self.photoImageView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
}
