//
//  GiftDetailVC.swift
//  Favor
//
//  Created by 이창준 on 2023/05/25.
//

import UIKit

import FavorKit
import ReactorKit
import SnapKit

final class GiftDetailViewController: BaseViewController, View {
  typealias GiftDetailDataSource = UICollectionViewDiffableDataSource<GiftDetailSection, GiftDetailSectionItem>

  // MARK: - Constants

  private enum Metric {
    static let imageCarouselHeight: CGFloat = 330.0
  }

  // MARK: - Properties

  private var dataSource: GiftDetailDataSource?

  // MARK: - UI Components

  // Navigation Bar
  private let editButton = FavorBarButtonItem(.edit)
  private let deleteButton = FavorBarButtonItem(.delete)
  private let shareButton = FavorBarButtonItem(.share)

  // Image Carousel
  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewLayout()
    )

    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    return collectionView
  }()

  private lazy var adapter: Adapter<GiftDetailSection, GiftDetailSectionItem> = {
    let adapter = Adapter(collectionView: self.collectionView, dataSource: self.dataSource)
    adapter.configuration = Adapter.Configuration(
      scrollDirection: .vertical,
      sectionSpacing: 24
    )
    return adapter
  }()

  private let pageLabel = FavorPageLabelView()

  // MARK: - Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.setupDataSource()
    self.adapter.adapt()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.setupNavigationBar()
  }

  // MARK: - Binding

  func bind(reactor: GiftDetailViewReactor) {
    // Action
    self.editButton.rx.tap
      .map { Reactor.Action.editButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.deleteButton.rx.tap
      .map { Reactor.Action.deleteButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.shareButton.rx.tap
      .map { Reactor.Action.shareButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State
    Observable.combineLatest(self.rx.viewDidLoad, reactor.state.map { $0.items })
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, items in
        guard let dataSource = owner.dataSource else { return }
        let items = items.1

        var snapshot = NSDiffableDataSourceSnapshot<GiftDetailSection, GiftDetailSectionItem>()
        let sections: [GiftDetailSection] = [.image, .title, .tags, .memo]
        snapshot.appendSections(sections)
        items.enumerated().forEach { idx, item in
          snapshot.appendItems(item, toSection: sections[idx])
        }

        DispatchQueue.main.async {
          dataSource.apply(snapshot)
        }
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  // MARK: - UI Setups

  private func setupNavigationBar() {
    self.navigationItem.setRightBarButtonItems(
      [self.shareButton, self.deleteButton, self.editButton],
      animated: false
    )
  }

  override func setupLayouts() {
    [
      self.collectionView,
      self.pageLabel
    ].forEach {
      self.view.addSubview($0)
    }
  }

  override func setupConstraints() {
    self.collectionView.snp.makeConstraints { make in
      make.directionalVerticalEdges.equalTo(self.view.safeAreaLayoutGuide)
      make.directionalHorizontalEdges.equalToSuperview()
    }

    self.pageLabel.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide).offset(284)
      make.trailing.equalTo(self.collectionView.snp.trailing).offset(-16)
    }
  }
}

// MARK: - Privates

private extension GiftDetailViewController {
  func setupDataSource() {
    let imageCellRegistration = UICollectionView.CellRegistration<GiftDetailImageCell, GiftDetailSectionItem> {
      [weak self] cell, indexPath, item in
      guard
        let self = self,
        case let GiftDetailSectionItem.image(image) = item
      else { return }
    }

    let titleCellRegistration = UICollectionView.CellRegistration<GiftDetailTitleCell, GiftDetailSectionItem>
      { [weak self] cell, indexPath, itemIdentifier in
      guard
        let self = self
      else { return }
    }

    let tagsCellRegistration = UICollectionView.CellRegistration<GiftDetailTagsCell, GiftDetailSectionItem>
      { [weak self] cell, indexPath, itemIdentifier in
      guard
        let self = self
      else { return }
    }

    let memoCellRegistration = UICollectionView.CellRegistration<GiftDetailMemoCell, GiftDetailSectionItem>
      { [weak self] cell, indexPath, itemIdentifier in
      guard
        let self = self
      else { return }
    }

    self.dataSource = GiftDetailDataSource(
      collectionView: self.collectionView,
      cellProvider: { [weak self] collectionView, indexPath, item in
        guard let self = self else { return UICollectionViewCell() }
        switch item {
        case .image:
          return collectionView.dequeueConfiguredReusableCell(using: imageCellRegistration, for: indexPath, item: item)
        case .title:
          return collectionView.dequeueConfiguredReusableCell(using: titleCellRegistration, for: indexPath, item: item)
        case .tags:
          return collectionView.dequeueConfiguredReusableCell(using: tagsCellRegistration, for: indexPath, item: item)
        case .memo:
          return collectionView.dequeueConfiguredReusableCell(using: memoCellRegistration, for: indexPath, item: item)
        }
      }
    )
  }
}
