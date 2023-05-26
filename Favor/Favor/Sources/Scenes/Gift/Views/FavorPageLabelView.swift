//
//  FavorPageLabelView.swift
//  Favor
//
//  Created by 이창준 on 2023/05/25.
//

import UIKit

import FavorKit
import SnapKit

public final class FavorPageLabelView: UILabel {

  // MARK: - Properties

  public var height: CGFloat = 32.0 {
    didSet { self.updateHeight() }
  }

  /// 현재 페이지를 담는 프로퍼티
  public var current: Int = 0 {
    didSet { self.updateLabel() }
  }

  /// 전체 페이지 수를 담는 프로퍼티
  public var total: Int = 0 {
    didSet { self.updateLabel() }
  }

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
    self.updateLabel()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  private func updateLabel() {
    self.text = "\(self.current)/\(self.total)"
  }

  private func updateHeight() {
    self.snp.updateConstraints { make in
      make.height.equalTo(self.height)
    }
    self.layer.cornerRadius = self.height / 2
  }
}

// MARK: - UI Setups

extension FavorPageLabelView: BaseView {
  public func setupStyles() {
    self.font = .favorFont(.bold, size: 12)
    self.textAlignment = .center
    self.textColor = .favorColor(.white)
    self.backgroundColor = .favorColor(.titleAndLine)
    self.layer.cornerRadius = self.height / 2
    self.clipsToBounds = true
    self.setContentHuggingPriority(.defaultHigh, for: .horizontal)
  }

  public func setupLayouts() { }

  public func setupConstraints() {
    self.snp.makeConstraints { make in
      make.width.greaterThanOrEqualTo(52)
      make.height.equalTo(self.height)
    }
  }
}
