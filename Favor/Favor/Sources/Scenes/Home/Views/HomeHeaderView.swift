//
//  HeaderView.swift
//  Favor
//
//  Created by 이창준 on 2023/02/01.
//

import UIKit

import FavorKit
import RxCocoa
import RxSwift
import SnapKit

public protocol HomeHeaderViewDelegate: AnyObject {
  func rightButtonDidTap(from view: HomeHeaderView, for section: HomeSection)
  func filterDidSelected(from view: HomeHeaderView, to filterType: GiftFilterType)
}

public class HomeHeaderView: UICollectionReusableView {

  // MARK: - Constants

  private enum Metric {
    static let rightButtonSize: CGFloat = 32.0
  }
  
  // MARK: - Properties
  
  public var disposeBag = DisposeBag()
  
  public weak var delegate: HomeHeaderViewDelegate?

  public var section: HomeSection {
    didSet { self.updateToSection() }
  }

  private var selectedFilter: GiftFilterType = .all {
    didSet {
      self.delegate?.filterDidSelected(from: self, to: self.selectedFilter)
    }
  }
  
  // MARK: - UI Components
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 22.0)
    label.text = "헤더 타이틀"
    return label
  }()
  
  private let rightButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.background.backgroundColor = .clear
    config.baseForegroundColor = .favorColor(.icon)
    
    let button = UIButton(configuration: config)
    return button
  }()
  
  private let firstLineStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.distribution = .fillProportionally
    return stackView
  }()
  
  private lazy var allButton: UIButton = {
    let button = self.makeFilterButton(title: "모두")
    button.isSelected = true
    return button
  }()
  private lazy var receivedButton: UIButton = self.makeFilterButton(title: "받은 선물")
  private lazy var givenButton: UIButton = self.makeFilterButton(title: "준 선물")
  private var buttons: [UIButton] = []
  
  private let secondLineStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.distribution = .fillProportionally
    stackView.spacing = 24
    stackView.isHidden = true
    return stackView
  }()
  
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    self.section = .timeline(isEmpty: true)
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
    self.bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Binding
  
  public func bind() {
    // Action
    self.rightButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, _ in
        owner.delegate?.rightButtonDidTap(from: owner, for: owner.section)
      })
      .disposed(by: self.disposeBag)
    
    self.allButton.rx.tap
      .map { .all }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { $0.toggleButton($1) }
      .disposed(by: self.disposeBag)
    
    self.receivedButton.rx.tap
      .map { .received }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { $0.toggleButton($1) }
      .disposed(by: self.disposeBag)
    
    self.givenButton.rx.tap
      .map { .given }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { $0.toggleButton($1) }
      .disposed(by: self.disposeBag)
  }
}

// MARK: - Setup

extension HomeHeaderView: BaseView {
  public func setupStyles() {
    self.backgroundColor = .clear
  }
  
  public func setupLayouts() {
    [
      self.titleLabel,
      self.rightButton
    ].forEach {
      self.firstLineStack.addArrangedSubview($0)
    }

    [
      self.allButton,
      self.receivedButton,
      self.givenButton
    ].forEach {
      self.buttons.append($0)
    }
    
    [
      self.allButton,
      self.receivedButton,
      self.givenButton
    ].forEach {
      self.secondLineStack.addArrangedSubview($0)
    }
    
    [
      self.firstLineStack,
      self.secondLineStack
    ].forEach {
      self.addSubview($0)
    }
  }
  
  public func setupConstraints() {
    self.firstLineStack.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(Metric.rightButtonSize)
    }
    
    self.secondLineStack.snp.makeConstraints { make in
      make.centerY.equalTo(self.firstLineStack.snp.bottom).offset(25)
      make.leading.equalToSuperview()
      make.height.greaterThanOrEqualTo(44)
    }
    
    self.rightButton.snp.makeConstraints { make in
      make.width.height.equalTo(Metric.rightButtonSize)
    }
    self.rightButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    self.buttons.forEach {
      $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
  }
  
  func toggleButton(_ filterType: GiftFilterType) {
    self.buttons.forEach { $0.isSelected = false }
    self.buttons[filterType.rawValue].isSelected = true
    self.selectedFilter = filterType
  }
}

// MARK: - Private Functions

private extension HomeHeaderView {
  func updateToSection() {
    var isUpcoming: Bool
    if case HomeSection.timeline = self.section {
      isUpcoming = false
    } else {
      isUpcoming = true
    }
    // Header Title
    self.titleLabel.text = isUpcoming ? "다가오는 기념일" : "타임라인"
    // Filter Buttons
    self.secondLineStack.isHidden = isUpcoming ? true : false
    // Right Button
    self.rightButton.configurationUpdateHandler = { button in
      var config = button.configuration
      config?.contentInsets = .zero
      config?.baseForegroundColor = isUpcoming ? .favorColor(.subtext) : .favorColor(.icon)
      let title = isUpcoming ? "더보기" : nil
      config?.updateAttributedTitle(title, font: .favorFont(.regular, size: 12))
      config?.image = isUpcoming ? nil : .favorIcon(.filter)
      button.configuration = config
    }
  }
  
  func makeFilterButton(title: String) -> UIButton {
    var configuration = UIButton.Configuration.plain()
    var attributedTitle = AttributedString(title)
    attributedTitle.font = .favorFont(.bold, size: 16)
    configuration.attributedTitle = attributedTitle
    configuration.background.backgroundColor = .clear
    configuration.baseForegroundColor = .favorColor(.titleAndLine)
    configuration.contentInsets = .zero
    
    let button = UIButton(configuration: configuration)
    button.configurationUpdateHandler = { button in
      switch button.state {
      case .selected:
        button.configuration?.baseForegroundColor = .favorColor(.titleAndLine)
      case .normal:
        button.configuration?.baseForegroundColor = .favorColor(.explain)
      default:
        break
      }
    }
    
    return button
  }
}
