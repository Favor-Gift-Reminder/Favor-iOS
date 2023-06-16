//
//  SearchVC.swift
//  Favor
//
//  Created by 이창준 on 2023/02/07.
//

import UIKit

import Composer
import FavorKit
import ReactorKit
import RxCocoa
import SnapKit

final class SearchViewController: BaseSearchViewController {
  typealias SearchDataSource = UICollectionViewDiffableDataSource<SearchSection, SearchSectionItem>

  // MARK: - Constants

  private enum Constants {
    static let fadeInDuration = 0.15
    static let fadeOutDuration = 0.2
  }
  
  // MARK: - Properties

  private var dataSource: SearchDataSource?

  private lazy var composer: Composer<SearchSection, SearchSectionItem> = {
    let composer = Composer(collectionView: self.collectionView, dataSource: self.dataSource)
    return composer
  }()

  // MARK: - UI Components
  
  // Gift Category
  private lazy var giftCategoryTitleLabel = self.makeTitleLabel(title: "선물 카테고리")

  private lazy var giftCategoryButtonStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 10
    FavorCategory.allCases.forEach {
      stackView.addArrangedSubview(FavorSmallButton(with: .gray($0.rawValue)))
    }
    stackView.distribution = .fillProportionally
    return stackView
  }()
  
  private lazy var giftCategoryButtonScrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    scrollView.canCancelContentTouches = true
    return scrollView
  }()
  
  // Emotion
  private lazy var emotionTitleLabel = self.makeTitleLabel(title: "선물 기록")
  
  private lazy var emotionButtonStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.distribution = .equalCentering
    return stackView
  }()

  // RecentSearchObject
  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewLayout()
    )
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.contentInset = UIEdgeInsets(top: 40, left: .zero, bottom: .zero, right: .zero)
    return collectionView
  }()

  // MARK: - Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.setupDataSource()
    self.composer.compose()
  }

  // MARK: - Binding

  override func bind(reactor: SearchViewReactor) {
    super.bind(reactor: reactor)

    // Action
    Observable.combineLatest(self.rx.viewDidAppear, self.rx.viewWillAppear)
      .throttle(.nanoseconds(500), scheduler: MainScheduler.instance)
      .map { _ in Reactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.giftCategoryButtonStack.arrangedSubviews.forEach { arrangedView in
      guard let button = arrangedView as? FavorSmallButton else { return }
      button.rx.tap
        .map { Reactor.Action.categoryButtonDidTap(button.category) }
        .bind(to: reactor.action)
        .disposed(by: self.disposeBag)
    }

    self.emotionButtonStack.arrangedSubviews.forEach { arrangedView in
      guard let button = arrangedView as? FavorEmotionButton else { return }
      button.rx.tap
        .map { Reactor.Action.emotionButtonDidTap(button.emotion) }
        .bind(to: reactor.action)
        .disposed(by: self.disposeBag)
    }

    self.collectionView.rx.itemSelected
      .map { indexPath -> Reactor.Action in
        guard let item = self.dataSource?.itemIdentifier(for: indexPath) else { return .doNothing }
        switch item {
        case .recent(let searchString):
          return .searchRecentDidSelected(searchString.queryString)
        }
      }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { $0.recentSearchItems }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, searches in
        guard let dataSource = owner.dataSource else { return }
        var snapshot = NSDiffableDataSourceSnapshot<SearchSection, SearchSectionItem>()
        snapshot.appendSections([.recent])
        snapshot.appendItems(searches, toSection: .recent)

        DispatchQueue.main.async {
          dataSource.apply(snapshot)
        }
      })
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions

  override func toggleIsEditing(to isEditing: Bool) {
    super.toggleIsEditing(to: isEditing)
    
    self.toggleRecentSearch(to: !isEditing)
  }
  
  // MARK: - UI Setups
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func setupLayouts() {
    self.giftCategoryButtonScrollView.addSubview(self.giftCategoryButtonStack)

    FavorEmotion.allCases.forEach {
      self.emotionButtonStack.addArrangedSubview(FavorEmotionButton($0))
    }

    [
      self.searchTextField,
      self.giftCategoryTitleLabel,
      self.giftCategoryButtonScrollView,
      self.emotionTitleLabel,
      self.emotionButtonStack,
      self.collectionView
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.searchTextField.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }
    
    self.giftCategoryTitleLabel.snp.makeConstraints { make in
      make.top.equalTo(self.searchTextField.snp.bottom).offset(40)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }
    self.giftCategoryButtonScrollView.snp.makeConstraints { make in
      make.top.equalTo(self.giftCategoryTitleLabel.snp.bottom).offset(16)
      make.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(32)
    }
    self.giftCategoryButtonStack.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.height.equalToSuperview()
    }
    
    self.emotionTitleLabel.snp.makeConstraints { make in
      make.top.equalTo(self.giftCategoryButtonScrollView.snp.bottom).offset(56)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }
    self.emotionButtonStack.snp.makeConstraints { make in
      make.top.equalTo(self.emotionTitleLabel.snp.bottom).offset(16)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
      make.height.equalTo(40)
    }

    self.collectionView.snp.makeConstraints { make in
      make.top.equalTo(self.searchTextField.snp.bottom)
      make.directionalHorizontalEdges.equalToSuperview()
      make.bottom.equalTo(self.view.safeAreaLayoutGuide)
    }
  }
}

// MARK: - Privates

private extension SearchViewController {
  func makeTitleLabel(title: String) -> UILabel {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 18)
    label.textColor = .favorColor(.icon)
    label.text = title
    return label
  }

  func toggleRecentSearch(to isHidden: Bool) {
    let duration = isHidden ? Constants.fadeInDuration : Constants.fadeOutDuration
    self.collectionView.isHidden = false
    let animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) {
      self.collectionView.layer.opacity = isHidden ? 0.0 : 1.0
    }
    animator.addCompletion { _ in
      self.collectionView.isHidden = isHidden
    }
    animator.startAnimation()
  }

  func setupDataSource() {
    let searchCellRegistration = UICollectionView.CellRegistration
    <SearchRecentCell, SearchSectionItem> { [weak self] cell, _, item in
      guard
        self != nil,
        case let SearchSectionItem.recent(recentSearch) = item
      else { return }
      cell.delegate = self
      cell.bind(with: recentSearch)
    }

    self.dataSource = SearchDataSource(
      collectionView: self.collectionView,
      cellProvider: { collectionView, indexPath, item in
        switch item {
        case .recent:
          return collectionView.dequeueConfiguredReusableCell(
            using: searchCellRegistration, for: indexPath, item: item)
        }
      }
    )

    let headerRegistration = UICollectionView.SupplementaryRegistration
    <FavorSectionHeaderView>(elementKind: UICollectionView.elementKindSectionHeader
    ) { [weak self] header, _, _ in
      guard self != nil else { return }
      header.bind(title: "최근 검색어")
    }

    self.dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
      guard self != nil else { return UICollectionReusableView() }
      switch kind {
      case UICollectionView.elementKindSectionHeader:
        return collectionView.dequeueConfiguredReusableSupplementary(
          using: headerRegistration, for: indexPath)
      default:
        return UICollectionReusableView()
      }
    }
  }
}

// MARK: - SearchRecentCell

extension SearchViewController: SearchRecentCellDelegate {
  func deleteButtonDidTap(_ recentSearch: RecentSearch) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.searchRecentDeleteButtonDidTap(recentSearch))
  }
}
