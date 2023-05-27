//
//  ReminderDatePopup.swift
//  Favor
//
//  Created by 김응철 on 2023/05/27.
//

import UIKit

import FavorKit
import SnapKit
import Then

final class ReminderDatePopup: BasePopup {
  
  private enum Metric {
    static let containerViewHeight: CGFloat = 252.0
    static let yearLabelTopInset: CGFloat = 26.0
    static let arrowButtonHorizontalInset: CGFloat = 20.0
    static let monthButtonWidth: CGFloat = 70.0
    static let monthButtonHeight: CGFloat = 40.0
    static let buttonStackHorizontalSpacing: CGFloat = 8.0
    static let buttonStackVerticalSpacing: CGFloat = 8.0
    static let buttonStackBottomInset: CGFloat = 32.0
    static let buttonVerticalStackHeight: CGFloat = 136.0
    static let buttonStackHorizontalInset: CGFloat = 16.0
  }
  
  // MARK: - UI Components
  
  private lazy var leftButton = self.makeArrowButton(image: .favorIcon(.left))
  private lazy var rightButton = self.makeArrowButton(image: .favorIcon(.right))
  private lazy var monthButtons = (1...12).map { self.makeMonthButton(month: $0) }
  private lazy var buttonHorizontalStack1 = self.makeHorizontalStack(Array(self.monthButtons[0...3]))
  private lazy var buttonHorizontalStack2 = self.makeHorizontalStack(Array(self.monthButtons[4...7]))
  private lazy var buttonHorizontalStack3 = self.makeHorizontalStack(Array(self.monthButtons[8...11]))
  
  private lazy var yearLabel: UILabel = UILabel().then {
    $0.font = .favorFont(.bold, size: 18.0)
    $0.textColor = .favorColor(.icon)
    $0.text = "2023년"
  }
  
  private lazy var buttonVerticalStack: UIStackView = UIStackView().then { stack in
    [
      self.buttonHorizontalStack1,
      self.buttonHorizontalStack2,
      self.buttonHorizontalStack3
    ].forEach { stack.addArrangedSubview($0) }
    stack.spacing = Metric.buttonStackVerticalSpacing
    stack.axis = .vertical
    stack.distribution = .fillEqually
  }
  
  // MARK: - Initializer
  
  init() {
    // TODO: 처음 진입할 때, 년도와 달 값 받기
    super.init(Metric.containerViewHeight)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Properties
  
  private var currentYear: Int = Date().currentYear {
    didSet { self.yearLabel.text = "\(self.currentYear)년" }
  }
  
  // MARK: - Setup
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [
      self.yearLabel,
      self.leftButton,
      self.rightButton,
      self.buttonVerticalStack
    ].forEach {
      self.containerView.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.yearLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().inset(Metric.yearLabelTopInset)
    }
    
    self.leftButton.snp.makeConstraints { make in
      make.centerY.equalTo(self.yearLabel)
      make.leading.equalToSuperview().inset(Metric.arrowButtonHorizontalInset)
    }
    
    self.rightButton.snp.makeConstraints { make in
      make.centerY.equalTo(self.yearLabel)
      make.trailing.equalToSuperview().inset(Metric.arrowButtonHorizontalInset)
    }
    
    self.buttonVerticalStack.snp.makeConstraints { make in
      make.bottom.equalToSuperview().inset(Metric.buttonStackBottomInset)
      make.directionalHorizontalEdges.equalToSuperview().inset(Metric.buttonStackHorizontalInset)
      make.height.equalTo(Metric.buttonVerticalStackHeight)
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    self.monthButtons.forEach { button in
      button.rx.tap
        .compactMap { button.configuration?.title }
        .asDriver(onErrorJustReturn: "")
        .drive(with: self) { owner, title in owner.tapMonthButton(title) }
        .disposed(by: self.disposeBag)
    }
    
    self.leftButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in owner.currentYear -= 1 }
      .disposed(by: self.disposeBag)
    
    self.rightButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in owner.currentYear += 1 }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions
  
  private func makeArrowButton(image: UIImage?) -> UIButton {
    let button = UIButton()
    let image = image?.resize(newWidth: 20.0)
    button.setImage(image, for: .normal)
    return button
  }
  
  private func makeMonthButton(month: Int) -> UIButton {
    var config = UIButton.Configuration.filled()
    var container = AttributeContainer()
    container.font = .favorFont(.bold, size: 16.0)
    config.attributedTitle = AttributedString("\(month)월", attributes: container)
    config.background.cornerRadius = 20.0
    config.baseForegroundColor = .favorColor(.subtext)
    config.baseBackgroundColor = .favorColor(.button)
    let button = UIButton(configuration: config)
    button.configurationUpdateHandler = {
      switch $0.state {
      case .selected:
        $0.configuration?.baseBackgroundColor = .favorColor(.main)
        $0.configuration?.baseForegroundColor = .favorColor(.white)
      default:
        $0.configuration?.baseBackgroundColor = .favorColor(.button)
        $0.configuration?.baseForegroundColor = .favorColor(.subtext)
      }
    }
    return button
  }
  
  private func makeHorizontalStack(_ buttons: [UIButton]) -> UIStackView {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = Metric.buttonStackHorizontalSpacing
    stackView.distribution = .fillEqually
    buttons.forEach { stackView.addArrangedSubview($0) }
    return stackView
  }
  
  private func tapMonthButton(_ month: String) {
    self.monthButtons.forEach { $0.isSelected = false }
    self.monthButtons.first(where: { $0.configuration?.title == month })?.isSelected = true
    // TODO: 현재 팝업 종료
  }
}
