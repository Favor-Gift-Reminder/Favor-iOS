//
//  FavorEmotionView.swift
//
//
//  Created by 김응철 on 11/9/23.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift

public final class FavorEmotionView: UIView {
  
  // MARK: - UI Components
  
  private lazy var buttons: [FavorButton] = {
    var buttons: [FavorButton] = []
    buttons = FavorEmotion.allCases.map { emotion in
      let button = FavorButton()
      button.baseBackgroundColor = .clear
      button.contentInset = .zero
      button.updateEmotion(emotion, size: 40.0)
      button.configurationUpdateHandler = { button in
        guard let button = button as? FavorButton else { return }
        switch button.state {
        case .selected:
          button.alpha = 1.0
        default:
          button.alpha = 0.3
        }
      }
      let action = UIAction { [weak self] _ in
        self?.updateEmotion(emotion)
        self?.emotionSubject.onNext(emotion)
      }
      button.addAction(action, for: .touchUpInside)
      return button
    }
    return buttons
  }()
  
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: self.buttons)
    stackView.distribution = .equalSpacing
    stackView.axis = .horizontal
    return stackView
  }()
  
  // MARK: - Properties
  
  public var emotionSubject = PublishSubject<FavorEmotion>()
  
  // MARK: - Initializer
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Functions
  
  public func updateEmotion(_ emotion: FavorEmotion?) {
    self.buttons.forEach { $0.isSelected = false }
    if let firstIndex = self.buttons.firstIndex(where: { $0.emotion == emotion }) {
      self.buttons[firstIndex].isSelected = true
    }
  }
}

extension FavorEmotionView: BaseView {
  public func setupStyles() {}
  
  public func setupLayouts() {
    self.addSubview(self.stackView)
  }
  
  public func setupConstraints() {
    self.stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.height.equalTo(40.0)
    }
  }
}
