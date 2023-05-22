//
//  FavorDateSelectorCell.swift
//  Favor
//
//  Created by 이창준 on 2023/05/18.
//

import UIKit

import Reusable
import RxCocoa
import RxSwift
import SnapKit

public protocol FavorDateSelectorCellDelegate: AnyObject {
  func dateSelectorDidUpdate(from cell: FavorDateSelectorCell, _ date: Date?)
}

open class FavorDateSelectorCell: BaseCollectionViewCell, Reusable {

  // MARK: - Properties

  public weak var delegate: FavorDateSelectorCellDelegate?

  // MARK: - UI Components

  fileprivate let datePicker: FavorDatePickerTextField = {
    let datePicker = FavorDatePickerTextField()
    return datePicker
  }()

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
    self.bind()
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  private func bind() {
    self.datePicker.rx.optionalDate
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, date in
        owner.delegate?.dateSelectorDidUpdate(from: self, date)
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Bind

  public func bind(date: Date?) {
    print(date)
    self.datePicker.updateDate(date)
  }
}

// MARK: - UI Setups

extension FavorDateSelectorCell: BaseView {
  public func setupStyles() { }

  public func setupLayouts() {
    self.addSubview(self.datePicker)
  }

  public func setupConstraints() {
    self.datePicker.snp.makeConstraints { make in
      make.directionalVerticalEdges.equalToSuperview()
      make.leading.equalToSuperview()
    }
  }
}
