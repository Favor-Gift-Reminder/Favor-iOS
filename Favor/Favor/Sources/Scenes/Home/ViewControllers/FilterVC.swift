//
//  FilterVC.swift
//  Favor
//
//  Created by 이창준 on 2023/03/17.
//

import UIKit

import FavorKit
import RxCocoa
import RxFlow
import SnapKit

final class FilterViewController: BaseBottomSheetViewController, Stepper {

  // MARK: - Constants

  // MARK: - Properties

  public var currentSortType: SortType = .latest {
    didSet { self.updateButton() }
  }

  // MARK: - UI Components

  var steps = PublishRelay<Step>()

  private lazy var sortLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 18)
    label.text = "정렬 기준"
    return label
  }()

  private lazy var latestButton = self.makeSelectionButton(title: "최신순")
  private lazy var oldestButton = self.makeSelectionButton(title: "과거순")

  private lazy var buttons: [UIButton] = []

  private lazy var buttonStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 24
    stackView.alignment = .leading
    return stackView
  }()

  // MARK: - Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.updateTitle("필터")
    self.buttons = [latestButton, oldestButton]
    self.updateButton()
  }

  // MARK: - UI Setup

  override func setupLayouts() {
    super.setupLayouts()

    [
      self.latestButton,
      self.oldestButton
    ].forEach {
      self.buttonStack.addArrangedSubview($0)
    }

    [
      self.sortLabel,
      self.buttonStack
    ].forEach {
      self.view.addSubview($0)
    }
  }

  override func setupConstraints() {
    super.setupConstraints()

    self.sortLabel.snp.makeConstraints { make in
      make.top.equalTo(self.topMenuContainerView.snp.bottom).offset(40)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }

    self.buttonStack.snp.makeConstraints { make in
      make.top.equalTo(self.sortLabel.snp.bottom).offset(32)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }
  }

  override func bind() {
    self.latestButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, _ in
        owner.currentSortType = .latest
        owner.steps.accept(AppStep.filterIsComplete(.latest))
      })
      .disposed(by: self.disposeBag)

    self.oldestButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, _ in
        owner.currentSortType = .oldest
        owner.steps.accept(AppStep.filterIsComplete(.oldest))
      })
      .disposed(by: self.disposeBag)
  }
}

private extension FilterViewController {
  func makeSelectionButton(title: String) -> UIButton {
    var config = UIButton.Configuration.plain()
    var container = AttributeContainer()
    container.font = .favorFont(.regular, size: 16)
    container.foregroundColor = .favorColor(.titleAndLine)
    config.attributedTitle = AttributedString(title, attributes: container)
    config.image = .favorIcon(.select)?.withTintColor(.favorColor(.icon))
    config.imagePlacement = .leading
    config.imagePadding = 20
    config.baseBackgroundColor = .clear

    let button = UIButton(configuration: config)
    button.configurationUpdateHandler = { button in
      var config = button.configuration
      let image: UIImage? = button.isSelected ? .favorIcon(.select) : .favorIcon(.deselect)
      config?.image = image?.withTintColor(.favorColor(.icon))
      button.configuration = config
    }
    return button
  }

  func updateButton() {
    self.buttons.enumerated().forEach { index, button in
      button.isSelected = self.currentSortType.rawValue == index ? true : false
    }
  }
}
