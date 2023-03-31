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

    // State
    reactor.state.map { $0.iconImage }
      .asDriver(onErrorRecover: { _ in return .never()})
      .drive(with: self, onNext: { owner, image in
        owner.image = image
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.title }
      .asDriver(onErrorRecover: { _ in return .never()})
      .drive(with: self, onNext: { owner, title in
        owner.title = title
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.subtitle }
      .asDriver(onErrorRecover: { _ in return .never()})
      .drive(with: self, onNext: { owner, subtitle in
        owner.subtitle = subtitle
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
