//
//  SearchUserResultCell.swift
//  Favor
//
//  Created by 이창준 on 2023/04/14.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import RxCocoa
import SnapKit

final class SearchUserResultCell: UICollectionViewCell, View, Reusable {

  // MARK: - Constants

  private enum Metric {
    static let profileImageSize = 120.0
    static let buttonHeight = 56.0
  }

  // MARK: - Properties

  public var disposeBag = DisposeBag()

  // MARK: - UI Components

  private lazy var profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.layer.cornerRadius = Metric.profileImageSize / 2
    imageView.clipsToBounds = true
    imageView.backgroundColor = .systemGray
    return imageView
  }()

  private lazy var nameLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 20)
    label.textColor = .favorColor(.icon)
    label.textAlignment = .center
    return label
  }()

  private lazy var idLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 14)
    label.textColor = .favorColor(.subtext)
    label.textAlignment = .center
    return label
  }()

  private lazy var labelStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 8
    return stackView
  }()

  fileprivate lazy var addFriendButton: FavorLargeButton = {
    let button = FavorLargeButton(with: .main2("친구맺기"))
    button.layer.cornerRadius = Metric.buttonHeight / 2
    button.layer.borderWidth = 1
    button.layer.borderColor = UIColor.favorColor(.divider).cgColor
    return button
  }()

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Binding

  func bind(reactor: SearchUserResultCellReactor) {
    // Action

    // State
    reactor.state.map { $0.userData }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, user in
        // image
        owner.nameLabel.text = user.name
        owner.idLabel.text = "@" + user.userID
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

}

// MARK: - UI Setups

extension SearchUserResultCell: BaseView {
  func setupStyles() {
    //
  }

  func setupLayouts() {
    [
      self.profileImageView,
      self.labelStack,
      self.addFriendButton
    ].forEach {
      self.addSubview($0)
    }

    [
      self.nameLabel,
      self.idLabel
    ].forEach {
      self.labelStack.addArrangedSubview($0)
    }
  }

  func setupConstraints() {
    self.profileImageView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(140)
      make.centerX.equalToSuperview()
      make.width.height.equalTo(Metric.profileImageSize)
    }

    self.labelStack.snp.makeConstraints { make in
      make.top.equalTo(self.profileImageView.snp.bottom).offset(32)
      make.centerX.equalToSuperview()
    }

    self.addFriendButton.snp.makeConstraints { make in
      make.bottom.equalToSuperview().inset(24)
      make.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(Metric.buttonHeight)
    }
  }
}

// MARK: - Reactive

extension Reactive where Base: SearchUserResultCell {
  var addFriendButtonDidTap: ControlEvent<()> {
    return ControlEvent(events: base.addFriendButton.rx.tap)
  }
}
