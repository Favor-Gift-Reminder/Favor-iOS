//
//  UITextField+.swift
//  
//
//  Created by 김응철 on 2023/03/27.
//

import UIKit

extension UITextField {
  public func addRightImage(_ image: UIImage?) {
    guard let image = image else { return }
    let newImage = image.resize(newWidth: 12)
    let rightImageView = UIImageView(frame: CGRect(
      x: 0,
      y: 0,
      width: newImage.size.width,
      height: newImage.size.height
    ))
    rightImageView.image = newImage
    self.rightView = rightImageView
    self.rightViewMode = .always
  }
}
