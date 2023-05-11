//
//  UICollectionViewCell+Tappable.swift
//  
//
//  Created by 이창준 on 2023/05/11.
//

import UIKit

import RxGesture

public protocol Tappable: GestureInteractable {

  // MARK: - Properties

  var idleBackgroundColor: UIColor { get set }
  var pressedBackgroundColor: UIColor { get set }
}

extension Tappable {
  public func setupTapRecognizer() {
    self.rx.tapGesture()
      .subscribe(with: self, onNext: { owner, event in
        let tapGestures: [UIGestureRecognizer.State] = [.recognized]

        let backgroundColor: UIColor = {
          tapGestures.contains(event.state) ?
          self.pressedBackgroundColor :
          self.idleBackgroundColor
        }()

        UIViewPropertyAnimator(duration: 0.1, curve: .easeInOut) {
          owner.backgroundColor = backgroundColor
        }.startAnimation()
      })
      .disposed(by: self.disposeBag)
  }
}
