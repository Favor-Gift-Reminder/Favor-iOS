//
//  UIImage+.swift
//  Favor
//
//  Created by 이창준 on 2023/03/13.
//

import UIKit

extension UIImage {

  public enum FavorIcon: String {
    case add
    case addFriend
    case addNoti
    case check
    case checkFilled
    case close
    case delete
    case deleteCard
    case deselect
    case done
    case edit
    case etc
    case favor
    case filter
    case friend
    case gallery
    case hashtag
    case hide
    case home
    case more
    case newGift
    case noti
    case pin
    case remove
    case search
    case select
    case setting
    case share
    case show
    case uncheck
    
    case down
    case left
    case right
    
    case birth
    case congrat
    case couple
    case employ
    case gradu
    case gift
    case house
    case pass
  }

  public static func favorIcon(_ icon: FavorIcon) -> UIImage? {
    return UIImage(named: "ic_\(String(describing: icon.rawValue).lowercased())")
  }

  public func resize(newWidth: CGFloat) -> UIImage {
    let newSize = CGSize(width: newWidth, height: newWidth)
    let renderer = UIGraphicsImageRenderer(size: newSize)
    let renderedImage = renderer.image { _ in
      self.draw(in: CGRect(origin: .zero, size: newSize))
    }
    return renderedImage
  }
}
