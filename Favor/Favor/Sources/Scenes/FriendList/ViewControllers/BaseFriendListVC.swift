//
//  BaseFriendListVC.swift
//  Favor
//
//  Created by 이창준 on 2023/05/10.
//

import UIKit

import Composer
import FavorKit

public class BaseFriendListViewController: BaseViewController {
  public typealias FriendDataSource = UICollectionViewDiffableDataSource<FriendSection, FriendSectionItem>

  // MARK: - Constants
  
  public enum FriendViewType {
    case list
    case edit
  }

  // MARK: - Properties

  public var viewType: FriendViewType?

  public lazy var dataSource: FriendDataSource = {
    let dataSource = FriendDataSource(
      collectionView: self.collectionView,
      cellProvider: { collectionView, indexPath, item in
        switch item {
        case .empty:
          let cell = collectionView.dequeueReusableCell(for: indexPath) as FavorEmptyCell
          cell.bindEmptyData(image: nil, text: "친구가 없군요? 토닥토닥..")
          return cell
        case .friend(let friend):
          guard let viewType = self.viewType else {
            fatalError("View Type for FriendListViewController is required.")
          }
          switch viewType {
          case .list:
            let cell = collectionView.dequeueReusableCell(for: indexPath) as FriendListCell
            cell.configure(friend)
            return cell
          case .edit:
            let cell = collectionView.dequeueReusableCell(for: indexPath) as FriendListModifyingCell
            cell.configure(
              name: friend.friendName,
              image: friend.profilePhoto
            )
            cell.deleteButton.rx.tap
              .subscribe(with: cell, onNext: { _, _ in
                guard case let FriendSectionItem.friend(friend) = item else { return }
                self.cellButtonDidTap(with: friend)
              })
              .disposed(by: cell.disposeBag)
            return cell
          }
        }
      }
    )
    dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
      switch kind {
      case UICollectionView.elementKindSectionHeader:
        let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          for: indexPath
        ) as FavorSectionHeaderView
        return header
      default:
        return UICollectionReusableView()
      }
    }
    return dataSource
  }()
  public lazy var composer: Composer<FriendSection, FriendSectionItem> = {
    let composer = Composer(collectionView: self.collectionView, dataSource: self.dataSource)
    composer.configuration = Composer.Configuration(scrollDirection: .vertical)
    return composer
  }()

  // MARK: - UI Components

  public lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewLayout()
    )

    // Register
    collectionView.register(cellType: FavorEmptyCell.self)
    collectionView.register(cellType: FriendListCell.self)
    collectionView.register(cellType: FriendListModifyingCell.self)
    collectionView.register(
      supplementaryViewType: FavorSectionHeaderView.self,
      ofKind: UICollectionView.elementKindSectionHeader
    )

    collectionView.showsVerticalScrollIndicator = false
    collectionView.contentInset = UIEdgeInsets(top: 16, left: .zero, bottom: .zero, right: .zero)
    return collectionView
  }()

  // MARK: - Functions

  public func cellButtonDidTap<T>(with data: T) { }
}
