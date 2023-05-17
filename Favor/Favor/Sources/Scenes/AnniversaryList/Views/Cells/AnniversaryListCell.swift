//
//  AnniversaryListCell.swift
//  Favor
//
//  Created by 이창준 on 2023/05/16.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import SnapKit

final class AnniversaryListCell: BaseCardCell, View, Reusable {

  // MARK: - Constants

  public enum CellType {
    case list
    case edit

    public var rightButtonImage: UIImage? {
      switch self {
      case .list:
        return .favorIcon(.pin)
      case .edit:
        return .favorIcon(.edit)
      }
    }
  }

  private enum Metric {
    static let rightButtonSize = 48.0
    static let rightButtonImageSize = 18.0
  }

  // MARK: - Properties

  // MARK: - UI Components

  private let rightButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.background.backgroundColor = .clear
    config.baseForegroundColor = .favorColor(.line2)

    let button = UIButton(configuration: config)
    button.contentMode = .center
    return button
  }()

  // MARK: - Life Cycle

  // MARK: - Binding

  func bind(reactor: AnniversaryListCellReactor) {
    // Action

    // State
    reactor.state.map { (cellType: $0.cellType, isPinned: $0.anniversary.isPinned) }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, cellData in
        owner.convert(to: cellData.cellType, isPinned: cellData.isPinned)
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  // MARK: - UI Setups

  override func setupLayouts() {
    super.setupLayouts()

    self.addSubview(self.rightButton)
  }

  override func setupConstraints() {
    super.setupConstraints()

    self.rightButton.snp.makeConstraints { make in
      make.right.equalToSuperview().inset(16)
      make.centerY.equalToSuperview()
      make.width.height.equalTo(Metric.rightButtonSize)
    }
  }
}

// MARK: - Privates

private extension AnniversaryListCell {
  func convert(to type: CellType, isPinned: Bool) {
    let iconColor: UIColor = isPinned ? .favorColor(.icon) : .favorColor(.line2)
    self.rightButton.configuration?.image = type.rightButtonImage?
      .withRenderingMode(.alwaysTemplate)
      .resize(newWidth: Metric.rightButtonImageSize)
      .withTintColor(iconColor)
  }
}