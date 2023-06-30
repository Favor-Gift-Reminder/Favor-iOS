//
//  AlertPopup.swift
//  Favor
//
//  Created by 김응철 on 2023/05/27.
//

import UIKit

import FavorKit
import RxCocoa
import SnapKit

final class AlertPopup: BasePopup {
  
  enum PopupType {
    case register
    case remove
    
    var contents: String {
      switch self {
      case .register:
        return "등록하시겠습니까?"
      case .remove:
        return "삭제하시겠습니까?"
      }
    }
  }
  
  private enum Metric {
    static let buttonStackSpacing: CGFloat = 7.0
    static let contentsLabelTopInset: CGFloat = 59.0
    static let buttonStackHorizontalInset: CGFloat = 20.0
    static let buttonStackHeight: CGFloat = 48.0
    static let buttonStackBottomInset: CGFloat = 24.0
    static let containerViewHeight: CGFloat = 184.0
  }
  
  // MARK: - UI Components
  
  /// 확인 버튼 입니다.
  private lazy var confirmButton = self.makeButton(
    backgroundColor: .favorColor(.main),
    foregroundColor: .favorColor(.white),
    title: "확인"
  )
  
  /// 취소 버튼 입니다.
  private lazy var cancelButton = self.makeButton(
    backgroundColor: .favorColor(.button),
    foregroundColor: .favorColor(.subtext),
    title: "취소"
  )
  
  private lazy var buttonStack: UIStackView = UIStackView().then { stack in
    [self.cancelButton, self.confirmButton].forEach { stack.addArrangedSubview($0) }
    stack.spacing = Metric.buttonStackSpacing
    stack.distribution = .fillEqually
  }
  
  private lazy var contentsLabel: UILabel = UILabel().then {
    $0.font = .favorFont(.bold, size: 16.0)
    $0.textColor = .favorColor(.black)
    $0.text = self.popupType.contents
  }
  
  // MARK: - Properties
  
  private let popupType: PopupType
  
  /// 확인 버튼을 누르고 난 후 구현해야할 클로저입니다.
  var confirmButtonHandler: (() -> Void)?
  
  // MARK: - Initializer
  
  init(_ popupType: PopupType) {
    self.popupType = popupType
    super.init(Metric.containerViewHeight)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [
      self.contentsLabel,
      self.buttonStack
    ].forEach {
      self.containerView.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.contentsLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().inset(Metric.contentsLabelTopInset)
    }
    
    self.buttonStack.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(Metric.buttonStackHorizontalInset)
      make.height.equalTo(Metric.buttonStackHeight)
      make.bottom.equalToSuperview().inset(Metric.buttonStackBottomInset)
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()

    /// 확인 버튼이 클릭 될 때
    self.confirmButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.confirmButtonHandler?()
        owner.dismissPopup()
      }
      .disposed(by: self.disposeBag)
    
    self.cancelButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.dismissPopup()
      }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions
  
  /// 팝업창에 필요한 버튼들을 만듭니다.
  private func makeButton(
    backgroundColor: UIColor,
    foregroundColor: UIColor,
    title: String
  ) -> UIButton {
    var config = UIButton.Configuration.filled()
    var container = AttributeContainer()
    container.font = .favorFont(.bold, size: 16.0)
    config.attributedTitle = AttributedString(title, attributes: container)
    config.baseBackgroundColor = backgroundColor
    config.baseForegroundColor = foregroundColor
    config.background.cornerRadius = 24.0
    let button = UIButton(configuration: config)
    return button
  }
}
