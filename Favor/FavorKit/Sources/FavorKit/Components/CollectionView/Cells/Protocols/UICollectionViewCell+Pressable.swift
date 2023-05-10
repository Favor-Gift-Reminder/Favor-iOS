//
//  Pressable.swift
//  Favor
//
//  Created by 이창준 on 2023/05/10.
//

import UIKit

import RxGesture
import RxSwift

public protocol Pressable: AnyObject where Self: UICollectionViewCell {

  // MARK: - Properties

  var disposeBag: DisposeBag { get set }

  var pressedScale: Double { get set }
  var idleBackgroundColor: UIColor { get set }
  var pressedBackgroundColor: UIColor { get set }

  // MARK: - UI Components

  var containerView: UIView { get set }
}

extension Pressable {
  public func setupLongPressRecognizer() {
    self.rx.longPressGesture(configuration: { recognizer, _ in
      recognizer.minimumPressDuration = TimeInterval(0.05)
    })
    .asDriver(onErrorRecover: { _ in return .empty()})
    .drive(with: self, onNext: { owner, event in
      let pressingGestures: [UIGestureRecognizer.State] = [.began]

      let (scale, backgroundColor): (Double, UIColor) = {
        pressingGestures.contains(event.state) ?
        (self.pressedScale, self.pressedBackgroundColor) :
        (1.0, self.idleBackgroundColor)
      }()

      UIViewPropertyAnimator(duration: 0.15, curve: .easeInOut) {
        owner.containerView.transform = CGAffineTransform(scaleX: scale, y: scale)
        owner.backgroundColor = backgroundColor
      }.startAnimation()
    })
    .disposed(by: self.disposeBag)
  }
}
