//
//  GiftDetailPageFooterView.swift
//  Favor
//
//  Created by 이창준 on 2023/05/25.
//

import UIKit

import FavorKit
import RxSwift
import SnapKit

public final class GiftDetailPageFooterView: UICollectionViewCell {

  // MARK: - Properties

  private let disposeBag = DisposeBag()

  /// 현재 페이지를 담는 프로퍼티
  public var current: Int = 0 {
    didSet { self.updateLabel() }
  }

  /// 전체 페이지 수를 담는 프로퍼티
  public var total: Int = 0 {
    didSet { self.updateLabel() }
  }

  // MARK: - UI Components

  private let pageLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 12)
    label.textAlignment = .center
    label.textColor = .favorColor(.white)
    label.backgroundColor = .favorColor(.titleAndLine)
    label.layer.cornerRadius = 16
    label.clipsToBounds = true
    return label
  }()

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

  public func bind(currentPage: Observable<Int>, totalPages: Observable<Int>) {
    Observable.combineLatest(currentPage, totalPages)
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, pages in
        owner.current = pages.0 + 1
        owner.total = pages.1
      })
      .disposed(by: self.disposeBag)
  }

  private func updateLabel() {
    self.pageLabel.text = "\(self.current)/\(self.total)"
  }
}

// MARK: - UI Setups

extension GiftDetailPageFooterView: BaseView {
  public func setupStyles() {
    self.backgroundColor = .clear
  }

  public func setupLayouts() {
    self.addSubview(self.pageLabel)
  }

  public func setupConstraints() {
    self.pageLabel.snp.makeConstraints { make in
      make.bottom.equalTo(self.snp.top).offset(-14)
      make.trailing.equalToSuperview().inset(16)
      make.width.greaterThanOrEqualTo(52)
      make.height.equalTo(32)
    }
  }
}
