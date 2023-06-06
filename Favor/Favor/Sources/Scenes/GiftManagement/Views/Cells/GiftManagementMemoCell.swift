//
//  GiftManagementMemoCell.swift
//  Favor
//
//  Created by 이창준 on 2023/05/29.
//

import UIKit

import FavorKit
import RSKPlaceholderTextView
import RxCocoa
import RxSwift
import SnapKit

public protocol GiftManagementMemoCellDelegate: AnyObject {
  func memoDidUpdate(_ memo: String?)
}

final class GiftManagementMemoCell: BaseCollectionViewCell {

  // MARK: - Properties

  public weak var delegate: GiftManagementMemoCellDelegate?

  // MARK: - UI Components

  private let memoView: RSKPlaceholderTextView = {
    let textView = RSKPlaceholderTextView()
    textView.attributedPlaceholder = NSAttributedString(
      string: "메모가 없습니다.",
      attributes: [
        .font: UIFont.favorFont(.regular, size: 16),
        .foregroundColor: UIColor.favorColor(.explain)
      ]
    )
    textView.isScrollEnabled = false
    textView.font = .favorFont(.regular, size: 16)
    textView.textColor = .favorColor(.icon)
    textView.textContainerInset = .zero
    textView.textContainer.lineFragmentPadding = .zero
    return textView
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

  // MARK: - Functions

  public func bind(with memo: String?) {
    self.memoView.text = memo
  }

  private func bind() {
    self.memoView.rx.text
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, _ in
        owner.delegate?.memoDidUpdate(owner.memoView.text)
      })
      .disposed(by: self.disposeBag)
  }
}

// MARK: - UI Setups

extension GiftManagementMemoCell: BaseView {
  func setupStyles() { }

  func setupLayouts() {
    self.addSubview(self.memoView)
  }

  func setupConstraints() {
    self.memoView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
