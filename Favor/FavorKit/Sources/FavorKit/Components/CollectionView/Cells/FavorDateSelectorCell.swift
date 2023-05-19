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

open class FavorDateSelectorCell: BaseCollectionViewCell, Reusable {

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
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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

// MARK: - Reactive

public extension Reactive where Base: FavorDateSelectorCell {
  var date: ControlEvent<Date> {
    return ControlEvent(events: base.datePicker.rx.date)
  }
}
