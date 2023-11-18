//
//  ReminderDetailVC.swift
//  Favor
//
//  Created by 이창준 on 2023/04/06.
//

import UIKit

import FavorKit
import ReactorKit
import RxSwift
import SnapKit

final class ReminderDetailViewController: BaseReminderViewController, View {

  // MARK: - Constants

  // MARK: - Properties

  // MARK: - UI Components

  // Navigation Items
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
  
  // View Items
  private let contentsView = UIView()
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 40
    return stackView
  }()
  
  // Header
  private let eventInfoViewContainer = UIView()
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

  // Editables
  private lazy var notifyEmptyLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 16)
    label.textColor = .favorColor(.icon)
    label.text = "알림 없음"
    label.isHidden = true
    return label
  }()

  // MARK: - Life Cycle

  // MARK: - Binding
  
  func bind(reactor: ReminderDetailViewReactor) {
    // Action
    Observable.combineLatest(self.rx.viewDidLoad, self.rx.viewWillAppear)
      .map { _ in Reactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.editButton.rx.tap
      .map { Reactor.Action.editButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.deleteButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.presentRemovalPopup()
      }
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { $0.reminder }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, reminder in
        // 헤더
        owner.eventTitleLabel.text = reminder.name
        owner.eventSubtitleLabel.text = reminder.date.toDday()
        if let friend = reminder.relatedFriend,
           let urlString = reminder.relatedFriend?.profilePhoto?.remote
        {
          if let url = URL(string: urlString) {
            owner.eventImageView.imageView.setImage(
              from: url, mapper: .init(friend: friend, subpath: .profilePhoto(urlString))
            )
          }
        } else {
          owner.eventImageView.image = nil
        }
        // 날짜
        owner.dateSelectorTextField.updateDate(reminder.date)
        // 알림
        owner.notifyDateSelectorButton.title = reminder.date.toNotifyDays(reminder.notifyDate).stringValue
        owner.notifyDateSelectorButton.baseForegroundColor = .favorColor(.icon)
        owner.notifyDateSelectorButton.isSelected = true
        owner.notifyTimeSelectorTextField.updateDate(reminder.notifyDate)
        // 메모
        owner.memoTextView.text = reminder.memo
        // 친구
        if let friend = reminder.relatedFriend {
          owner.friendSelectorStack.isHidden = false
          owner.friendSelectorButton.updateButtonState(.favorColor(.icon), title: friend.friendName)
          owner.friendSelectorButton.configuration?.image = nil
        } else {
          owner.friendSelectorStack.isHidden = true
        }
      })
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions
  
  func presentRemovalPopup() {
    let removalPopup = NewAlertPopup(
      .onlyTitle(
        title: "삭제 하시겠습니까?",
        NewAlertPopup.ActionButtons(reject: "취소", accept: "삭제")
      ),
      identifier: "RemoveGift"
    )
    removalPopup.accpetButtonCompletion = { self.reactor?.action.onNext(.deleteButtonDidTap) }
    removalPopup.modalPresentationStyle = .overFullScreen
    self.present(removalPopup, animated: false)
  }

  // MARK: - UI Setups

  override func setupLayouts() {
    super.setupLayouts()

    // Navigation Items
    let rightItems = [self.deleteButton.toBarButtonItem(), self.editButton.toBarButtonItem()]
    self.navigationItem.setRightBarButtonItems(rightItems, animated: false)

    // View Items
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


    self.notifySelectorStack.insertArrangedSubview(self.notifyEmptyLabel, at: 2)
    [
      self.eventStack,
      self.dateSelectorStack,
      self.notifySelectorStack,
      self.friendSelectorStack,
      self.memoStack
    ].forEach {
      self.stackView.addArrangedSubview($0)
    }
    self.stackView.setCustomSpacing(8.0, after: self.eventStack)
  }

  override func setupConstraints() {
    super.setupConstraints()

    self.scrollView.snp.makeConstraints { make in
      make.directionalVerticalEdges.equalTo(self.view.safeAreaLayoutGuide)
      make.directionalHorizontalEdges.equalToSuperview()
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
      make.top.equalTo(self.eventImageView.snp.top).offset(-32)
      make.bottom.equalTo(self.eventImageView.snp.bottom).offset(32)
    }

    self.eventImageView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.width.height.equalTo(48)
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
