//
//  BaseTextField.swift
//  Favor
//
//  Created by 이창준 on 2023/01/14.
//

import UIKit

import SnapKit

enum MessageType {
  case error, info
}

class BaseTextField: UITextField, BaseView {
  
  // MARK: - Properties
  
  /// TextField가 선택되었는 지의 Boolean
  override var isSelected: Bool {
    didSet {
      self.updateControl(animated: true)
    }
  }
  
  /// TextField가 highlighted되야 하는 상태 여부 Boolean (Editing or Selected)
  var isEditingOrSelected: Bool {
    super.isEditing || self.isSelected
  }
  
  /// TextField가 enabled 됐는 지의 Boolean
  override var isEnabled: Bool {
    didSet {
      self.updateControl()
      self.updatePlaceholder()
    }
  }
  
  // MARK: - Animation
  
  /// 메시지가 표현되는 애니메이션 시간
  var fadeInDuration: TimeInterval = 0.2
  
  /// 메시지가 사라질 때 애니메이션 시간
  var fadeOutDuration: TimeInterval = 0.3
  
  // MARK: - Text
  
  /// TextField의 텍스트 콘텐츠
  override var text: String? {
    didSet {
      self.updateControl(animated: false)
    }
  }
  
  // MARK: - Placeholder
  
  /// TextField에 아무것도 입력되지 않았을 때 표시되는 String
  override var placeholder: String? {
    didSet {
      self.updatePlaceholder()
      self.setNeedsDisplay()
    }
  }
  
  /// Placeholder의 폰트
  var placeholderFont: UIFont? = .systemFont(ofSize: 16, weight: .regular) {
    didSet {
      self.updatePlaceholder()
      self.setNeedsDisplay()
    }
  }
  
  /// Placeholder 텍스트의 색상
  var placeholderColor: UIColor = FavorStyle.Color.detail.value {
    didSet {
      self.updatePlaceholder()
    }
  }
  
  // MARK: - Message Label
  
  /// TextField 하단에 표시되는 정보 Label
  var messageLabel: UILabel = {
    let messageLabel = UILabel()
    return messageLabel
  }()
  
  /// `messageLabel`로 출력될 String
  var messageText: String? {
    didSet {
      self.updateControl(animated: true)
    }
  }
  
  /// 메시지의 타입 (`info`, `error`)
  var messageType: MessageType = .info {
    didSet {
      self.updateControl(animated: true)
    }
  }
  
  /// 메시지의 폰트
  var messageFont: UIFont? = .systemFont(ofSize: 12, weight: .regular) {
    didSet {
      self.updateMessageLabel()
      self.setNeedsDisplay()
    }
  }
  
  /// 메시지가 있는 지의 Boolean
  var hasMessage: Bool {
    self.messageText != nil && !(self.messageText ?? "").isEmpty
  }
  
  /// 정보 메시지 색상
  var infoMessageColor: UIColor? = FavorStyle.Color.box2.value {
    didSet {
      self.updateColors()
    }
  }
  
  /// 에러 메시지 색상
  var errorMessageColor: UIColor? = FavorStyle.Color.error.value {
    didSet {
      self.updateColors()
    }
  }
  
  /// 메시지와 밑줄 사이의 간격
  var messageLabelSpacing: CGFloat = 8.0 {
    didSet {
      self.updateMessageLabel()
      self.setNeedsDisplay()
    }
  }
  
  // MARK: - Underline
  
  /// TextField의 하단에 깔리는 밑줄 View
  var underlineView: UIView = {
    let underlineView = UIView()
    underlineView.isUserInteractionEnabled = false
    return underlineView
  }()
  
  /// TextField의 밑줄 색상
  var underlineColor: UIColor = FavorStyle.Color.box1.value {
    didSet {
      self.updateUnderlineView()
    }
  }
  
  /// TextField가 선택됐을 때의 밑줄 색상
  var selectedUnderlineColor: UIColor = FavorStyle.Color.box2.value {
    didSet {
      self.updateUnderlineView()
    }
  }
  
  /// TextField의 밑줄 두께
  var underlineHeight: CGFloat = 1.0 {
    didSet {
      self.updateUnderlineView()
      self.setNeedsDisplay()
    }
  }
  
  /// TextField가 선택됐을 때의 밑줄 두께
  var selectedUnderlineHeight: CGFloat = 1.5 {
    didSet {
      self.updateUnderlineView()
      self.setNeedsDisplay()
    }
  }
  
  /// TextField의 텍스트와 밑줄 사이의 거리
  var underlineSpacing: CGFloat = 16.0 {
    didSet {
      self.updateUnderlineView()
      self.setNeedsDisplay()
    }
  }
  
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupBaseTextField()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupBaseTextField() {
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
    self.addEditingChangedObserver()
  }
  
  // MARK: - Setup
  
  func setupStyles() {
    self.borderStyle = .none
    self.updateColors()
  }
  
  func setupLayouts() {
    [self.underlineView, self.messageLabel].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.underlineView.snp.makeConstraints { make in
      make.top.equalTo(self.snp.bottom).offset(self.underlineSpacing)
      make.width.equalToSuperview()
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(self.underlineHeight)
    }
    
    self.messageLabel.snp.makeConstraints { make in
      make.top.equalTo(self.underlineView.snp.bottom).offset(self.messageLabelSpacing)
      make.width.equalToSuperview()
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(self.messageLabel.font.lineHeight)
    }
  }
  
  // MARK: - Functions
  
  func addEditingChangedObserver() {
    self.addTarget(self, action: #selector(BaseTextField.editingChanged), for: .editingChanged)
  }
  
  @objc func editingChanged() {
    self.updateControl(animated: true)
  }
  
  @discardableResult
  override func becomeFirstResponder() -> Bool {
    let result = super.becomeFirstResponder()
    self.updateControl(animated: true)
    return result
  }
  
  @discardableResult
  override func resignFirstResponder() -> Bool {
    let result = super.resignFirstResponder()
    self.updateControl(animated: true)
    return result
  }
  
  /// TextField 하단의 정보 메시지 레이블을 수정합니다.
  func updateMessage(_ message: String?, for messageType: MessageType) {
    self.messageText = message
    self.messageType = messageType
  }
  
  /// TextField 하단의 정보 메시지 색상을 `messageType`에 따라 변경합니다.
  func updateMessageColor(to color: UIColor, for messageType: MessageType) {
    
  }
  
}

// MARK: - Privates

private extension BaseTextField {
  
  // MARK: - Updates
  
  /// UIControl 상태에 따라 TextField를 업데이트합니다.
  func updateControl(animated: Bool = false) {
    self.updateColors()
    self.updateUnderlineView()
    self.updateMessageLabel(animated: animated)
  }
  
  func updateColors() {
    self.updateUnderlineColor()
    self.updateMessageLabelColor()
  }
  
  func updateUnderlineView() {
    let height = self.isEditingOrSelected ? self.selectedUnderlineHeight : self.underlineHeight
    self.underlineView.snp.updateConstraints { make in
      make.height.equalTo(height)
    }
    
    self.updateUnderlineColor()
  }
  
  func updateUnderlineColor() {
    if !self.isEnabled {
      self.underlineView.backgroundColor = .darkGray
    } else if self.hasMessage {
      self.underlineView.backgroundColor = (self.messageType == .info) ? self.infoMessageColor : self.errorMessageColor
    } else {
      self.underlineView.backgroundColor = self.isEditingOrSelected ? self.selectedUnderlineColor : self.underlineColor
    }
  }
  
  func updatePlaceholder() {
    guard let placeholder, let font = self.placeholderFont ?? font else { return }
    
    let color = self.isEnabled ? self.placeholderColor : .darkGray
    self.attributedPlaceholder = NSAttributedString(
      string: placeholder,
      attributes: [
        NSAttributedString.Key.foregroundColor: color,
        NSAttributedString.Key.font: font
      ]
    )
  }
  
  /// 메시지 레이블에 메시지를 넣어줍니다.
  func updateMessageLabel(animated: Bool = false, completion: ((_ completed: Bool) -> Void)? = nil) {
    self.messageLabel.font = self.messageFont
    self.messageLabel.text = self.messageText
    
    let alpha: CGFloat = self.hasMessage ? 1.0 : 0.0
    let updateBlock = { () -> Void in
      self.messageLabel.alpha = alpha
      self.messageLabel.snp.updateConstraints { make in
        make.height.equalTo(self.messageLabel.font.lineHeight)
      }
    }
    
    if animated {
      let duration = self.hasMessage ? self.fadeInDuration : self.fadeOutDuration
      UIView.animate(
        withDuration: duration,
        delay: 0,
        options: .curveEaseOut,
        animations: { () -> Void in
          updateBlock()
        },
        completion: completion
      )
    } else {
      updateBlock()
      completion?(true)
    }
  }
  
  /// 메시지 타입(`error`, `info`)에 따라 메시지 텍스트 색상을 업데이트합니다.
  func updateMessageLabelColor() {
    switch self.messageType {
    case .info:
      self.messageLabel.textColor = self.infoMessageColor
    case .error:
      self.messageLabel.textColor = self.errorMessageColor
    }
  }
  
}
