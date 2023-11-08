//
//  GiftDetailVC.swift
//  Favor
//
//  Created by 이창준 on 2023/05/25.
//

import UIKit

import Composer
import FavorKit
import ImageViewer
import ReactorKit
import RxCocoa
import SnapKit

@MainActor
final class GiftDetailViewController: BaseViewController, View {
  typealias GiftDetailDataSource = UICollectionViewDiffableDataSource<GiftDetailSection, GiftDetailSectionItem>

  // MARK: - Constants
  
  // MARK: - Properties
  
  private var dataSource: GiftDetailDataSource?

  private let currentPage = BehaviorRelay<Int>(value: 0)
  private let totalPages = BehaviorRelay<Int>(value: 0)
  private var galleryItems: [GalleryItem] = []

  // MARK: - UI Components

  // Navigation Bar
  private let editButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.image = .favorIcon(.edit)?
      .withRenderingMode(.alwaysTemplate)
    let button = UIButton(configuration: config)
    return button
  }()
  private let deleteButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.image = .favorIcon(.delete)?
      .withRenderingMode(.alwaysTemplate)
    let button = UIButton(configuration: config)
    return button
  }()
  private let shareButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.image = .favorIcon(.share)?
      .withRenderingMode(.alwaysTemplate)
    let button = UIButton(configuration: config)
    return button
  }()

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

  private lazy var composer: Composer<GiftDetailSection, GiftDetailSectionItem> = {
    let composer = Composer(collectionView: self.collectionView, dataSource: self.dataSource)
    composer.configuration = Composer.Configuration(
      scrollDirection: .vertical,
      sectionSpacing: 24
    )
    composer.configuration.visibleItemsInvalidationHandler = (to: .image, { [weak self] _, offset, _ in
      guard let self = self else { return }
      let page = Int(round(offset.x / self.view.bounds.width))
      self.currentPage.accept(page)
    })
    return composer
  }()

  // MARK: - Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupDataSource()
    self.composer.compose()
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
      .asDriver()
      .drive(with: self) { owner, _ in owner.presentRemovalPopup() }
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
      .drive(with: self, onNext: { (owner: GiftDetailViewController, gift: Gift) in
        var totalGifts: Int = gift.photos.count
        totalGifts = gift.photos.isEmpty ? 4 : gift.photos.count
        owner.totalPages.accept(totalGifts)
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions
  
  public func update(gift: Gift) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.giftNeedsUpdated(gift))
    self.presentToast(.giftEdited(gift.name), duration: .short)
  }
  
  // MARK: - UI Setups
  
  private func setupNavigationBar() {
    self.navigationItem.setRightBarButtonItems(
      [
        self.shareButton.toBarButtonItem(),
        self.deleteButton.toBarButtonItem(),
        self.editButton.toBarButtonItem()
      ],
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
    <GiftDetailImageCell, GiftDetailSectionItem> { [weak self] cell, indexPath, _ in
      guard let self = self, let reactor = self.reactor else { return }
      cell.configure(gift: reactor.currentState.gift, index: indexPath.item)
    }
    
    let titleCellRegistration = UICollectionView.CellRegistration
    <GiftDetailTitleCell, GiftDetailSectionItem> { [weak self] cell, _, item in
      guard let self = self, let reactor = self.reactor else { return }
      cell.delegate = self
      cell.gift = reactor.currentState.gift
      
      cell.configurationUpdateHandler = { _, _ in
        cell.gift = reactor.currentState.gift
      }
    }
    
    let tagsCellRegistration = UICollectionView.CellRegistration
    <GiftDetailTagsCell, GiftDetailSectionItem> { [weak self] cell, _, _ in
      guard let self = self, let reactor = self.reactor else { return }
      cell.delegate = self
      cell.gift = reactor.currentState.gift
    }

    let memoCellRegistration = UICollectionView.CellRegistration
    <GiftDetailMemoCell, GiftDetailSectionItem> { [weak self] cell, _, _ in
      guard let self = self, let reactor = self.reactor else { return }
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
  
  /// `deleteButton`을 클릭하면 `Popup`으로 전환되는 메서드
  func presentRemovalPopup() {
    let removalPopup = NewAlertPopup(
      .onlyTitle(
        title: "삭제 하시겠습니까?",
        NewAlertPopup.ActionButtons(reject: "취소", accept: "삭제")
      ),
      identifier: "RemoveGift"
    )
    removalPopup.delegate = self
    removalPopup.modalPresentationStyle = .overFullScreen
    self.present(removalPopup, animated: false)
  }
}

// MARK: - GiftDetailTitleCell

extension GiftDetailViewController: GiftDetailTitleCellDelegate {
  nonisolated func pinButtonDidTap() {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.isPinnedButtonDidTap)
  }
}

// MARK: - GiftDetailTagsCell

extension GiftDetailViewController: GiftDetailTagsCellDelegate {
  nonisolated func tagDidSelected(_ tag: GiftTags) {
    guard let reactor = self.reactor else { return }
    switch tag {
    case .emotion(let emotion):
      reactor.action.onNext(.emotionTagDidTap(emotion))
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
  public func presentImageGallery(index: Int, total: Int) {
    guard let reactor = self.reactor else { return }
    let gift = reactor.currentState.gift
    let cache = ImageCacheManager()
    Task {
      for photo in gift.photos {
        let mapper = CacheKeyMapper(gift: gift, subpath: .image(photo.remote))
        if cache.cacher.isCached(forKey: mapper.key) {
          let image: UIImage? = await cache.fetch(from: mapper)
          self.galleryItems.append(.image { $0(image) })
        } else {
          guard let url = URL(string: photo.remote) else { return }
          let image = try await ImageDownloadManager.downloadImage(with: url)
          cache.cache(image, mapper: mapper)
          self.galleryItems.append(.image { $0(image) })
        }
      }
      let galleryVC = GalleryViewController(
        startIndex: index,
        itemsDataSource: self,
        configuration: self.galleryConfiguration()
      )
      let headerView = GiftDetailPhotoHeaderView()
      headerView.total = total
      
      galleryVC.headerView = headerView
      galleryVC.landedPageAtIndexCompletion = { index in
        headerView.currentIndex = index
      }
      self.present(galleryVC, animated: false)
    }
  }
  
  func itemCount() -> Int {
    guard let reactor = self.reactor else { return 1 }
    return reactor.currentState.gift.photos.count
  }
  
  func provideGalleryItem(_ index: Int) -> ImageViewer.GalleryItem {
    return self.galleryItems[index]
  }
  
  public func galleryConfiguration() -> GalleryConfiguration {
    return [
      .closeButtonMode(.builtIn),
      .closeLayout(.pinLeft(28, 22)),
      .deleteButtonMode(.none),
      .thumbnailsButtonMode(.none),
      .pagingMode(.standard),
      .presentationStyle(.displacement),
      .hideDecorationViewsOnLaunch(false),
      .swipeToDismissMode(.vertical),
      .activityViewByLongPress(false),
      .maximumZoomScale(3.0),
      .swipeToDismissThresholdVelocity(500),
      .doubleTapToZoomDuration(0.3)
    ]
  }
}

// MARK: - RemovalPopup

extension GiftDetailViewController: AlertPopupDelegate {
  /// `AlertPopup`에서 `삭제`버튼을 눌렀을 때 호출됩니다.
  func actionDidSelected(_ isAccepted: Bool, from identifier: String) {
    guard isAccepted else { return }
    self.reactor?.action.onNext(.deleteButtonDidTap)
  }
}
