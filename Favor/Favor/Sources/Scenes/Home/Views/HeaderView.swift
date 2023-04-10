//
//  HeaderView.swift
//  Favor
//
//  Created by 이창준 on 2023/02/01.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import RxCocoa
import SnapKit

class HeaderView: UICollectionReusableView, Reusable, View {
  
  // MARK: - Properties
  
  var disposeBag = DisposeBag()
  
  // MARK: - UI Components
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 22.0)
    label.text = "헤더 타이틀"
    return label
  }()

  fileprivate lazy var rightButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.updateAttributedTitle("버튼", font: .favorFont(.bold, size: 18))
    config.baseForegroundColor = .favorColor(.titleAndLine)

    let button = UIButton(configuration: config)
    return button
  }()

  private lazy var firstLineStack: UIStackView = {
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
  private lazy var getButton: UIButton = self.makeFilterButton(title: "받은 선물")
  private lazy var giveButton: UIButton = self.makeFilterButton(title: "준 선물")
  
  private var buttons: [UIButton] = []
  
  private lazy var secondLineStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.distribution = .fillProportionally
    stackView.spacing = 24
    stackView.isHidden = true
    return stackView
  }()
  
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Binding
  
  func bind(reactor: HeaderViewReactor) {
    // Action
    self.allButton.rx.tap
      .map { Reactor.Action.allButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.getButton.rx.tap
      .map { Reactor.Action.getButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.giveButton.rx.tap
      .map { Reactor.Action.giveButotnDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { $0.sectionType }
      .map { $0 == .upcoming }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, isUpcoming in
        // Header Title
        owner.titleLabel.text = isUpcoming ? "다가오는 기념일" : "타임라인"
        // Filter Buttons
        owner.secondLineStack.isHidden = isUpcoming ? true : false
        // Right Button
        owner.rightButton.configurationUpdateHandler = { button in
          var config = button.configuration
          config?.contentInsets = .zero
          config?.baseForegroundColor = isUpcoming ? .favorColor(.subtext) : .favorColor(.icon)
          let title = isUpcoming ? "더보기" : nil
          config?.updateAttributedTitle(title, font: .favorFont(.regular, size: 12))
          config?.image = isUpcoming ? nil : .favorIcon(.filter)
          button.configuration = config
        }
      })
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.selectedButtonIndex }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, buttonIndex in
        owner.buttons.enumerated().forEach { currentIndex, button in
          button.isSelected = (currentIndex == buttonIndex) ? true : false
        }
      })
      .disposed(by: self.disposeBag)
  }
}

// MARK: - Setup

extension HeaderView: BaseView {
  func setupStyles() {
    self.backgroundColor = .clear
  }
  
  func setupLayouts() {
    [
      self.titleLabel,
      self.rightButton
    ].forEach {
      self.firstLineStack.addArrangedSubview($0)
    }

    [
      self.allButton,
      self.getButton,
      self.giveButton
    ].forEach {
      self.buttons.append($0)
    }

    [
      self.allButton,
      self.getButton,
      self.giveButton
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
  
  func setupConstraints() {
    self.firstLineStack.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(40)
      make.height.equalTo(32)
      make.directionalHorizontalEdges.equalToSuperview()
    }

    self.secondLineStack.snp.makeConstraints { make in
      make.centerY.equalTo(self.firstLineStack.snp.bottom).offset(25)
      make.leading.equalToSuperview()
      make.height.greaterThanOrEqualTo(44)
    }

    self.rightButton.snp.makeConstraints { make in
      make.width.height.equalTo(32)
    }
    self.rightButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    self.buttons.forEach {
      $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
  }
}

// MARK: - Private Functions

private extension HeaderView {
  func makeFilterButton(title: String) -> UIButton {
    var configuration = UIButton.Configuration.plain()
    var attributedTitle = AttributedString(title)
    attributedTitle.font = .favorFont(.bold, size: 16)
    configuration.attributedTitle = attributedTitle
    configuration.baseBackgroundColor = .clear
    configuration.baseForegroundColor = .favorColor(.titleAndLine)
    configuration.contentInsets = .zero
    
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      switch button.state {
      case .selected:
        button.configuration?.background.backgroundColor = .clear
        button.configuration?.baseForegroundColor = .favorColor(.titleAndLine)
      case .normal:
        button.configuration?.background.backgroundColor = .clear
        button.configuration?.baseForegroundColor = .favorColor(.explain)
      default:
        break
      }
    }
    
    let button = UIButton(configuration: configuration)
    button.configurationUpdateHandler = handler
    
    return button
  }
}

// MARK: - Reactive

extension Reactive where Base: HeaderView {
  var rightButtonDidTap: ControlEvent<()> {
    return ControlEvent(events: base.rightButton.rx.tap)
  }
}
