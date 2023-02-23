//
//  FavorSwitch.swift
//  Favor
//
//  Created by 김응철 on 2023/02/16.
//

import UIKit

final class FavorSwitch: UISwitch {
  
  // MARK: - INITIALIZER
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.onTintColor = .favorColor(.main)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
