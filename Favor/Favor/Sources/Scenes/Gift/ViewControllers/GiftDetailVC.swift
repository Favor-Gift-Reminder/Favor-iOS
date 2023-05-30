//
//  GiftDetailVC.swift
//  Favor
//
//  Created by 이창준 on 2023/05/25.
//

import UIKit

import FavorKit
import ImageViewer
import ReactorKit
import RxCocoa
import SnapKit

final class GiftDetailViewController: BaseViewController, View {
  typealias GiftDetailDataSource = UICollectionViewDiffableDataSource<GiftDetailSection, GiftDetailSectionItem>

  // MARK: - Constants

  // MARK: - Properties

  private var dataSource: GiftDetailDataSource?

  private let currentPage = BehaviorRelay<Int>(value: 0)
  private let totalPages = BehaviorRelay<Int>(value: 0)

  // MARK: - UI Components

  // Navigation Bar
  private let editButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.image = .favorIcon(.edit)?
      .withRenderingMode(.alwaysTemplate)
    let button = UIButton(configuration: config)
    return button
  }()
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
    collectionView.contentInset = UIEdgeInsets(top: .zero, left: .zero, bottom: 24, right: .zero)
    return collectionView
  }()

  private lazy var adapter: Adapter<GiftDetailSection, GiftDetailSectionItem> = {
    let adapter = Adapter(collectionView: self.collectionView, dataSource: self.dataSource)
    adapter.configuration = Adapter.Configuration(
      scrollDirection: .vertical,
      sectionSpacing: 24
    )
    adapter.configuration.visibleItemsInvalidationHandler = (to: .image, { [weak self] _, offset, _ in
      guard let self = self else { return }
      let page = Int(round(offset.x / self.view.bounds.width))
      self.currentPage.accept(page)
    })
    return adapter
  }()

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
      .debug()
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

    self.collectionView.rx.itemSelected
      .map { [weak self] indexPath in
        guard
          let self = self,
          let dataSource = self.dataSource
        else { return Reactor.Action.doNothing }
        let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
        if case GiftDetailSection.image = section {
          return Reactor.Action.giftPhotoDidSelected(indexPath.item)
        }
        return Reactor.Action.doNothing
      }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State
    Observable.combineLatest(self.rx.viewDidLoad, reactor.state.map { $0.items })
      .debounce(.milliseconds(100), scheduler: MainScheduler.instance)
      .map { $0.1 }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, items in
        guard let dataSource = owner.dataSource else { return }
        var snapshot = NSDiffableDataSourceSnapshot<GiftDetailSection, GiftDetailSectionItem>()
        let sections: [GiftDetailSection] = [.image, .title, .tags, .memo]
        snapshot.appendSections(sections)
        items.enumerated().forEach { idx, item in
          snapshot.appendItems(item, toSection: sections[idx])
        }

        DispatchQueue.main.async {
          dataSource.apply(snapshot)
          owner.collectionView.collectionViewLayout.invalidateLayout()
        }
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.gift }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, gift in
        var totalGifts = gift.photoList.count
        #if DEBUG
        totalGifts = gift.photoList.isEmpty ? 4 : gift.photoList.count
        #endif
        owner.totalPages.accept(totalGifts)
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  // MARK: - UI Setups

  private func setupNavigationBar() {
    self.navigationItem.setRightBarButtonItems(
      [self.shareButton, self.deleteButton, self.editButton.toBarButtonItem()],
      animated: false
    )
  }

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

// MARK: - Privates

private extension GiftDetailViewController {
  func setupDataSource() {
    let imageCellRegistration = UICollectionView.CellRegistration
    <GiftDetailImageCell, GiftDetailSectionItem> { [weak self] cell, _, itemIdentifier in
      guard
        self != nil,
        case let GiftDetailSectionItem.image(image) = itemIdentifier
      else { return }
      // Image
    }

    let titleCellRegistration = UICollectionView.CellRegistration
    <GiftDetailTitleCell, GiftDetailSectionItem> { [weak self] cell, _, _ in
      guard
        let self = self,
        let reactor = self.reactor
      else { return }
      cell.delegate = self
      cell.gift = reactor.currentState.gift
    }

    let tagsCellRegistration = UICollectionView.CellRegistration
    <GiftDetailTagsCell, GiftDetailSectionItem> { [weak self] cell, _, _ in
      guard
        let self = self,
        let reactor = self.reactor
      else { return }
      cell.delegate = self
      cell.gift = reactor.currentState.gift
    }

    let memoCellRegistration = UICollectionView.CellRegistration
    <GiftDetailMemoCell, GiftDetailSectionItem> { [weak self] cell, _, _ in
      guard
        let self = self,
        let reactor = self.reactor
      else { return }
      cell.gift = reactor.currentState.gift
    }

    self.dataSource = GiftDetailDataSource(
      collectionView: self.collectionView,
      cellProvider: { [weak self] collectionView, indexPath, item in
        guard self != nil else { return UICollectionViewCell() }
        switch item {
        case .image:
          return collectionView.dequeueConfiguredReusableCell(
            using: imageCellRegistration, for: indexPath, item: item)
        case .title:
          return collectionView.dequeueConfiguredReusableCell(
            using: titleCellRegistration, for: indexPath, item: item)
        case .tags:
          return collectionView.dequeueConfiguredReusableCell(
            using: tagsCellRegistration, for: indexPath, item: item)
        case .memo:
          return collectionView.dequeueConfiguredReusableCell(
            using: memoCellRegistration, for: indexPath, item: item)
        }
      }
    )

    let pageFooterRegistration: UICollectionView.SupplementaryRegistration<GiftDetailPageFooterView> = UICollectionView.SupplementaryRegistration<GiftDetailPageFooterView>(
      elementKind: UICollectionView.elementKindSectionFooter
    ) { [weak self] footer, _, indexPath in
      guard
        let self = self,
        indexPath.section == 0
      else { return }
      footer.bind(
        currentPage: self.currentPage.asObservable(),
        totalPages: self.totalPages.asObservable()
      )
    }

    self.dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
      guard self != nil else { return UICollectionReusableView() }
      switch kind {
      case UICollectionView.elementKindSectionFooter:
        return collectionView.dequeueConfiguredReusableSupplementary(
          using: pageFooterRegistration, for: indexPath)
      default:
        return UICollectionReusableView()
      }
    }
  }
}

// MARK: - GiftDetailTitleCell

extension GiftDetailViewController: GiftDetailTitleCellDelegate {
  func pinButtonDidTap() {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.isPinnedButtonDidTap)
  }
}

// MARK: - GiftDetailTagsCell

extension GiftDetailViewController: GiftDetailTagsCellDelegate {
  func tagDidSelected(_ tag: GiftTags) {
    guard let reactor = self.reactor else { return }
    switch tag {
    case .emotion:
      reactor.action.onNext(.emotionTagDidTap)
    case .category(let category):
      reactor.action.onNext(.categoryTagDidTap(category))
    case .isGiven(let isGiven):
      reactor.action.onNext(.isGivenTagDidTap(isGiven))
    case .friends(let friends):
      reactor.action.onNext(.friendsTagDidTap(friends))
    }
    return
  }
}

// MARK: - GalleryView

extension GiftDetailViewController: GalleryItemsDataSource {
  public func presentGalleryImageViewer(startingIndex: Int) {
    
  }

  func itemCount() -> Int {
    guard let reactor = self.reactor else { return 1 }
    return reactor.currentState.gift.photoList.count
  }

  func provideGalleryItem(_ index: Int) -> ImageViewer.GalleryItem {
    return GalleryItem.image { $0(UIImage(named: "MyPageHeaderPlaceholder")) }
  }

  public func galleryConfiguration() -> GalleryConfiguration {
    var config = UIButton.Configuration.plain()
    config.image = .favorIcon(.down)?
      .withRenderingMode(.alwaysTemplate)
    config.baseForegroundColor = .favorColor(.white)
    let closeButton = UIButton(configuration: config)
    return [
      .closeButtonMode(.custom(closeButton)),
      .closeLayout(.pinLeft(28, 22)),
      .deleteButtonMode(.none),
      .thumbnailsButtonMode(.none),
      .pagingMode(.standard),
      .presentationStyle(.fade),
      .hideDecorationViewsOnLaunch(false),
      .swipeToDismissMode(.vertical),
      .activityViewByLongPress(false),
      .maximumZoomScale(3.0),
      .swipeToDismissThresholdVelocity(500),
      .doubleTapToZoomDuration(0.3)
    ]
  }
}
