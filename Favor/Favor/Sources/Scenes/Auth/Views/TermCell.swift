//
//  TermCell.swift
//  Favor
//
//  Created by 이창준 on 2023/03/02.
//

import UIKit

import Reusable
import RxCocoa
import RxSwift
import SnapKit

final class TermCell: UITableViewCell, Reusable {

  // MARK: - Constants

  // MARK: - Properties

  var disposeBag = DisposeBag()
  var url: String?

  // MARK: - UI Components

  private lazy var checkButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.image = UIImage(systemName: "checkmark.square")
    config.contentInsets = NSDirectionalEdgeInsets(top: 6.5, leading: 6.5, bottom: 6.5, trailing: 6.5)
    config.baseForegroundColor = .favorColor(.icon)

    let button = UIButton(configuration: config)
    button.isUserInteractionEnabled = false
    return button
  }()

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 14)
    return label
  }()

  fileprivate lazy var openDetailButton: FavorPlainButton = {
    let button = FavorPlainButton(with: .more("보기"))
    return button
  }()

  // MARK: - Initializer

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()

    self.openDetailButton.rx.tap
      .asDriver(onErrorRecover: {_ in return .never()})
      .drive(with: self, onNext: { owner, tap in
        guard
          let urlString = owner.url,
          let url = URL(string: urlString)
        else { return }

        UIApplication.shared.open(url)
      })
      .disposed(by: self.disposeBag)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Binding

  public func bind(terms: Terms) {
    self.titleLabel.text = terms.title
    let image = terms.isAccepted ? "checkmark.square.fill" : "checkmark.square"
    self.checkButton.configuration?.image = UIImage(systemName: image)
    self.url = terms.url
  }

  // MARK: - Functions

}

// MARK: - UI Setup

extension TermCell: BaseView {
  func setupStyles() {
    self.contentView.frame = self.contentView.frame.inset(
      by: UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    )
    self.selectionStyle = .none
  }

  func setupLayouts() {
    [
      self.checkButton,
      self.titleLabel,
      self.openDetailButton
    ].forEach {
      self.addSubview($0)
    }
  }

  func setupConstraints() {
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
