//
//  FilterBottomSheet.swift
//  Favor
//
//  Created by 김응철 on 2023/04/04.
//

import UIKit

import FavorKit
import RxCocoa
import RxFlow
import RxSwift

final class FilterBottomSheet: BaseBottomSheet, Stepper {
  
  // MARK: - Properties
  
  private lazy var latestButton = self.makeSelectionButton(title: "최신순")
  private lazy var oldestButton = self.makeSelectionButton(title: "과거순")
  private lazy var buttons: [UIButton] = []
  
  var steps = PublishRelay<Step>()
  
  public var currentSortType: SortType = .latest {
    didSet { self.updateButton() }
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    self.updateTitle("필터")
    self.cancelButton.isHidden = true
    self.buttons = [latestButton, oldestButton]
    self.updateButton()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [
      self.latestButton,
      self.oldestButton
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.latestButton.snp.makeConstraints { make in
      make.top.equalTo(self.titleLabel.snp.bottom).offset(56)
      make.leading.equalTo(self.view.layoutMarginsGuide)
    }

    self.oldestButton.snp.makeConstraints { make in
      make.top.equalTo(self.latestButton.snp.bottom).offset(32)
      make.leading.equalTo(self.view.layoutMarginsGuide)
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    self.latestButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, _ in
        owner.currentSortType = .latest
//        owner.steps.accept(AppStep.filterBottomSheetIsComplete(.latest))
      })
      .disposed(by: self.disposeBag)

    self.oldestButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, _ in
        owner.currentSortType = .oldest
//        owner.steps.accept(AppStep.filterBottomSheetIsComplete(.oldest))
      })
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions
  
  func updateButton() {
    self.buttons.enumerated().forEach { index, button in
      button.isSelected = self.currentSortType.rawValue == index ? true : false
    }
  }
}

// MARK: - UI Factories

private extension FilterBottomSheet {
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
}
