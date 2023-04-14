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
    case checked
    case close
    case delete
    case deleteCard
    case deselect
    case done
    case edit
    case favor
    case filter
    case friend
    case gallery
    case hashtag
    case heartedPerson
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
    case photo

    case down
    case left
    case right

    case birth
    case congrat
    case couple
    case employed
    case graduate
    case housewarm
    case pass
  }

  public static func favorIcon(_ icon: FavorIcon) -> UIImage? {
    return UIImage(named: "ic_\(icon.rawValue)")
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
