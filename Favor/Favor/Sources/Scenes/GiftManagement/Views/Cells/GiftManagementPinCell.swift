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
    self.pinButton.isOn
  }
  
  // MARK: - UI Components

  private let label: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 18)
    label.textColor = .favorColor(.icon)
    label.text = "타임라인 고정"
    return label
  }()
  
  private let pinButton = FavorSwitch()

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
//    self.pinButton.
//      .asDriver(onErrorRecover: { _ in return .empty()})
//      .drive(with: self, onNext: { owner, _ in
//      })
//      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  public func bind(with isPinned: Bool) {
    self.pinButton.isOn = isPinned
  }
}

// MARK: - UI Setups

extension GiftManagementPinCell: BaseView {
  public func setupStyles() { 
    self.pinButton.delegate = self
  }

  public func setupLayouts() {
    [
      self.label,
      self.pinButton
    ].forEach {
      self.contentView.addSubview($0)
    }
  }

  public func setupConstraints() {
    self.label.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.directionalVerticalEdges.equalToSuperview()
    }
    
    self.pinButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview()
      make.directionalVerticalEdges.equalToSuperview()
      make.width.equalTo(40)
    }
  }
}

extension GiftManagementPinCell: FavorSwitchDelegate {
  public func switchDidToggled(to state: Bool) {
    self.delegate?.pinButtonDidTap(from: self, isPinned: state)
  }
}
