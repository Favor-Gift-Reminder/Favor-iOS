//
//  UpcomingCell.swift
//  Favor
//
//  Created by 이창준 on 2023/01/31.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import SnapKit

final class UpcomingCell: BaseCardCell, Reusable, View {
  
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
  
  func bind(reactor: UpcomingCellReactor) {
    // Action

    // State
    reactor.state.map { $0.reminder }
      .asDriver(onErrorRecover: { _ in return .never()})
      .drive(with: self, onNext: { owner, reminder in
        owner.title = reminder.title
        owner.subtitle = reminder.date.toDateString()
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - UI Setup

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
