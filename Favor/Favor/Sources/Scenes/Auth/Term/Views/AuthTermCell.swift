//
//  AuthTermCell.swift
//  Favor
//
//  Created by 이창준 on 2023/03/02.
//

import UIKit

import FavorKit
import RxCocoa
import RxSwift
import SnapKit

public final class AuthTermCell: BaseCollectionViewCell {

  // MARK: - Constants

  private enum Typo {
    static let detailButtonTitle: String = "보기"
  }

  // MARK: - Properties

  public var url: String?

  // MARK: - UI Components

  private let checkButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.background.backgroundColor = .clear

    let button = UIButton(configuration: config)

    button.configurationUpdateHandler = { button in
      switch button.state {
      case .normal:
        button.configuration?.image = .favorIcon(.uncheck)?
          .withRenderingMode(.alwaysTemplate)
        button.configuration?.baseForegroundColor = .favorColor(.line2)
      case .selected:
        button.configuration?.image = .favorIcon(.checkFilled)?
          .withRenderingMode(.alwaysTemplate)
        button.configuration?.baseForegroundColor = .favorColor(.main)
      default:
        break
      }
    }

    button.isUserInteractionEnabled = false
    return button
  }()

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 16)
    return label
  }()

  private let openDetailButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.updateAttributedTitle(Typo.detailButtonTitle, font: .favorFont(.regular, size: 16))
    config.baseForegroundColor = .favorColor(.main)

    let button = UIButton(configuration: config)
    return button
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

  // MARK: - Binding

  private func bind() {
    self.openDetailButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self, onNext: { owner, _ in
        guard
          let urlString = owner.url,
          let url = URL(string: urlString)
        else { return }
        UIApplication.shared.open(url)
      })
      .disposed(by: self.disposeBag)
  }

  public func bind(terms: Terms) {
    self.titleLabel.text = terms.title
    self.checkButton.isSelected = terms.isAccepted
    self.url = terms.url
  }

  // MARK: - Functions

}

// MARK: - UI Setup

extension AuthTermCell: BaseView {
  public func setupStyles() { }

  public func setupLayouts() {
    [
      self.checkButton,
      self.titleLabel,
      self.openDetailButton
    ].forEach {
      self.addSubview($0)
    }
  }

  public func setupConstraints() {
    self.checkButton.snp.makeConstraints { make in
      make.leading.directionalVerticalEdges.equalToSuperview()
      make.width.equalTo(self.checkButton.snp.height)
    }

    self.titleLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.checkButton.snp.trailing).offset(8)
      make.centerY.equalToSuperview()
      make.trailing.equalTo(self.openDetailButton.snp.leading)
    }

    self.openDetailButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    self.openDetailButton.snp.makeConstraints { make in
      make.trailing.directionalVerticalEdges.equalToSuperview()
      make.centerY.equalToSuperview()
    }
  }
}
