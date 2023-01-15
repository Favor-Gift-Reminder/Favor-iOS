//
//  FavorButton.swift
//  Favor
//
//  Created by 김응철 on 2023/01/15.
//

import UIKit

final class FavorButton: UIButton {
  
  enum Style {
    case black
    case white
  }
  
  // MARK: - Properties
  
  private let style: Style
  
  // MARK: - Initializer
  
  init(with style: Style, title: String) {
    self.style = style
    super.init(frame: .zero)
    setupConfiguration()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setupConfiguration() {
    var config = UIButton.Configuration.filled()
    
    switch style {
    case .white:
      
    case .black:
      
    }
  }
}
