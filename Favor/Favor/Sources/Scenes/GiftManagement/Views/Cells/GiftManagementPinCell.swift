//
//  GiftManagementPinCell.swift
//  Favor
//
//  Created by 이창준 on 2023/05/29.
//

import UIKit

import FavorKit
import RxCocoa
import RxSwift
import SnapKit

public protocol GiftManagementPinCellDelegate: AnyObject {
  func pinButtonDidTap(from cell: GiftManagementPinCell, isPinned: Bool)
}

public final class GiftManagementPinCell: BaseCollectionViewCell {

  // MARK: - Constants

  private enum Metric {
    static let pinButtonSize: CGFloat = 22.0
  }

  // MARK: - Properties

  public weak var delegate: GiftManagementPinCellDelegate?

  public var isPinned: Bool {
    self.pinButton.isSelected
  }

  // MARK: - UI Components

  private let label: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 18)
    label.textColor = .favorColor(.icon)
    label.text = "타임라인 고정"
    return label
  }()

  private let pinButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.background.backgroundColor = .clear
    config.image = .favorIcon(.pin)?
      .withRenderingMode(.alwaysTemplate)

    let button = UIButton(configuration: config)
    button.configurationUpdateHandler = { button in
      switch button.state {
      case .selected:
        button.configuration?.baseForegroundColor = .favorColor(.icon)
      case .normal:
        button.configuration?.baseForegroundColor = .favorColor(.line2)
      default:
        break
      }
    }
    button.contentMode = .center
    return button
  }()

  private let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 10
    return stackView
  }()

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
    self.bind()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Bind

  private func bind() {
    self.pinButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, _ in
        owner.pinButton.isSelected.toggle()
        owner.delegate?.pinButtonDidTap(from: self, isPinned: self.isPinned)
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  public func bind(with isPinned: Bool) {
    self.pinButton.isSelected = isPinned
  }
}

// MARK: - UI Setups

extension GiftManagementPinCell: BaseView {
  public func setupStyles() { }

  public func setupLayouts() {
    [
      self.label,
      self.pinButton
    ].forEach {
      self.stackView.addArrangedSubview($0)
    }

    self.addSubview(self.stackView)
  }

  public func setupConstraints() {
    self.stackView.snp.makeConstraints { make in
      make.directionalVerticalEdges.equalToSuperview()
      make.leading.equalToSuperview()
    }

    self.pinButton.snp.makeConstraints { make in
      make.width.height.equalTo(Metric.pinButtonSize)
    }
  }
}
