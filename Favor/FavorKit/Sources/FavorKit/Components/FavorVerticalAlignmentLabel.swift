//
//  FavorVerticalAlignmentLabel.swift
//
//
//  Created by 김응철 on 8/10/23.
//

import UIKit

public class FavorVerticalAlignmentLabel: UILabel {
  enum VerticalAlignment {
    case top
    case middle
    case bottom
  }
  
  var verticalAlignment: VerticalAlignment = .top {
    didSet {
      self.setNeedsDisplay()
    }
  }
  
  override public func textRect(forBounds bounds: CGRect, limitedToNumberOfLines: Int) -> CGRect {
    let rect = super.textRect(forBounds: bounds, limitedToNumberOfLines: limitedToNumberOfLines)
    
    if UIView.userInterfaceLayoutDirection(for: .unspecified) == .rightToLeft {
      switch verticalAlignment {
      case .top:
        return CGRect(x: self.bounds.size.width - rect.size.width, y: bounds.origin.y, width: rect.size.width, height: rect.size.height)
      case .middle:
        return CGRect(x: self.bounds.size.width - rect.size.width, y: bounds.origin.y + (bounds.size.height - rect.size.height) / 2, width: rect.size.width, height: rect.size.height)
      case .bottom:
        return CGRect(x: self.bounds.size.width - rect.size.width, y: bounds.origin.y + (bounds.size.height - rect.size.height), width: rect.size.width, height: rect.size.height)
      }
    } else {
      switch verticalAlignment {
      case .top:
        return CGRect(x: bounds.origin.x, y: bounds.origin.y, width: rect.size.width, height: rect.size.height)
      case .middle:
        return CGRect(x: bounds.origin.x, y: bounds.origin.y + (bounds.size.height - rect.size.height) / 2, width: rect.size.width, height: rect.size.height)
      case .bottom:
        return CGRect(x: bounds.origin.x, y: bounds.origin.y + (bounds.size.height - rect.size.height), width: rect.size.width, height: rect.size.height)
      }
    }
  }
  
  override public func drawText(in rect: CGRect) {
    let r = self.textRect(forBounds: rect, limitedToNumberOfLines: self.numberOfLines)
    super.drawText(in: r)
  }
}