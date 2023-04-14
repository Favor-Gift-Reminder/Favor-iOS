//
//  UIScrollView+.swift
//  Favor
//
//  Created by 이창준 on 2023/03/01.
//

import UIKit

extension UIScrollView {
  public var verticalInsets: CGFloat { self.contentInset.top + self.contentInset.bottom }
  public var horizontalInsets: CGFloat { self.contentInset.left + self.contentInset.right }

  /// 특정 y 좌표로 스크롤뷰를 스크롤합니다.
  public func scroll(to offsetY: CGFloat) {
    DispatchQueue.main.async {
      self.setContentOffset(CGPoint(x: .zero, y: offsetY), animated: true)
    }
  }

  /// 맨 위, 중간, 맨 아래로 스크롤뷰를 스크롤합니다.
  /// - Parameters:
  ///   - direction: `top`, `center`,  `bottom`
  public func scroll(to direction: ScrollDirection) {
    DispatchQueue.main.async {
      switch direction {
      case .top:
        self.scroll(to: .zero)
      case .center:
        let centerOffsetY = (self.contentSize.height - self.bounds.size.height) / 2
        self.scroll(to: centerOffsetY)
      case .bototm:
        let visibleHeight = self.bounds.height - self.contentInset.bottom - self.contentInset.top
        let bottomOffsetY = self.contentSize.height - visibleHeight
        if bottomOffsetY > 0 {
          self.scroll(to: bottomOffsetY)
        }
      }
    }
  }
}
