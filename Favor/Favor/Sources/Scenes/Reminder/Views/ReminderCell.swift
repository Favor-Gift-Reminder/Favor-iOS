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

final class ReminderCell: BaseCardCell, Reusable {

  // MARK: - Constants

  // MARK: - Properties

  // MARK: - UI Components

  private lazy var toggleSwitch = FavorSwitch()

  // MARK: - Binding
  
//  func bind(reactor: ReminderCellReactor) {
//    // Action
//    self.toggleSwitch.rx.tap
//      .map { Reactor.Action.notifySwitchDidTap }
//      .bind(to: reactor.action)
//      .disposed(by: self.disposeBag)
//  }

  // MARK: - Functions
  
  func configure(_ reminder: Reminder) {
    self.title = reminder.name
    self.subtitle = reminder.date.toDday()
    self.toggleSwitch.isOn = reminder.shouldNotify
    if let friend = reminder.relatedFriend,
       let urlString = friend.profilePhoto?.remote
    {
      guard let url = URL(string: urlString) else { return }
      self.imageView.setImage(from: url, mapper: .init(friend: friend, subpath: .profilePhoto(urlString)))
      self.imageView.isHidden = false
    } else {
      self.imageView.isHidden = true
    }
  }

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
