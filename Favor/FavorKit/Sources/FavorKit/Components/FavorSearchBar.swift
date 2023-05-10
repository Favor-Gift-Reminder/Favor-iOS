//
//  FavorSearchBar.swift
//  Favor
//
//  Created by 이창준 on 2023/02/07.
//

import UIKit

import ReactorKit
import RxCocoa
import SnapKit

/// 기본적으로 검색 아이콘을 왼쪽에 갖고 있는 SearchBar입니다.
///
/// `hasButton` 프로퍼티를 통해 좌측에 뒤로가기 버튼을 없애거나 넣을 수 있습니다.
/// 네비게이션 바를 대체할 때 `true`로 설정합니다.
public class FavorSearchBar: UIView {
  public typealias BackButtonHidden = Bool

  // MARK: - Constants
  
  // MARK: - Properties

  /// 뒤로가기 버튼 여부
  public var hasBackButton: Bool = true {
    didSet { self.updateBackButton() }
  }
  
  /// 뒤로가기 버튼의 크기 (1:1 ratio)
  public var backButtonSize: CGFloat = 40.0 {
    didSet { self.updateBackButton() }
  }
  
  /// SearchBar의 높이
  public var searchBarHeight: CGFloat = 40.0
  
  /// 뒤로가기 아이콘의 이미지
  public var backButtonImage: UIImage? = .favorIcon(.left)
  
  /// TextField의 Corner Radius
  public var cornerRadius: CGFloat = 20.0 {
    didSet { self.updateTextField() }
  }
  
  /// TextField의 placeholder 텍스트
  public var placeholder: String? {
    didSet { self.updateTextField() }
  }
  
  /// placeholder 텍스트의 색상
  public var placeholderColor: UIColor = .favorColor(.explain) {
    didSet { self.updateTextField() }
  }

  /// 왼쪽 아이템이 제거되는데 걸리는 TimeInterval
  public var popDuration: TimeInterval = 0.3

  /// 왼쪽 아이템이 추가되는데 걸리는 TimeInterval
  public var pushDuration: TimeInterval = 0.4
  
  // MARK: - UI Components
  
  fileprivate lazy var backButton: UIButton = {
    var configuration = UIButton.Configuration.plain()
    configuration.baseForegroundColor = .favorColor(.icon)
    configuration.background.backgroundColor = .clear
    configuration.image = self.backButtonImage
    
    let button = UIButton(configuration: configuration)
    return button
  }()

  private let searchImageView: UIImageView = {
    let imageView = UIImageView(image: .favorIcon(.search))
    imageView.contentMode = .center
    return imageView
  }()
  
  public lazy var textField: UITextField = {
    let textField = UITextField()
    textField.backgroundColor = .favorColor(.card)
    textField.font = .favorFont(.regular, size: 16)
    textField.textColor = .favorColor(.icon)
    textField.clipsToBounds = true
    textField.placeholder = "플레이스 홀더 메시지"
    textField.leftView = self.searchImageView
    textField.leftViewMode = .always
    textField.clearButtonMode = .always
    textField.autocapitalizationType = .none
    textField.enablesReturnKeyAutomatically = true
    textField.returnKeyType = .search
    return textField
  }()
  
  private lazy var searchStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.spacing = 18
    return stackView
  }()
  
  // MARK: - Initializer
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
    self.updateTextField()
    self.updateBackButton()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Functions

  /// 뒤로가기 버튼의 숨김 여부를 설정합니다.
  public func setBackButton(toHidden isHidden: BackButtonHidden, animated: Bool = true) {
    self.toggleBackButton(isHidden: isHidden, animated: animated)
  }

  /// 뒤로가기 버튼을 보여줍니다.
  public func showBackButton(animated: Bool = true) {
    self.toggleBackButton(isHidden: false, animated: animated)
  }

  /// 뒤로가기 버튼을 숨깁니다.
  public func hideBackButton(animated: Bool = true) {
    self.toggleBackButton(isHidden: true, animated: animated)
  }
}

// MARK: - Setup

extension FavorSearchBar {
  func setupStyles() { }
  
  func setupLayouts() {
    [
      self.backButton,
      self.textField
    ].forEach {
      self.searchStack.addArrangedSubview($0)
    }

    self.addSubview(self.searchStack)
  }
  
  func setupConstraints() {
    self.searchStack.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.height.equalTo(self.backButtonSize)
    }

    self.backButton.snp.makeConstraints { make in
      make.width.height.equalTo(self.backButtonSize)
    }

    self.searchImageView.snp.makeConstraints { make in
      make.width.equalTo(58)
    }

    self.textField.snp.makeConstraints { make in
      make.height.equalTo(self.searchBarHeight)
    }
  }
}

// MARK: - Privates

private extension FavorSearchBar {
  /// 뒤로 가기 버튼을 업데이트합니다.
  func updateBackButton() {
    if !self.hasBackButton {
      self.searchStack.removeArrangedSubview(self.backButton)
    } else {
      if !self.searchStack.arrangedSubviews.contains(self.backButton) {
        self.searchStack.insertArrangedSubview(self.backButton, at: 0)
      }
    }

    self.backButton.snp.updateConstraints { make in
      make.height.width.equalTo(self.backButtonSize)
    }
  }

  func toggleBackButton(isHidden: BackButtonHidden, animated: Bool = true) {
    let updateClosure = {
      self.backButton.isHidden = isHidden
    }

    if animated {
      let duration = isHidden ? self.popDuration : self.pushDuration
      UIViewPropertyAnimator(duration: duration, curve: .easeInOut) {
        updateClosure()
      }.startAnimation()
    } else {
      updateClosure()
    }
  }

  /// TextField를 업데이트합니다.
  private func updateTextField() {
    self.textField.layer.cornerRadius = self.cornerRadius

    var container = AttributeContainer()
    container.font = .favorFont(.regular, size: 16)
    container.foregroundColor = self.placeholderColor

    let attributedString = AttributedString(self.placeholder ?? "", attributes: container)
    self.textField.attributedPlaceholder = NSAttributedString(attributedString)
  }
}

// MARK: - Reactive

public extension Reactive where Base: FavorSearchBar {
  var text: ControlProperty<String?> {
    let source = base.textField.rx.text
    let bindingObserver = Binder(self.base) { textField, text in
      textField.textField.text = text
    }
    return ControlProperty(values: source, valueSink: bindingObserver)
  }
  
  var backButtonDidTap: ControlEvent<()> {
    let source = base.backButton.rx.tap
    return ControlEvent(events: source)
  }

  var editingDidBegin: ControlEvent<()> {
    let source = base.textField.rx.controlEvent(.editingDidBegin)
    return ControlEvent(events: source)
  }

  var editingDidEnd: ControlEvent<()> {
    let source = base.textField.rx.controlEvent(.editingDidEnd)
    return ControlEvent(events: source)
  }

  var editingDidEndOnExit: ControlEvent<()> {
    let source = base.textField.rx.controlEvent(.editingDidEndOnExit)
    return ControlEvent(events: source)
  }
}
