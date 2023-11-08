//
//  BaseSearchTagVC.swift
//  Favor
//
//  Created by 이창준 on 6/15/23.
//

import UIKit

import Composer
import FavorKit
import ReactorKit
import SnapKit

public class BaseSearchTagViewController: BaseViewController, View {
  public typealias SearchTagDataSource = UICollectionViewDiffableDataSource<SearchTagSection, SearchTagSectionItem>

  // MARK: - Constants

  // MARK: - Properties

  public var dataSource: SearchTagDataSource?

  public lazy var composer: Composer<SearchTagSection, SearchTagSectionItem> = {
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

  public func bind(reactor: SearchTagViewReactor) {
    // Action
    Observable.combineLatest(
      self.rx.viewDidLoad,
      self.rx.viewWillAppear.map { _ in }
    )
    .debug()
      .map { _ in Reactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.collectionView.rx.itemSelected
      .compactMap { self.dataSource?.itemIdentifier(for: $0) }
      .map { Reactor.Action.itemSelected($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { ($0.sections, $0.giftItems) }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, sectionData in
          let (sections, items) = sectionData
        var snapshot = NSDiffableDataSourceSnapshot<SearchTagSection, SearchTagSectionItem>()
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

  // MARK: - UI Setups
}

// MARK: - DataSource

private extension BaseSearchTagViewController {
  func setupDataSource() {
    let emptyCellRegistration = UICollectionView.CellRegistration
    <FavorEmptyCell, SearchTagSectionItem> { [weak self] cell, _, item in
      guard
        self != nil,
        case let SearchTagSectionItem.empty(image, text) = item
      else { return }
      cell.bindEmptyData(image: image, text: text)
    }

    let giftResultCellRegistration = UICollectionView.CellRegistration
    <SearchGiftResultCell, SearchTagSectionItem> { [weak self] cell, _, item in
      guard
        self != nil,
        case let SearchTagSectionItem.gift(gift) = item
      else { return }
      cell.bind(with: gift)
    }

    self.dataSource = SearchTagDataSource(
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
