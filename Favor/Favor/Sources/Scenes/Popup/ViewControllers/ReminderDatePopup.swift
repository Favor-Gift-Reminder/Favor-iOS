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

protocol ReminderDatePopupDelegate: AnyObject {
  func reminderDatePopupDidClose(_ dateComponents: DateComponents)
}

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
  
  /// 월 버튼을 모아놓은 배열입니다.
  private lazy var monthButtons = (1...12).map { self.makeMonthButton(month: $0) }
  
  // 버튼들을 스택뷰로 모아둔 객체입니다.
  private lazy var buttonHorizontalStack1 = self.makeHorizontalStack(Array(self.monthButtons[0...3]))
  private lazy var buttonHorizontalStack2 = self.makeHorizontalStack(Array(self.monthButtons[4...7]))
  private lazy var buttonHorizontalStack3 = self.makeHorizontalStack(Array(self.monthButtons[8...11]))
  
  /// 팝업 상단의 년도를 나타내주는 레이블입니다.
  private lazy var yearLabel: UILabel = UILabel().then {
    $0.font = .favorFont(.bold, size: 18.0)
    $0.textColor = .favorColor(.icon)
    $0.text = "\(self.currentDate.year!)년"
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
  
  /// 초기에 진입할 때, 날짜 값의 정보가 필요합니다.
  init(_ date: DateComponents) {
    self.currentDate = date
    self.initialYear = date.year!
    super.init(Metric.containerViewHeight)
    self.yearDidChange()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Properties
  
  /// 현재 저장되어 있는 날짜 값 입니다.
  private var currentDate: DateComponents {
    didSet {
      self.yearLabel.text = "\(self.currentDate.year!)년"
      self.yearDidChange()
    }
  }
  
  /// 처음 화면에 진입할 때 저장할 년도 입니다.
  private let initialYear: Int
  
  /// 이벤트 처리를 위한 `Delegate` 컴포넌트 입니다.
  weak var delegate: ReminderDatePopupDelegate?
  
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
    
    // 월 버튼
    self.monthButtons.forEach { button in
      button.rx.tap
        .compactMap { button.configuration?.title }
        .asDriver(onErrorJustReturn: "")
        .drive(with: self) { owner, title in owner.monthButtonDidTap(title) }
        .disposed(by: self.disposeBag)
    }
    
    // 왼쪽 버튼
    self.leftButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in owner.currentDate.year! -= 1 }
      .disposed(by: self.disposeBag)
    
    // 오른쪽 버튼
    self.rightButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in owner.currentDate.year! += 1 }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions
  
  /// 년도 값을 달라지면 호출되는 메서드입니다.
  private func yearDidChange() {
    self.monthButtons.forEach {
      $0.isSelected = false
      $0.isEnabled = true
    }
    // 미래는 버튼 선택이 되지 않게 함
    if Date().currentYear <= self.currentDate.year ?? 1 {
      if Date().currentYear == self.currentDate.year {
        self.monthButtons[(Date().currentMonth)...].forEach { $0.isEnabled = false }
      } else {
        self.monthButtons.forEach { $0.isEnabled = false }
      }
    }
    if self.initialYear == self.currentDate.year {
      // 화면에 처음 진입했을 때의 년도 값과 현재 선택된 년도 값이 일치했을 경우,
      let month = self.currentDate.month ?? 0
      self.monthButtons[month - 1].isSelected = true
    }
  }
  
  /// 월 버튼을 클릭하면 호출되는 메서드입니다.
  /// - Parameters:
  ///  - month: 버튼에 들어가 있는 월 String 입니다.
  private func monthButtonDidTap(_ month: String) {
    // 문자열에서 숫자만 추출
    let extractedMonth = month.components(
      separatedBy: CharacterSet.decimalDigits.inverted)
      .joined()
    
    // 현재 저장되는 날짜에 월 값을 저장합니다.
    self.currentDate.month = Int(extractedMonth)
    // VC에 이벤트를 전달합니다.
    self.delegate?.reminderDatePopupDidClose(self.currentDate)
    // 팝업 창을 닫습니다.
    self.dismissPopup()
  }
}

// MARK: - Privates

private extension ReminderDatePopup {
  func makeArrowButton(image: UIImage?) -> UIButton {
    let button = UIButton()
    let image = image?.resize(newWidth: 20.0)
    button.setImage(image, for: .normal)
    return button
  }
  
  func makeMonthButton(month: Int) -> UIButton {
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
        $0.configuration?.background.backgroundColor = .favorColor(.main)
        $0.configuration?.baseForegroundColor = .favorColor(.white)
      case .disabled:
        $0.configuration?.background.backgroundColor = .favorColor(.button)
        $0.configuration?.baseForegroundColor = .favorColor(.line2)
      default:
        $0.configuration?.background.backgroundColor = .favorColor(.button)
        $0.configuration?.baseForegroundColor = .favorColor(.subtext)
      }
    }
    return button
  }
  
  func makeHorizontalStack(_ buttons: [UIButton]) -> UIStackView {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = Metric.buttonStackHorizontalSpacing
    stackView.distribution = .fillEqually
    buttons.forEach { stackView.addArrangedSubview($0) }
    return stackView
  }
}
