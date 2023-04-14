//
//  String+.swift
//  Favor
//
//  Created by 이창준 on 2023/02/08.
//

import UIKit

extension String {
  public func emojiToImage(size: CGSize) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    UIColor.clear.set()
    
    let rect = CGRect(origin: CGPoint(), size: size)
    UIRectFill(CGRect(origin: CGPoint(), size: size))
    (self as NSString).draw(
      in: rect,
      withAttributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: size.width * 0.9, weight: .regular)
      ]
    )
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image
  }

  public func toDate(_ format: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    if let date = dateFormatter.date(from: self) {
      return date
    }
    return nil
  }
}
