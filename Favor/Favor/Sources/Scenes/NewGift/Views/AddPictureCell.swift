//
//  AddPictureCell.swift
//  Favor
//
//  Created by 김응철 on 2023/02/07.
//

import UIKit

final class AddPictureCell: UICollectionViewCell, ReuseIdentifying {
  
  // MARK: - Properties
  
  // MARK: - Initializer
  
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

extension AddPictureCell: BaseView {
  func setupStyles() {
    self.backgroundColor = .favorColor(.explain)
  }
  
  func setupLayouts() {
    
  }
  
  func setupConstraints() {
    
  }
}
