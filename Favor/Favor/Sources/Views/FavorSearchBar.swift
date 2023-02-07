//
//  FavorSearchBar.swift
//  Favor
//
//  Created by 이창준 on 2023/02/07.
//

import UIKit

class FavorSearchBar: UISearchBar {
  
  // MARK: - Properties
  
  
  
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupBaseSearchBar()
    self.searchBarStyle = .minimal
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupBaseSearchBar() {
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  // MARK: - Functions
}

// MARK: - Setup

extension FavorSearchBar: BaseView {
  func setupStyles() {
    self.backgroundColor = .clear
  }
  
  func setupLayouts() {
    //
  }
  
  func setupConstraints() {
    //
  }
}
