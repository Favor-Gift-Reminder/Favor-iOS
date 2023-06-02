//
//  GiftDetailMemoCell.swift
//  Favor
//
//  Created by 이창준 on 2023/05/26.
//

import UIKit

import FavorKit
import Reusable
import RSKPlaceholderTextView
import SnapKit

final class GiftDetailMemoCell: BaseCollectionViewCell {

  // MARK: - Properties

  public var gift: Gift? {
    didSet { self.updateGift() }
  }

  // MARK: - UI Components

  private let memoTextView: RSKPlaceholderTextView = {
    let textView = RSKPlaceholderTextView()
    textView.attributedPlaceholder = NSAttributedString(
      string: "메모가 없습니다.",
      attributes: [
        .font: UIFont.favorFont(.regular, size: 14),
        .foregroundColor: UIColor.favorColor(.explain)
      ]
    )
    textView.isScrollEnabled = false
    textView.font = .favorFont(.regular, size: 14)
    textView.textColor = .favorColor(.icon)
    textView.textContainerInset = .zero
    textView.textContainer.lineFragmentPadding = .zero
    textView.isUserInteractionEnabled = false
    return textView
  }()

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
    self.memoTextView.sizeToFit()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  private func updateGift() {
    guard let gift = self.gift else { return }
    self.memoTextView.text = gift.memo
  }
}

// MARK: - UI Setups

extension GiftDetailMemoCell: BaseView {
  func setupStyles() { }

  func setupLayouts() {
    self.addSubview(self.memoTextView)
  }

  func setupConstraints() {
    self.memoTextView.snp.makeConstraints { make in
      make.top.directionalHorizontalEdges.equalToSuperview()
      make.bottom.equalToSuperview()
    }
  }
}
