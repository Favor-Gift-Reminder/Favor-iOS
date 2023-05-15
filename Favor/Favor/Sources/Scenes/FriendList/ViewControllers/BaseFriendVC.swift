//
//  BaseFriendVC.swift
//  Favor
//
//  Created by 이창준 on 2023/05/10.
//

import UIKit

import FavorKit

public class BaseFriendViewController: BaseViewController {
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
        case .friend(let friend):
          guard let viewType = self.viewType else {
            fatalError("View Type for FriendListViewController is required.")
          }
          switch viewType {
          case .list:
            let cell = collectionView.dequeueReusableCell(for: indexPath) as FriendCell
            cell.bind(with: friend)
            return cell
          case .edit:
            let cell = collectionView.dequeueReusableCell(for: indexPath) as EditFriendCell
            cell.bind(with: friend)
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
        ) as FriendListSectionHeader
        return header
      default:
        return UICollectionReusableView()
      }
    }
    return dataSource
  }()
  public lazy var adapter: Adapter<FriendSection, FriendSectionItem> = {
    let adapter = Adapter(collectionView: self.collectionView, dataSource: self.dataSource)
    adapter.configuration = Adapter.Configuration(scrollDirection: .vertical)
    return adapter
  }()

  // MARK: - UI Components

  public lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewLayout()
    )

    // Register
    collectionView.register(cellType: FriendCell.self)
    collectionView.register(cellType: EditFriendCell.self)
    collectionView.register(
      supplementaryViewType: FriendListSectionHeader.self,
      ofKind: UICollectionView.elementKindSectionHeader
    )
    collectionView.register(
      supplementaryViewType: EditFriendCollectionHeaderView.self,
      ofKind: EditFriendCollectionHeaderView.reuseIdentifier
    )

    collectionView.showsVerticalScrollIndicator = false
    collectionView.contentInset = UIEdgeInsets(top: 16, left: .zero, bottom: .zero, right: .zero)
    return collectionView
  }()

  // MARK: - Functions

  public func cellButtonDidTap<T>(with data: T) { }
}
