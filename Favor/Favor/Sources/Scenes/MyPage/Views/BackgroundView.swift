//
//  BackgroundView.swift
//  Favor
//
//  Created by 이창준 on 2023/02/16.
//

import UIKit

final class BackgroundView: UICollectionReusableView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.layer.cornerRadius = 24
    self.backgroundColor = .favorColor(.background)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
