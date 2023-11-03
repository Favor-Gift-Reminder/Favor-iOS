//
//  FavorEmotionButton.swift
//  Favor
//
//  Created by 이창준 on 6/15/23.
//

import UIKit

import SnapKit

public final class FavorEmotionButton: UIButton {

  // MARK: - Properties

  public var emotion: FavorEmotion! {
    didSet { self.setImage(self.emotion.emoji.emojiToImage(size: .init(width: 40, height: 40)), for: .normal) }
  }
  
  // MARK: - Initializer
  
  private override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }

  public convenience init(_ emotion: FavorEmotion) {
    self.init(frame: .zero)
    self.emotion = emotion
    self.setImage(self.emotion.emoji.emojiToImage(size: .init(width: 40, height: 40)), for: .normal)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Setup

extension FavorEmotionButton: BaseView {
  public func setupStyles() {
    self.contentMode = .center
//    self.configurationUpdateHandler = { button in
//      switch button.state {
//      case .selected:
//        self.backgroundView.isHidden = false
//      default:
//        self.backgroundView.isHidden = true
//      }
//    }
  }

  public func setupLayouts() {
  }
  
  public func setupConstraints() {
  }
}
