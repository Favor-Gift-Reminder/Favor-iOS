//
//  EditMyPagePreferenceCell.swift
//  Favor
//
//  Created by 이창준 on 2023/04/25.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import SnapKit

final class EditMyPagePreferenceCell: BaseCollectionViewCell, Reusable, View {

  // MARK: - Constants

  // MARK: - Properties

  // MARK: - UI Components

  private let preferenceButton: UIButton = {
    var config = UIButton.Configuration.filled()

    let button = UIButton(configuration: config)
    button.configurationUpdateHandler = { button in
      switch button.state {
      case .normal:
        button.configuration?.baseBackgroundColor = .favorColor(.button)
        button.configuration?.baseForegroundColor = .favorColor(.subtext)
      case .selected:
        button.configuration?.baseBackgroundColor = .favorColor(.icon)
        button.configuration?.baseForegroundColor = .favorColor(.white)
      default: break
      }
    }
    return button
  }()

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Binding

  func bind(reactor: EditMyPagePreferenceCellReactor) {
    // Action
    self.preferenceButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, _ in
        owner.preferenceButton.isSelected.toggle()
      })
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { $0.favor }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, favor in
        owner.preferenceButton.configuration?.updateAttributedTitle(favor, font: .favorFont(.bold, size: 12))
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

}

// MARK: - UI Setups

extension EditMyPagePreferenceCell: BaseView {
  func setupStyles() {
    //
  }

  func setupLayouts() {
    self.addSubview(self.preferenceButton)
  }

  func setupConstraints() {
    self.preferenceButton.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
