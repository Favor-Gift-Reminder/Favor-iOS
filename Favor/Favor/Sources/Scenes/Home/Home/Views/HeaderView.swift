//
//  HeaderView.swift
//  Favor
//
//  Created by 이창준 on 2023/02/01.
//

import UIKit

import ReactorKit
import SnapKit

class HeaderView: UICollectionReusableView, ReuseIdentifying, View {
  
  // MARK: - Properties
  
  var disposeBag = DisposeBag()
  
  // MARK: - UI Components
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 22.0)
    label.text = "헤더 타이틀"
    return label
  }()
  
  private lazy var allButton: UIButton = {
    let button = self.makeFilterButton(title: "모두")
    button.isSelected = true
    return button
  }()
  
  private lazy var getButton: UIButton = {
    let button = self.makeFilterButton(title: "받은 선물")
    return button
  }()
  
  private lazy var giveButton: UIButton = {
    let button = self.makeFilterButton(title: "준 선물")
    return button
  }()
  
  private var buttons: [UIButton] = []
  
  private lazy var hStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.distribution = .fillProportionally
    stackView.spacing = 24
    [
      self.allButton,
      self.getButton,
      self.giveButton
    ].forEach {
      stackView.addArrangedSubview($0)
    }
    stackView.isHidden = true
    return stackView
  }()
  
  private lazy var vStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.addArrangedSubview(self.titleLabel)
    stackView.addArrangedSubview(self.hStack)
    return stackView
  }()
  
  private lazy var rightButton: UIButton = {
    var configuration = UIButton.Configuration.plain()
    configuration.title = "버튼"
    configuration.baseForegroundColor = .favorColor(.typo)
    
    let button = UIButton(configuration: configuration)
    return button
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
  
  func bind(reactor: HeaderReactor) {
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
    
    self.rightButton.rx.tap
      .map { Reactor.Action.rightButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { $0.sectionType }
      .map { $0 == .upcoming([]) }
      .asDriver(onErrorJustReturn: true)
      .drive(with: self, onNext: { owner, isUpcoming in
        // Header Title
        owner.titleLabel.text = isUpcoming ? "다가오는 이벤트" : "타임라인"
        // Filter Buttons
        owner.hStack.isHidden = isUpcoming
        // Right Button
        owner.rightButton.configurationUpdateHandler = { button in
          var config = button.configuration
          config?.contentInsets = .zero
          config?.baseForegroundColor = isUpcoming ? .favorColor(.detail) : .favorColor(.typo)
          config?.title = isUpcoming ? "더보기" : nil
          config?.image = isUpcoming ? nil : UIImage(named: "ic_filter")
          button.configuration = config
        }
      })
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.selectedButtonIndex }
      .asDriver(onErrorJustReturn: 0)
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
      self.allButton,
      self.getButton,
      self.giveButton
    ].forEach {
      self.buttons.append($0)
    }
    
    [
      self.vStack,
      self.rightButton
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.vStack.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(32)
      make.leading.equalToSuperview()
    }
    
    self.rightButton.snp.makeConstraints { make in
      make.centerY.equalTo(self.titleLabel.snp.centerY)
      make.trailing.equalToSuperview()
    }
    
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
    configuration.baseForegroundColor = .favorColor(.box2)
    configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      switch button.state {
      case .selected:
        button.configuration?.baseBackgroundColor = .clear
        button.configuration?.baseForegroundColor = .favorColor(.typo)
      case .normal:
        button.configuration?.baseBackgroundColor = .clear
        button.configuration?.baseForegroundColor = .favorColor(.box2)
      default:
        break
      }
    }
    
    let button = UIButton(configuration: configuration)
    button.configurationUpdateHandler = handler
    
    return button
  }
}
