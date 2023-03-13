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
    case addNoti
    case check
    case close
    case confirm
    case delete
    case deleteCard
    case deselect
    case done
    case edit
    case favor
    case friend
    case gallery
    case hashTag
    case hide
    case home
    case more
    case newFriend
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
    case employed
    case graduate
    case housewarm
    case pass
  }

  public static func favorIcon(_ icon: FavorIcon) -> UIImage? {
    let iconName = icon.rawValue.first!.uppercased() + icon.rawValue.dropFirst()
    return UIImage(named: "ic_\(iconName)")
  }

  public func resize(newWidth: CGFloat) -> UIImage {
    let scale = newWidth / self.size.width
    let newHeight = self.size.height * scale

    let newSize = CGSize(width: newWidth, height: newHeight)
    let renderer = UIGraphicsImageRenderer(size: newSize)
    let renderedImage = renderer.image { _ in
      self.draw(in: CGRect(origin: .zero, size: newSize))
    }
    return renderedImage
  }
}
