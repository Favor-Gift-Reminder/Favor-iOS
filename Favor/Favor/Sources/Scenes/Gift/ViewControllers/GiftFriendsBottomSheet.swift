//
//  GiftFriendsBottomSheet.swift
//  Favor
//
//  Created by 이창준 on 6/19/23.
//

import UIKit

import Composer
import FavorKit
import RxCocoa
import RxFlow

public final class GiftFriendsBottomSheet: BaseBottomSheet, Stepper {
  typealias GiftFriendsDataSource = UICollectionViewDiffableDataSource<GiftFriendsSection, GiftFriendsSectionItem>

  // MARK: - Properties

  public var steps = PublishRelay<Step>()

  public var friends: [Friend]? {
    didSet { self.updateSnapshot() }
  }

  private var dataSource: GiftFriendsDataSource?
  private lazy var composer: Composer<GiftFriendsSection, GiftFriendsSectionItem> = {
    let composer = Composer(collectionView: self.collectionView, dataSource: self.dataSource)
    composer.configuration = Composer.Configuration(scrollDirection: .horizontal)
    return composer
  }()

  // MARK: - UI Components

  private var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero, collectionViewLayout: UICollectionViewLayout()
    )
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    collectionView.contentInset = UIEdgeInsets(top: .zero, left: 20, bottom: .zero, right: 20)
    return collectionView
  }()

  // MARK: - Life Cycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.setupDataSource()
    self.composer.compose()
  }

  // MARK: - Bind

  public override func bind() {

  }

  // MARK: - UI Setups

  public override func setupStyles() {
    super.setupStyles()

    self.setUpperButtons(isHidden: true)
    self.updateTitle("주고받은 친구")
  }

  public override func setupLayouts() {
    super.setupLayouts()

    self.containerView.addSubview(self.collectionView)
  }

  public override func setupConstraints() {
    super.setupConstraints()

    self.collectionView.snp.makeConstraints { make in
      make.top.equalTo(self.titleLabel.snp.bottom).offset(60).priority(.low)
      make.directionalHorizontalEdges.equalToSuperview()
      make.bottom.lessThanOrEqualToSuperview().inset(95)
    }
  }
}

// MARK: - Privates

private extension GiftFriendsBottomSheet {
  func setupDataSource() {
    let giftFriendsCellRegistration = UICollectionView.CellRegistration
    <GiftFriendsBottomSheetCell, GiftFriendsSectionItem> { [weak self] cell, _, item in
      guard self != nil else { return }
      cell.bind(item.friend)
    }

    self.dataSource = GiftFriendsDataSource(
      collectionView: self.collectionView,
      cellProvider: { [weak self] collectionView, indexPath, item in
        guard self != nil else { return UICollectionViewCell() }
        return collectionView.dequeueConfiguredReusableCell(
          using: giftFriendsCellRegistration, for: indexPath, item: item)
      }
    )
  }

  func updateSnapshot() {
    guard let friends = self.friends else { return }
    var snapshot = NSDiffableDataSourceSnapshot<GiftFriendsSection, GiftFriendsSectionItem>()
    snapshot.appendSections([.friends])
    let items = friends.map { GiftFriendsSectionItem(friend: $0) }
    snapshot.appendItems(items, toSection: .friends)

    DispatchQueue.main.async {
      self.dataSource?.apply(snapshot)
    }
  }
}
