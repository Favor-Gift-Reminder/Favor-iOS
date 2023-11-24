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
  
  private let doneButton: FavorButton = {
    let button = FavorButton()
    button.baseBackgroundColor = .white
    button.baseForegroundColor = .favorColor(.line2)
    button.configuration?.background.backgroundColor = .clear
    button.font = .favorFont(.bold, size: 18)
    button.contentInset = .zero
    button.configurationUpdateHandler = { button in
      switch button.state {
      case .normal:
        button.configuration?.baseForegroundColor = .favorColor(.main)
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
    
    self.friendSelectorButton.rx.tap
      .map { Reactor.Action.friendSelectorButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.dateSelectorTextField.rx.date
      .distinctUntilChanged()
      .map { Reactor.Action.datePickerDidUpdate($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.notifyTimeSelectorTextField.rx.date
      .distinctUntilChanged()
      .map { Reactor.Action.notifyTimePickerDidUpdate($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.doneButton.rx.tap
      .map { Reactor.Action.doneButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.titleTextField.rx.text
      .orEmpty
      .skip(1)
      .map { Reactor.Action.titleTextFieldDidUpdate($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.memoTextView.rx.text
      .orEmpty
      .map { Reactor.Action.memoTextViewDidUpdate($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { (type: $0.type, reminder: $0.reminder) }
      .filter { !($0.type == .new) }
      .take(1)
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, reminderData in
        let reminder = reminderData.reminder
        let type = reminderData.type
        owner.titleTextField.rx.text.onNext(reminder.name)
        owner.dateSelectorTextField.updateDate(reminder.date)
        if type == .edit {
          owner.notifyDateSelectorButton.title = reminder.date.toNotifyDays(reminder.notifyDate).stringValue
          owner.notifyDateSelectorButton.isSelected = true
          owner.notifyTimeSelectorTextField.updateDate(reminder.notifyDate)
        }
        if let friendName = reminder.relatedFriend?.friendName {
          owner.friendSelectorButton.updateButtonState(.favorColor(.icon), title: friendName)
        }
        owner.memoTextView.text = reminder.memo
      })
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.type }
      .take(1)
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, type in
        owner.title = type == .new ? "새 리마인더" : "리마인더 수정"
        let doneText = type == .new ? "등록" : "완료"
        owner.doneButton.configuration?.updateAttributedTitle(
          doneText,
          font: .favorFont(.bold, size: 18)
        )
        owner.doneButton.isEnabled = type == .edit
      })
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.isEnabledDoneButton }
      .bind(to: self.doneButton.rx.isEnabled)
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.currentFriend }
      .compactMap { $0 }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, friend in
        owner.friendSelectorButton.updateButtonState(.favorColor(.icon), title: friend.friendName)
      }
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  // Favor Switch delegate
  override func switchDidToggled(to state: Bool) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.notifySwitchDidToggle(state))
  }
  
  override func notifyDateDidChanged(_ notifyDays: NotifyDays) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.notifyDateDidUpdate(notifyDays))
  }
  
  // MARK: - UI Setups
  override func setupStyles() {
    super.setupStyles()
    
    self.scrollView.contentInset = UIEdgeInsets(
      top: self.verticalSpacing,
      left: .zero,
      bottom: self.verticalSpacing,
      right: .zero
    )
    self.doneButton.isEnabled = self.reactor?.currentState.type == .edit
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    // Navigation Items
    self.navigationItem.rightBarButtonItem = self.doneButton.toBarButtonItem()
    
    // View Items
    self.scrollView.addSubview(self.contentsView)
    self.contentsView.addSubview(self.stackView)
    
    [
      self.titleStack,
      self.dateSelectorStack,
      self.notifySelectorStack,
      self.friendSelectorStack,
      self.memoStack
    ].forEach {
      self.stackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.scrollView.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview()
      make.top.equalTo(self.view.safeAreaLayoutGuide)
      make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top)
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
