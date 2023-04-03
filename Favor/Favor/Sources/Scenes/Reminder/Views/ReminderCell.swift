//
//  ReminderCell.swift
//  Favor
//
//  Created by 이창준 on 2023/03/30.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import RxCocoa
import SnapKit

final class ReminderCell: BaseCardCell, Reusable, View {

  // MARK: - Constants

  // MARK: - Properties

  // MARK: - UI Components

  private lazy var toggleSwitch = FavorSwitch()

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.imageType = .friend
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Binding

  func bind(reactor: ReminderCellReactor) {
    // Action
    self.toggleSwitch.rx.tap
      .map { Reactor.Action.notifySwitchDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { $0.reminderData }
      .asDriver(onErrorRecover: { _ in return .never()})
      .drive(with: self, onNext: { owner, reminder in
        owner.title = reminder.title
        owner.subtitle = reminder.date.toDday()
        owner.toggleSwitch.rx.state.onNext(reminder.shouldNotify)
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  // MARK: - UI Setups

  override func setupLayouts() {
    super.setupLayouts()

    self.addSubview(self.toggleSwitch)
  }

  override func setupConstraints() {
    super.setupConstraints()

    self.toggleSwitch.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(16)
      make.centerY.equalToSuperview()
      make.width.equalTo(40)
      make.height.equalTo(24)
    }
  }
}
