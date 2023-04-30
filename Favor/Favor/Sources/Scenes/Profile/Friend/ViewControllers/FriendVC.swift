//
//  FriendVC.swift
//  Favor
//
//  Created by 이창준 on 2023/04/25.
//

import UIKit

import FavorKit
import ReactorKit
import RxDataSources
import SnapKit

final class FriendViewController: BaseViewController, View {
  typealias FriendDataSource = RxCollectionViewSectionedReloadDataSource<FriendSection>

  // MARK: - Constants

  // MARK: - Properties

  private lazy var dataSource = FriendDataSource(
    configureCell: { _, collectionView, indexPath, items in
      switch items {
      case .friend(let reactor):
        let cell = collectionView.dequeueReusableCell(for: indexPath) as FriendCell
        cell.reactor = reactor
        return cell
      }
    }, configureSupplementaryView: { [weak self] dataSource, collectionView, kind, indexPath in
      switch kind {
      case FriendSectionCollectionHeader.reuseIdentifier:
        let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          for: indexPath
        ) as FriendSectionCollectionHeader
        let collectionHeaderReactor = FriendSectionCollectionHeaderReactor()
        header.reactor = collectionHeaderReactor
        return header
      case UICollectionView.elementKindSectionHeader:
        let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          for: indexPath
        ) as FriendSectionHeader
        let numberOfFriends = dataSource[indexPath.section].items.count
        header.bind(title: "전체", numberOfFriends: numberOfFriends)
        return header
      default:
        return UICollectionReusableView()
      }
    }
  )
  private lazy var adapter = Adapter(dataSource: self.dataSource)

  // MARK: - UI Components

  private let editButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.background.backgroundColor = .clear
    config.updateAttributedTitle("편집", font: .favorFont(.bold, size: 18))

    let button = UIButton(configuration: config)
    return button
  }()

  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: self.adapter.build(
        scrollDirection: .vertical,
        header: .header(
          height: .absolute(185),
          contentInsets: NSDirectionalEdgeInsets(
            top: 32,
            leading: 20,
            bottom: 16,
            trailing: 20
          ),
          kind: FriendSectionCollectionHeader.reuseIdentifier
        )
      )
    )

    // Register
    collectionView.register(cellType: FriendCell.self)
    collectionView.register(
      supplementaryViewType: FriendSectionCollectionHeader.self,
      ofKind: FriendSectionCollectionHeader.reuseIdentifier
    )
    collectionView.register(
      supplementaryViewType: FriendSectionHeader.self,
      ofKind: UICollectionView.elementKindSectionHeader
    )

    return collectionView
  }()

  // MARK: - Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.setupNavigationBar()
  }

  // MARK: - Binding

  override func bind() {
    guard let reactor = self.reactor else { return }

    // Action

    // State
    reactor.state.map { $0.sections }
      .bind(to: self.collectionView.rx.items(dataSource: self.dataSource))
      .disposed(by: self.disposeBag)
  }

  func bind(reactor: FriendViewReactor) {
    // Action
    self.editButton.rx.tap
      .map { Reactor.Action.editButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State

  }

  // MARK: - Functions

  private func setupNavigationBar() {
    self.navigationItem.setRightBarButton(self.editButton.toBarButtonItem(), animated: false)
  }

  // MARK: - UI Setups

  override func setupLayouts() {
    self.view.addSubview(self.collectionView)
  }

  override func setupConstraints() {
    self.collectionView.snp.makeConstraints { make in
      make.directionalVerticalEdges.equalTo(self.view.safeAreaLayoutGuide)
      make.directionalHorizontalEdges.equalToSuperview()
    }
  }
}
