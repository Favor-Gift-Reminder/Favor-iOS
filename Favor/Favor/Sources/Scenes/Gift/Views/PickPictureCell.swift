//
//  PickPictureCell.swift
//  Favor
//
//  Created by 김응철 on 2023/02/08.
//

import UIKit

import FavorKit

final class PickPictureCell: UICollectionViewCell, ReuseIdentifying {
  
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

extension PickPictureCell: BaseView {
  func setupStyles() {
    self.backgroundColor = .favorColor(.explain)
  }
  
  func setupLayouts() {
    
  }
  
  func setupConstraints() {
    
  }
}
