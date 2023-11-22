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

  // MARK: - Binding

  func bind(reactor: ReminderCellReactor) {
    // Action
    self.toggleSwitch.rx.tap
      .map { Reactor.Action.notifySwitchDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { $0.reminderData }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, reminder in
        owner.title = reminder.name
        owner.subtitle = reminder.date.toDday()
        owner.toggleSwitch.isOn = reminder.shouldNotify
        if let friend = reminder.relatedFriend,
           let urlString = friend.profilePhoto?.remote
        {
          guard let url = URL(string: urlString) else { return }
          owner.imageView.setImage(from: url, mapper: .init(friend: friend, subpath: .profilePhoto(urlString)))
          owner.imageView.isHidden = false
        } else {
          owner.imageView.isHidden = true
        }
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
