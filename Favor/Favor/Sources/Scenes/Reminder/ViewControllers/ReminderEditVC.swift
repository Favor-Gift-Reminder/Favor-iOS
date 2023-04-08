//
//  ReminderEditVC.swift
//  Favor
//
//  Created by 이창준 on 2023/04/02.
//

import UIKit

import FavorKit
import ReactorKit
import SnapKit

final class ReminderEditViewController: BaseReminderViewController, View {

  // MARK: - Constants

  private enum Metric {
    static let detailViewTopSpacing = 15.0
  }

  // MARK: - Properties

  // MARK: - UI Components

  private lazy var doneButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.baseBackgroundColor = .clear
    config.baseForegroundColor = .favorColor(.line2)

    let button = UIButton(configuration: config)
    button.configurationUpdateHandler = { button in
      switch button.state {
      case .normal:
        button.configuration?.baseForegroundColor = .favorColor(.icon)
      case .disabled:
        button.configuration?.baseForegroundColor = .favorColor(.line2)
      default: break
      }
    }
    return button
  }()

  // View Items
  private let contentsView = UIView()

  private lazy var stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 40
    return stackView
  }()

  // MARK: - Life Cycle

  // MARK: - Binding

  func bind(reactor: ReminderEditViewReactor) {
    // Action
    self.rx.viewDidLoad
      .map { Reactor.Action.viewDidLoad }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.dateSelectorTextField.rx.date
      .distinctUntilChanged()
      .map { Reactor.Action.datePickerDidUpdate($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.notifyTimeSelectorTextField.rx.optionalDate
      .distinctUntilChanged()
      .map { Reactor.Action.notifyTimePickerDidUpdate($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.notifySwitch.rx.isOn
      .distinctUntilChanged()
      .map { Reactor.Action.notifySwitchDidToggle($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.doneButton.rx.tap
      .map { Reactor.Action.doneButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { $0.type }
      .asDriver(onErrorRecover: { _ in return .never()})
      .drive(with: self, onNext: { owner, type in
        owner.title = type == .new ? "새 리마인더" : "리마인더 수정"
        let doneText = type == .new ? "등록" : "완료"
        owner.doneButton.configuration?.updateAttributedTitle(
          doneText,
          font: .favorFont(.bold, size: 18)
        )
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.reminderEditor }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, editor in
        owner.dateSelectorTextField.isSelected = true
        owner.dateSelectorTextField.updateDate(editor.date)
        owner.notifyTimeSelectorTextField.isSelected = !(editor.notifyTime == nil)
        owner.notifyTimeSelectorTextField.updateDate(editor.notifyTime)
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  // MARK: - UI Setups
  override func setupStyles() {
    super.setupStyles()

    self.scrollView.contentInset = UIEdgeInsets(
      top: self.verticalSpacing,
      left: .zero,
      bottom: self.verticalSpacing,
      right: .zero
    )
  }

  override func setupLayouts() {
    super.setupLayouts()

    // Navigation Items
    self.navigationItem.setRightBarButton(self.doneButton.toBarButtonItem(), animated: true)

    // View Items
    self.scrollView.addSubview(self.contentsView)
    self.contentsView.addSubview(self.stackView)
    
    [
      self.titleStack,
      self.friendSelectorStack,
      self.dateSelectorStack,
      self.notifySelectorStack,
      self.memoStack
    ].forEach {
      self.stackView.addArrangedSubview($0)
    }
  }

  override func setupConstraints() {
    super.setupConstraints()

    self.scrollView.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview()
      make.directionalVerticalEdges.equalTo(self.view.safeAreaLayoutGuide)
    }

    self.contentsView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalToSuperview()
    }

    self.stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
