//
//  GiftDetailTagsCell.swift
//  Favor
//
//  Created by 이창준 on 2023/05/25.
//

import UIKit

import FavorKit
import RxCocoa
import RxSwift
import SnapKit

public protocol GiftDetailTagsCellDelegate: AnyObject {
  func tagDidSelected(_ tag: GiftTags)
}

final class GiftDetailTagsCell: BaseCollectionViewCell {

  // MARK: - Properties

  public weak var delegate: GiftDetailTagsCellDelegate?

  public var gift: Gift = Gift() {
    didSet { self.updateGift() }
  }

  // MARK: - UI Components

  private let emotionButton = FavorSmallButton(with: .grayWithEmotion(.favorIcon(.deselect)))
  private let categoryButton = FavorSmallButton(with: .gray("카테고리"))
  private let isGivenButton = FavorSmallButton(with: .gray("준 선물"))
  private let relatedFriendsButton = FavorSmallButton(with: .grayWithUser("친구", image: .favorIcon(.friend)))

  private let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 10
    return stackView
  }()

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
    self.bind()
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Bind

  private func bind() {
    self.emotionButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, _ in
        owner.delegate?.tagDidSelected(.emotion(.boring))
      })
      .disposed(by: self.disposeBag)

    self.categoryButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, _ in
        owner.delegate?.tagDidSelected(.category(self.gift.category))
      })
      .disposed(by: self.disposeBag)

    self.isGivenButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, _ in
        owner.delegate?.tagDidSelected(.isGiven(self.gift.isGiven))
      })
      .disposed(by: self.disposeBag)

    self.relatedFriendsButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, _ in
        owner.delegate?.tagDidSelected(.friends(self.gift.relatedFriends))
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  private func updateGift() {
//    self.emotionButton.configuration?.image = gift.emotion
    self.categoryButton.configuration?.updateAttributedTitle(
      gift.category.rawValue,
      font: .favorFont(.regular, size: 12)
    )
    self.isGivenButton.configuration?.updateAttributedTitle(
      gift.isGiven ? "준 선물" : "받은 선물",
      font: .favorFont(.regular, size: 12)
    )
    let friends = gift.relatedFriends
    guard let firstFriend = friends.first else { return }
    let friendsTitle = friends.count == 1 ? firstFriend.name : "\(firstFriend.name) 외 \(friends.count)"
    self.relatedFriendsButton.configuration?.updateAttributedTitle(
      friendsTitle,
      font: .favorFont(.regular, size: 12)
    )
  }
}

// MARK: - UI Setups

extension GiftDetailTagsCell: BaseView {
  func setupStyles() { }

  func setupLayouts() {
    [
      self.emotionButton,
      self.categoryButton,
      self.isGivenButton,
      self.relatedFriendsButton
    ].forEach {
      self.stackView.addArrangedSubview($0)
    }

    self.addSubview(self.stackView)
  }

  func setupConstraints() {
    self.stackView.snp.makeConstraints { make in
      make.directionalVerticalEdges.equalToSuperview()
      make.leading.equalToSuperview()
      make.trailing.lessThanOrEqualToSuperview()
    }
  }
}
