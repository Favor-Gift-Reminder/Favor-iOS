//
//  SearchCategoryVC.swift
//  Favor
//
//  Created by 이창준 on 6/15/23.
//

import UIKit

import Composer
import FavorKit
import ReactorKit
import SnapKit

public final class SearchCategoryViewController: BaseViewController, View {
  typealias SearchCategoryDataSource = UICollectionViewDiffableDataSource<SearchCategorySection, SearchCategorySectionItem>

  // MARK: - Constants

  // MARK: - Properties

  private var dataSource: SearchCategoryDataSource?

  private lazy var composer: Composer<SearchCategorySection, SearchCategorySectionItem> = {
    let composer = Composer(collectionView: self.collectionView, dataSource: self.dataSource)
    composer.configuration = Composer.Configuration(scrollDirection: .vertical)
    return composer
  }()

  // MARK: - UI Components

  private let categoryView: FavorCategoryView = {
    let categoryView = FavorCategoryView()
    categoryView.contentInset = UIEdgeInsets(top: .zero, left: 20, bottom: .zero, right: 20)
    return categoryView
  }()

  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewLayout()
    )

    collectionView.showsHorizontalScrollIndicator = false
    return collectionView
  }()

  // MARK: - Life Cycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.setupDataSource()
    self.composer.compose()
  }

  // MARK: - Binding

  public func bind(reactor: SearchCategoryViewReactor) {
    // Action
    self.rx.viewDidLoad
      .map { Reactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.categoryView.currentCategory
      .distinctUntilChanged()
      .map { Reactor.Action.categoryDidSelected($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { $0.category ?? .lightGift }
      .distinctUntilChanged()
      .observe(on: MainScheduler.asyncInstance)
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, category in
        owner.categoryView.setSelectedCategory(category)
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { ($0.sections, $0.giftItems) }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, sectionData in
        let (sections, items) = sectionData
        var snapshot = NSDiffableDataSourceSnapshot<SearchCategorySection, SearchCategorySectionItem>()
        snapshot.appendSections(sections)
        guard let section = sections.first else { return }
        snapshot.appendItems(items, toSection: section)

        DispatchQueue.main.async {
          owner.dataSource?.apply(snapshot)
        }
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  public func requestCategory(_ category: FavorCategory) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.categoryDidSelected(category))
  }

  // MARK: - UI Setups

  public override func setupLayouts() {
    [
      self.categoryView,
      self.collectionView
    ].forEach {
      self.view.addSubview($0)
    }
  }

  public override func setupConstraints() {
    self.categoryView.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(32)
      make.directionalHorizontalEdges.equalToSuperview()
    }

    self.collectionView.snp.makeConstraints { make in
      make.top.equalTo(self.categoryView.snp.bottom)
      make.directionalHorizontalEdges.equalToSuperview()
      make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
    }
  }
}

// MARK: - DataSource

private extension SearchCategoryViewController {
  func setupDataSource() {
    let emptyCellRegistration = UICollectionView.CellRegistration
    <FavorEmptyCell, SearchCategorySectionItem> { [weak self] cell, _, item in
      guard
        self != nil,
        case let SearchCategorySectionItem.empty(image, text) = item
      else { return }
      cell.bindEmptyData(image: image, text: text)
    }

    let giftResultCellRegistration = UICollectionView.CellRegistration
    <SearchGiftResultCell, SearchCategorySectionItem> { [weak self] cell, _, item in
      guard
        self != nil,
        case let SearchCategorySectionItem.gift(gift) = item
      else { return }
      cell.bind(with: gift)
    }

    self.dataSource = SearchCategoryDataSource(
      collectionView: self.collectionView,
      cellProvider: { [weak self] collectionView, indexPath, item in
        guard self != nil else { return UICollectionViewCell() }
        switch item {
        case .empty:
          return collectionView.dequeueConfiguredReusableCell(
            using: emptyCellRegistration, for: indexPath, item: item)
        case .gift:
          return collectionView.dequeueConfiguredReusableCell(
            using: giftResultCellRegistration, for: indexPath, item: item)
        }
      }
    )
  }
}
