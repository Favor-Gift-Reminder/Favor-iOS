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
import RxCocoa
import SnapKit

public final class AnniversaryListCell: BaseCardCell, View, Reusable {

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

  fileprivate let rightButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.background.backgroundColor = .clear
    config.baseForegroundColor = .favorColor(.line2)

    let button = UIButton(configuration: config)
    button.contentMode = .center
    return button
  }()

  // MARK: - Binding

  public func bind(reactor: AnniversaryListCellReactor) {
    // Action
    self.rightButton.rx.tap
      .map { Reactor.Action.rightButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { (cellType: $0.cellType, isPinned: $0.anniversary.isPinned) }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, cellData in
        owner.convert(to: cellData.cellType, isPinned: cellData.isPinned)
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.anniversary }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, anniversary in
        owner.title = anniversary.title
        owner.subtitle = anniversary.date.toShortenDateString()
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  // MARK: - UI Setups

  public override func setupLayouts() {
    super.setupLayouts()

    self.addSubview(self.rightButton)
  }

  public override func setupConstraints() {
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
    // type == .list이고 isPinned일때만 .icon
    // 아니면 line2
    let iconColor: UIColor = isPinned && type == .list ?
      .favorColor(.icon) :
      .favorColor(.line2)
    self.rightButton.configuration?.image = type.rightButtonImage?
      .withRenderingMode(.alwaysTemplate)
      .resize(newWidth: Metric.rightButtonImageSize)
      .withTintColor(iconColor)
  }
}


// MARK: - Reactive

public extension Reactive where Base: AnniversaryListCell {
  var rightButtonDidTap: ControlEvent<()> {
    return ControlEvent(events: base.rightButton.rx.tap)
  }
}
