//
//  FavorTextField.swift
//  Favor
//
//  Created by 이창준 on 2023/02/23.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

class FavorTextField: UIView {

  // MARK: - Properties

  /// TextField가 highlighted되야 하는 상태 여부 Boolean (Editing or Selected)
  private var isEditingOrSelected: Bool = false {
    didSet { self.updateColor() }
  }

  /// TextField 오른쪽에 SecureEyeButton이 있는지 여부 Boolean
  public var isSecureField: Bool = false {
    didSet { self.updateSecureState() }
  }

  /// TextField가 SecureTextEntry 상태일 때 `SecureEyeButton`에 따라 숨겨졌는지 여부 Boolean
  private var isTextSecured: Bool? {
    didSet { self.updateSecureState() }
  }

  /// TextField의 Font
  public var textFieldFont: UIFont = .favorFont(.regular, size: 16) {
    didSet { self.updateTextField() }
  }

  /// TextField의 placeholder String
  public var placeholder: String? {
    didSet { self.updateTextField() }
  }

  /// Placeholder의 Font
  public var placeholderFont: UIFont = .favorFont(.regular, size: 16) {
    didSet { self.updateTextField() }
  }

  /// Placeholder의 텍스트 Color
  public var placeholderColor: UIColor = .favorColor(.explain) {
    didSet { self.updateTextField() }
  }

  /// TextField 상단 타이틀 Label의 String
  public var titleLabelText: String? {
    didSet { self.updateTitleLabel() }
  }

  /// TextField 상단 타이틀 Label의 Font
  public var titleLabelFont: UIFont = .favorFont(.bold, size: 18) {
    didSet { self.updateTitleLabel() }
  }

  /// TextField의 밑줄 색상
  public var underlineColor: UIColor = .favorColor(.divider) {
    didSet { self.updateColor() }
  }

  /// TextField의 밑줄 두께
  public var underlineHeight: CGFloat = 1.0

  /// TextField의 텍스트와 밑줄 사이의 거리
  public var underlineSpacing: CGFloat = 16.0

  /// TextField 하단에 위치하는 메세지가 존재하는지 여부 Boolean
  /// 해당 값의 여부에 따라 `FavorTextField` 전체적인 `frame`의 차이가 있음
  public var hasMessage: Bool = true {
    didSet { self.updateMessageLabel() }
  }

  /// TextField 하단에 위치하는 메시지 Label의 String
  public var messageLabelText: String = "" {
    didSet { self.updateMessageLabel() }
  }

  /// TextField 하단에 위치하는 메시지 Label의 상태 (enum)
  public enum MessageState {
    case normal, error
  }

  /// 메시지의 타입 (`normal`, `error`)
  public var messageState: MessageState = .normal {
    didSet { self.updateMessageLabel() }
  }

  /// TextField 하단의 메시지 Label이 비어있는지 여부 Boolean
  private var isMessageEmpty: Bool = false

  /// TextField 하단의 메시지 Font
  public var messageLabelFont: UIFont = .favorFont(.regular, size: 12) {
    didSet { self.updateMessageLabel() }
  }

  /// TextField 하단 메시지 Label의 애니메이션을 담당하는 프로퍼티
  private var messageLabelAnimator: UIViewPropertyAnimator?

  /// TextField 하단의 메시지 Color
  public var messageLabelColor: UIColor = .favorColor(.line2) {
    didSet { self.updateColor() }
  }

  /// TextField가 선택됐을 때의 밑줄과 메시지 색상
  public var normalStateColor: UIColor = .favorColor(.titleAndLine) {
    didSet { self.updateColor() }
  }

  /// TextField의 상태가 `error`일 때 밑줄과 메시지 색상
  public var errorStateColor: UIColor = .favorColor(.error) {
    didSet { self.updateColor() }
  }

  /// 생겨날 때 소요되는 애니메이션 시간
  public var fadeInDuration: TimeInterval = 0.2

  /// 사라질 때 소요되는 애니메이션 시간
  public var fadeOutDuration: TimeInterval = 0.3

  // MARK: - UI Components

  private lazy var stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 12
    return stackView
  }()

  /// 메인 컴포넌트
  public lazy var textField: UITextField = {
    let textField = UITextField()
    textField.borderStyle = .none
    textField.autocorrectionType = .no
    textField.enablesReturnKeyAutomatically = true
    textField.autocapitalizationType = .none
    textField.rightViewMode = .always
    textField.delegate = self
    return textField
  }()

  /// TextField의 하단에 깔리는 밑줄 View
  private lazy var underlineView: UIView = {
    let view = UIView()
    view.isUserInteractionEnabled = false
    return view
  }()

  /// TextField와 UnderlineView를 묶는 View
  private lazy var textFieldContainerView = UIView()

  /// TextField 상단에 표시되는 헤더 Label
  private lazy var titleLabel = UILabel()

  /// TextField 하단에 표시되는 정보 Label 위치를 잡아두는 View
  private lazy var messageLabelContainer = UIView()

  /// TextField 하단에 표시되는 정보 Label
  private lazy var messageLabel = UILabel()

  /// TextField 우측에 표시되는 숨김/표시 Button
  private lazy var secureEyeButton: UIButton = {
    var config = UIButton.Configuration.plain()

    let button = UIButton(
      configuration: config,
      primaryAction: UIAction(handler: { _ in self.isTextSecured?.toggle() })
    )
    button.configurationUpdateHandler = { button in
      guard let isTextSecured = self.isTextSecured else { return }
      var config = button.configuration
      let showIcon: UIImage? = UIImage(named: "ic_Show")?.withTintColor(.favorColor(.explain))
      let hideIcon: UIImage? = UIImage(named: "ic_Hide")?.withTintColor(.favorColor(.explain))
      config?.image = isTextSecured ? showIcon : hideIcon
      button.configuration = config
    }
    return button
  }()

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
    self.updateControl()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  func updateMessageLabel(_ text: String?, state: MessageState? = nil, animated: Bool = true) {
    guard let text else { return }
    let updateClosure = {
      self.messageLabelText = text
      if let messageState = state {
        self.messageState = messageState
      }
    }
    self.isMessageEmpty = text.isEmpty
    let alpha = self.isMessageEmpty ? 0.0 : 1.0
    if !self.isMessageEmpty { updateClosure() }
    if animated {
      let duration = self.isMessageEmpty ? self.fadeInDuration : self.fadeOutDuration
      self.messageLabelAnimator = UIViewPropertyAnimator(
        duration: duration,
        curve: .easeInOut,
        animations: {
          self.messageLabel.alpha = alpha
        }
      )
      self.messageLabelAnimator?.addCompletion({ _ in
        if self.isMessageEmpty { updateClosure() }
      })
      self.messageLabelAnimator?.startAnimation()
    }
  }

  func addLeftItem(item: UIView) {
    self.textField.leftView = item
    self.textField.leftView?.snp.makeConstraints { make in
      make.height.width.equalTo(24)
    }
    self.textField.leftViewMode = .always
  }

  /// First Responder 지정을 TextField에 전달합니다.
  @discardableResult
  override func becomeFirstResponder() -> Bool {
    super.becomeFirstResponder()
    return self.textField.becomeFirstResponder()
  }

  /// First Responder 지정 해제를 TextField에 전달합니다.
  @discardableResult
  override func resignFirstResponder() -> Bool {
    super.resignFirstResponder()
    return self.textField.resignFirstResponder()
  }
}

extension FavorTextField: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    self.isEditingOrSelected = true
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    self.isEditingOrSelected = false
  }
}

extension FavorTextField: BaseView {
  func setupStyles() { }

  func setupLayouts() {
    [
      self.textField,
      self.underlineView
    ].forEach {
      self.textFieldContainerView.addSubview($0)
    }

    self.messageLabelContainer.addSubview(self.messageLabel)

    self.addSubview(self.stackView)

    [
      self.titleLabel,
      self.textFieldContainerView,
      self.messageLabelContainer
    ].forEach {
      self.stackView.addArrangedSubview($0)
    }

    self.textField.rightView = self.secureEyeButton
  }

  func setupConstraints() {
    self.textField.snp.makeConstraints { make in
      make.top.directionalHorizontalEdges.equalToSuperview()
      make.height.greaterThanOrEqualTo(19)
    }

    self.underlineView.snp.makeConstraints { make in
      make.top.equalTo(self.textField.snp.bottom).offset(self.underlineSpacing)
      make.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(self.underlineHeight)
    }

    self.textFieldContainerView.snp.makeConstraints { make in
      make.top.equalTo(self.textField.snp.top)
      make.directionalHorizontalEdges.equalToSuperview()
      make.bottom.equalTo(self.underlineView.snp.bottom)
    }

    self.stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.messageLabel.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}

// MARK: - Privates

private extension FavorTextField {
  /// 모든 프로퍼티와 UI 요소를 업데이트합니다.
  func updateControl() {
    self.updateTextField()
    self.updateTitleLabel()
    self.updateMessageLabel()
    self.updateColor()
  }

  /// 프로퍼티와 상태에 따라 색상을 업데이트합니다.
  func updateColor() {
    switch self.messageState {
    case .normal:
      self.underlineView.backgroundColor = self.isEditingOrSelected ? self.normalStateColor : self.underlineColor
      self.messageLabel.textColor = self.isEditingOrSelected ? self.normalStateColor : self.messageLabelColor
    case .error:
      self.underlineView.backgroundColor = self.errorStateColor
      self.messageLabel.textColor = self.errorStateColor
    }
  }

  /// TextField를 업데이트합니다.
  func updateTextField() {
    // Placeholder
    guard let placeholder = self.placeholder else { return }
    var container = AttributeContainer()
    container.foregroundColor = self.placeholderColor
    container.font = self.placeholderFont
    self.textField.attributedPlaceholder = NSAttributedString(AttributedString(placeholder, attributes: container))
    self.textField.font = self.textFieldFont
  }

  /// 상단에 표시되는 타이틀 Label을 업데이트합니다.
  func updateTitleLabel() {
    guard let titleText = self.titleLabelText else {
      self.titleLabel.layer.opacity = 0.0
      return
    }
    self.titleLabel.layer.opacity = 1.0
    self.titleLabel.text = titleText
    self.titleLabel.font = self.titleLabelFont
  }

  /// TextField 하단의 메시지 인스턴스의 프로퍼티를 업데이트합니다.
  func updateMessageLabel() {
    self.messageLabelContainer.isHidden = self.hasMessage ? false : true
    self.isMessageEmpty = self.messageLabelText.isEmpty
    self.messageLabel.text = self.messageLabelText
    self.messageLabel.font = self.messageLabelFont
    self.updateColor()
  }

  /// `isSecureField` 값에 따라 프로퍼티를 업데이트합니다.
  func updateSecureState() {
    self.secureEyeButton.isHidden = self.isSecureField ? false : true

    guard let isTextSecured = self.isTextSecured else {
      self.isTextSecured = self.isSecureField
      return
    }
    self.textField.isSecureTextEntry = isTextSecured
  }
}

// MARK: - ReactorKit

extension Reactive where Base: FavorTextField {
  var text: ControlProperty<String?> {
    let source = base.textField.rx.text
    let bindingObserver = Binder(self.base) { (favorTextField, text: String?) in
      favorTextField.textField.text = text
    }
    return ControlProperty(values: source, valueSink: bindingObserver)
  }

  var editingDidEndOnExit: ControlEvent<()> {
    let source = base.textField.rx.controlEvent(.editingDidEndOnExit)
    return ControlEvent(events: source)
  }

  var editingDidBegin: ControlEvent<()> {
    let source = base.textField.rx.controlEvent(.editingDidBegin)
    return ControlEvent(events: source)
  }
}
