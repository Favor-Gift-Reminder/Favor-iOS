//
//  EditStackMaker.swift
//  Favor
//
//  Created by 이창준 on 2023/04/01.
//

import UIKit

import FavorKit

protocol EditStackMaker {
  func makeEditStack(title: String, itemView: UIView, isDividerNeeded: Bool) -> UIStackView
  func makeTitleLabel(title: String) -> UILabel
}

extension EditStackMaker {
  func makeEditStack(
    title: String,
    itemView: UIView,
    isDividerNeeded: Bool = true
  ) -> UIStackView {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.distribution = .equalSpacing

    // Title Label
    let titleLabel = self.makeTitleLabel(title: title)

    // Divider
    let divider = FavorDivider()
    divider.isHidden = isDividerNeeded ? false : true

    [
      titleLabel,
      itemView,
      divider
    ].forEach {
      stackView.addArrangedSubview($0)
    }

    return stackView
  }

  func makeTitleLabel(title: String) -> UILabel {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 18)
    label.textAlignment = .left
    label.text = title
    return label
  }
}
