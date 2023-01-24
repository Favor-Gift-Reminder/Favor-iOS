//
//  FavorTextField.swift
//  Favor
//
//  Created by 이창준 on 2023/01/14.
//

import UIKit

import SnapKit

enum MessageType {
  case error, info
}

class FavorTextField: UITextField, BaseView {
  
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
  
  /// TextField 오른쪽에 SecureEyeButton이 있는 지 여부 Boolean.
  /// 일반적인 경우 TextField 초기화 시 한 번 설정합니다.
  var isSecureField: Bool = false {
    didSet {
      self.updateControl()
    }
  }
  
  /// TextField에 입력된 내용 숨김/표시 여부 Boolean
  var isTextHidden: Bool = true {
    didSet {
      self.updateTextVisibility()
      self.secureEyeButton.setNeedsUpdateConfiguration()
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
  var placeholderFont: UIFont? = .favorFont(.regular, size: 16.0) {
    didSet {
      self.updatePlaceholder()
      self.setNeedsDisplay()
    }
  }
  
  /// Placeholder 텍스트의 색상
  var placeholderColor: UIColor = .favorColor(.detail) {
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
  var messageFont: UIFont? = .favorFont(.regular, size: 12) {
    didSet {
      self.updateMessageLabel()
      self.setNeedsDisplay()
    }
  }
  
  /// 메시지가 있는 지의 Boolean
  var hasMessage: Bool {
    self.messageText != nil && !(self.messageText ?? "").isEmpty
  }
  
  /// 텍스트필드가 선택됐을 때 정보 메시지 색상
  var selectedMessageColor: UIColor? = .favorColor(.typo) {
    didSet {
      self.updateColors()
    }
  }
  
  /// 정보 메시지 색상
  var infoMessageColor: UIColor? = .favorColor(.box2) {
    didSet {
      self.updateColors()
    }
  }
  
  /// 에러 메시지 색상
  var errorMessageColor: UIColor? = .favorColor(.main) {
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
  var underlineColor: UIColor = .favorColor(.box1) {
    didSet {
      self.updateUnderlineColor()
    }
  }
  
  /// TextField가 선택됐을 때의 밑줄 색상
  var selectedUnderlineColor: UIColor = .favorColor(.typo) {
    didSet {
      self.updateUnderlineColor()
    }
  }
  
  /// TextField의 밑줄 두께
  var underlineHeight: CGFloat = 1.0
  
  /// TextField의 텍스트와 밑줄 사이의 거리
  var underlineSpacing: CGFloat = 16.0
  
  // MARK: - Secure Eye Button
  
  lazy var secureEyeButton = UIButton(
    configuration: .plain(),
    primaryAction: UIAction(handler: { _ in
      self.isTextHidden.toggle()
    })
  )
  
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupBaseTextField()
    self.setupSecureEyeButton()
    self.updateControl()
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
  
  private func setupSecureEyeButton() {
    self.rightView = self.secureEyeButton
    self.rightViewMode = .always
    self.secureEyeButton.configurationUpdateHandler = { button in
      var config = button.configuration
      let showIcon: UIImage? = UIImage(named: "ic_eye_small")?.withTintColor(.favorColor(.detail))
      let hideIcon: UIImage? = UIImage(named: "ic_eye_closed_small")?.withTintColor(.favorColor(.detail))
      config?.image = self.isTextHidden ? hideIcon : showIcon
      button.configuration = config
    }
  }
  
  // MARK: - Setup
  
  func setupStyles() {
    self.borderStyle = .none
    self.updateColors()
    self.font = .favorFont(.regular, size: 16.0)
    self.autocapitalizationType = .none
  }
  
  func setupLayouts() {
    [
      self.underlineView,
      self.messageLabel
    ].forEach {
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
    
    self.secureEyeButton.snp.makeConstraints { make in
      make.width.height.equalTo(24)
    }
  }
  
  // MARK: - Functions
  
  func addEditingChangedObserver() {
    self.addTarget(self, action: #selector(FavorTextField.editingChanged), for: .editingChanged)
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
  
  func addLeftItem(item: UIView) {
    item.snp.makeConstraints { make in
      make.height.equalTo(24)
      make.width.equalTo(28)
    }
    self.leftView = item
    self.leftViewMode = .always
  }
  
}

// MARK: - Privates

private extension FavorTextField {
  
  // MARK: - Updates
  
  /// UIControl 상태에 따라 TextField를 업데이트합니다.
  func updateControl(animated: Bool = false) {
    self.updateColors()
    self.updateMessageLabel(animated: animated)
    self.updateSecureEye()
  }
  
  /// 밑줄과 메시지 텍스트 색상을 업데이트합니다.
  func updateColors() {
    self.updateUnderlineColor()
    self.updateMessageLabelColor()
  }
  
  /// 메시지 타입(`error`, `info`)과 TextField 선택 여부에 따라 밑줄 색상을 업데이트합니다.
  func updateUnderlineColor() {
    if self.isEditingOrSelected {
      self.underlineView.backgroundColor = (self.messageType == .info) ? self.selectedUnderlineColor : self.errorMessageColor
    } else {
      self.underlineView.backgroundColor = (self.messageType == .info) ? self.underlineColor : self.errorMessageColor
    }
  }
  
  func updatePlaceholder() {
    guard let placeholder, let font = self.placeholderFont ?? self.font else { return }
    
    let color = self.isEnabled ? self.placeholderColor : .favorColor(.box1)
    self.attributedPlaceholder = NSAttributedString(
      string: placeholder,
      attributes: [
        .foregroundColor: color,
        .font: font
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
  
  /// 메시지 타입(`error`, `info`)과 TextField 선택 여부에 따라 메시지 텍스트 색상을 업데이트합니다.
  /// - Editing:
  ///   - invalid: `.favorColor(.main)`
  ///   - valid: `.favorColor(.typo)`
  /// - NotEditing:
  ///   - invalid: `.favorColor(.main)`
  ///   - valid: `.favorColor(.box2)`
  func updateMessageLabelColor() {
    if self.isEditingOrSelected {
      self.messageLabel.textColor = (self.messageType == .info) ? self.selectedMessageColor : self.errorMessageColor
    } else {
      self.messageLabel.textColor = (self.messageType == .info) ? self.infoMessageColor : self.errorMessageColor
    }
  }
  
  /// 암호화 필드 여부에 따라 TextField 속성들을 업데이트합니다.
  func updateSecureEye() {
    self.isTextHidden = self.isSecureField
    self.isSecureTextEntry = self.isSecureField
    self.secureEyeButton.isHidden = !self.isSecureField
  }
  
  /// 암호화 필드의 텍스트 숨김/표시 여부에 따라 텍스트를 숨김/표시 여부를 업데이트합니다.
  func updateTextVisibility() {
    self.isSecureTextEntry = self.isTextHidden
  }
  
}
