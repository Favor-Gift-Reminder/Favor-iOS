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
  
  private let categoryButton = FavorSmallButton(with: .gray("카테고리"))
  private let isGivenButton = FavorSmallButton(with: .gray("준 선물"))
  private lazy var emotionButton = self.getTagButton()
  private lazy var relatedFriendsButton = self.getTagButton()
  
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
        guard let emotion = self.gift.emotion else { return }
        owner.delegate?.tagDidSelected(.emotion(emotion))
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
        let friends: [Friend] =
        owner.gift.relatedFriends + owner.gift.tempFriends.map { Friend(friendName: $0) }
        owner.delegate?.tagDidSelected(.friends(friends))
      })
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions
  
  private func updateGift() {
    // Emotion
    self.emotionButton.updateEmotion(gift.emotion, size: 16.0)
    // Category
    self.categoryButton.configuration?.updateAttributedTitle(
      gift.category.rawValue,
      font: .favorFont(.regular, size: 12)
    )
    // isGiven
    self.isGivenButton.configuration?.updateAttributedTitle(
      gift.isGiven ? "준 선물" : "받은 선물",
      font: .favorFont(.regular, size: 12)
    )
    // relatedFriends
    self.relatedFriendsButton.leftProfileView = .init(.verySmall)
    let friends: [Friend] = gift.relatedFriends + gift.tempFriends.map { Friend(friendName: $0) }
    self.relatedFriendsButton.isHidden = friends.isEmpty
    guard let firstFriend = friends.first else { return }
    let friendsTitle = friends.count == 1 ? 
    firstFriend.friendName : "\(firstFriend.friendName) 외 \(friends.count - 1)"
    self.relatedFriendsButton.title = friendsTitle
  }
  
  private func getTagButton() -> FavorButton {
    let button = FavorButton()
    button.baseBackgroundColor = .favorColor(.card)
    button.baseForegroundColor = .favorColor(.subtext)
    button.contentInset = .init(top: 8.5, leading: 12, bottom: 8.5, trailing: 12)
    button.font = .favorFont(.regular, size: 12.0)
    button.cornerRadius = 16.0
    return button
  }
}

// MARK: - UI Setups

extension GiftDetailTagsCell: BaseView {
  func setupStyles() {
    self.relatedFriendsButton.imageView?.layer.cornerRadius = 8.0
  }

  func setupLayouts() {
    [
      self.emotionButton,
      self.categoryButton,
      self.isGivenButton,
      self.relatedFriendsButton,
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
