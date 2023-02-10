//
//  PickedPictureCell.swift
//  Favor
//
//  Created by 김응철 on 2023/02/07.
//

import UIKit

final class PickedPictureCell: UICollectionViewCell, ReuseIdentifying {
  
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

extension PickedPictureCell: BaseView {
  func setupStyles() {
    self.backgroundColor = .favorColor(.main)
  }
  
  func setupLayouts() {
    
  }
  
  func setupConstraints() {
    
  }
}
