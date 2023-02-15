//
//  NewProfileCell.swift
//  Favor
//
//  Created by 이창준 on 2023/02/12.
//

import UIKit

import ReactorKit

class NewProfileCell: UICollectionViewCell, ReuseIdentifying, View {
  
  // MARK: - Properties
  
  var disposeBag = DisposeBag()
  
  // MARK: - UI Components
  
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
  
  // MARK: - Bind
  
  func bind(reactor: NewProfileCellReactor) {
    // Action
    
    // State
    
  }
}

// MARK: - Setup

extension NewProfileCell: BaseView {
  func setupStyles() {
    // TODO: 배경색 변경
    self.backgroundColor = .cyan
  }
  
  func setupLayouts() {
    //
  }
  
  func setupConstraints() {
    //
  }
}
