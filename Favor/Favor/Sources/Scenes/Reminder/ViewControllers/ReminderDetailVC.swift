//
//  ReminderDetailVC.swift
//  Favor
//
//  Created by 이창준 on 2023/04/02.
//

import UIKit

import FavorKit
import ReactorKit
import SnapKit

final class ReminderDetailViewController: BaseReminderViewController, View {

  // MARK: - Constants

  private enum Metric {
    static let detailViewTopSpacing = 15.0
  }

  // MARK: - Properties

  override var verticalSpacing: CGFloat { return 8.0 }

  // MARK: - UI Components

  // Navigation Items

  private lazy var cancelButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.updateAttributedTitle("취소", font: .favorFont(.bold, size: 18))
    let button = UIButton(configuration: config)
    return button
  }()

  private lazy var editButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.image = .favorIcon(.edit)
    let button = UIButton(configuration: config)
    return button
  }()

  private lazy var deleteButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.image = .favorIcon(.delete)
    let button = UIButton(configuration: config)
    return button
  }()

  private lazy var doneButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.updateAttributedTitle("완료", font: .favorFont(.bold, size: 18))
    let button = UIButton(configuration: config)
    return button
  }()

  // View Items

  private lazy var stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 40
    return stackView
  }()

  private let contentsView = UIView()

  private lazy var eventInfoViewContainer: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    return view
  }()

  private lazy var eventImageView = FavorIconImageView(.profile)

  private lazy var eventTitleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 18)
    label.text = "이벤트"
    return label
  }()

  private lazy var eventSubtitleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 16)
    label.text = "날짜"
    return label
  }()

  private lazy var eventLabelStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 8
    return stackView
  }()

  private lazy var roundedTopView = FavorRoundedTopView()

  private lazy var eventStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 15
    return stackView
  }()

  // MARK: - Life Cycle

  // MARK: - Binding

  func bind(reactor: ReminderDetailViewReactor) {
    // Action
    self.rx.viewDidLoad
      .map { Reactor.Action.viewDidLoad }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.editButton.rx.tap
      .map { Reactor.Action.editButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.deleteButton.rx.tap
      .map { Reactor.Action.deleteButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.cancelButton.rx.tap
      .map { Reactor.Action.cancelButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.doneButton.rx.tap
      .map { Reactor.Action.doneButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.selectDatePicker.rx.date
      .map { Reactor.Action.datePickerDidUpdate($0) }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { _, action in
        reactor.action.onNext(action)
      })
      .disposed(by: self.disposeBag)

    self.notifyTimePicker.rx.date
      .map { Reactor.Action.notifyTimePickerDidUpdate($0) }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { _, action in
        reactor.action.onNext(action)
      })
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { $0.isEditable }
      .do(onNext: { isEditable in
        if !isEditable {
          self.selectDatePicker.finishEditMode()
        }
      })
      .observe(on: MainScheduler.asyncInstance)
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, isEditable in
        owner.switchToEditMode(isEditable)
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.reminderEditor }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, editor in
        owner.eventTitleLabel.text = editor.title
        owner.eventSubtitleLabel.text = editor.date.toDday()
        owner.selectDatePicker.rx.dateString.onNext(editor.date.toDateString())
        owner.notifyTimePicker.rx.dateString.onNext(editor.notifyTime?.toTimeString())
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  // MARK: - UI Setups

  override func setupLayouts() {
    super.setupLayouts()

    self.scrollView.addSubview(self.contentsView)
    self.contentsView.addSubview(self.stackView)

    [
      self.eventTitleLabel,
      self.eventSubtitleLabel
    ].forEach {
      self.eventLabelStack.addArrangedSubview($0)
    }

    [
      self.eventImageView,
      self.eventLabelStack
    ].forEach {
      self.eventInfoViewContainer.addSubview($0)
    }

    [
      self.eventInfoViewContainer,
      self.roundedTopView
    ].forEach {
      self.eventStack.addArrangedSubview($0)
    }
    
    [
      self.eventStack,
      self.selectFriendStack,
      self.selectDateStack,
      self.selectNotiStack,
      self.memoStack
    ].forEach {
      self.stackView.addArrangedSubview($0)
    }
    self.stackView.setCustomSpacing(8.0, after: self.eventStack)
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

    // Header
    self.eventInfoViewContainer.snp.makeConstraints { make in
      make.height.equalTo(112)
    }

    self.eventImageView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.width.height.equalTo(48)
      make.top.equalToSuperview().inset(32)
    }

    self.eventLabelStack.snp.makeConstraints { make in
      make.leading.equalTo(self.eventImageView.snp.trailing).offset(16)
      make.centerY.equalTo(self.eventImageView)
    }

    self.roundedTopView.snp.makeConstraints { make in
      make.height.equalTo(40)
    }
  }
}

// MARK: - Privates

private extension ReminderDetailViewController {
  func switchToEditMode(_ isEditable: Bool) {
    let leftItem = isEditable ? self.cancelButton.toBarButtonItem() : nil
    let editRightItems = [self.doneButton.toBarButtonItem()]
    let viewRightItems = [self.editButton.toBarButtonItem(), self.deleteButton.toBarButtonItem()]
    let rightItems = isEditable ? editRightItems : viewRightItems

    self.navigationItem.setLeftBarButton(leftItem, animated: true)
    self.navigationItem.setHidesBackButton(isEditable, animated: true)
    self.navigationItem.setRightBarButtonItems(rightItems, animated: true)
    self.title = isEditable ? "이벤트 수정" : nil

    self.selectDatePicker.updateIsUserInteractable(to: isEditable)
    self.notifyDateSelectorButton.isEnabled = isEditable
    self.notifyTimePicker.updateIsUserInteractable(to: isEditable)
    self.memoTextView.isUserInteractionEnabled = isEditable
  }
}
