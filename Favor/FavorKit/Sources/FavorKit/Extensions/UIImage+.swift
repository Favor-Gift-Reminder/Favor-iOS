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
    case addnoti
    case baby
    case check
    case checkFilled
    case close
    case delete
    case deleteCard
    case deselect
    case done
    case edit
    case etc
    case erase
    case error
    case favor
    case filter
    case friend
    case gallery
    case hashtag
    case hide
    case home
    case more
    case gift
    case newGift
    case noti
    case pick
    case pin
    case remove
    case search
    case select
    case setting
    case share
    case show
    case uncheck
    case tabbar

    case down
    case left
    case right

    case birth
    case congrat
    case couple
    case employed
    case graduate
    case gradu
    case housewarm
    case pass

    case kakao
    case naver
    case apple
    
    case user_circle
    
    // Emotion
    case touching
    case excited
    case good
    case xoxo
    case boring
    
    case logo
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
  
  public func applyBlur_original(radius: CGFloat) -> UIImage {
    guard let ciImage = CIImage(image: self) else { return self }
    let filter = CIFilter(name: "CIGaussianBlur")
    filter?.setValue(ciImage, forKey: kCIInputImageKey)
    filter?.setValue(radius, forKey: kCIInputRadiusKey)
    guard let output = filter?.outputImage else { return self }
    return UIImage(ciImage: output)
  }
}
