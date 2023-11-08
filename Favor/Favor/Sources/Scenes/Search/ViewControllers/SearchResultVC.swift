//
//  SearchResultVC.swift
//  Favor
//
//  Created by 이창준 on 2023/02/09.
//

import UIKit

import Composer
import FavorKit
import ReactorKit
import RxGesture
import SnapKit

final class SearchResultViewController: BaseSearchViewController {
  typealias SearchResultDataSource = UICollectionViewDiffableDataSource<SearchResultSection, SearchResultSectionItem>

  // MARK: - Constants
  
  // MARK: - Properties
  
  private var dataSource: SearchResultDataSource?
  
  private lazy var composer: Composer<SearchResultSection, SearchResultSectionItem> = {
    let composer = Composer(collectionView: self.collectionView, dataSource: self.dataSource)
    return composer
  }()

  // MARK: - UI Components

  // Search Selected
  private lazy var giftSelectedButton = self.makeSelectedSearchButton(with: "선물")
  private lazy var userSelectedButton = self.makeSelectedSearchButton(with: "유저")

  private lazy var buttonStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    return stackView
  }()

  private let selectedIndicatorBarView = SelectedIndicatorBar()

  // Contents
  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewLayout()
    )
    collectionView.showsVerticalScrollIndicator = false
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.alwaysBounceVertical = false
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
    self.rx.viewDidLoad
      .throttle(.nanoseconds(500), scheduler: MainScheduler.instance)
      .map { _ in Reactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.giftSelectedButton.rx.tap
      .map { Reactor.Action.searchTypeDidSelected(.gift) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.userSelectedButton.rx.tap
      .map { Reactor.Action.searchTypeDidSelected(.user) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.collectionView.rx.didScroll
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, _ in
        owner.view.endEditing(true)
      })
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { $0.searchQuery }
      .take(1) // 최초 1회만 필요
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, searchString in
        owner.searchTextField.textField.text = searchString
      })
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.selectedSearchType }
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, selected in
        owner.updateSelectedSearchButton(to: selected)
        owner.collectionView.isScrollEnabled = selected == .gift
      })
      .disposed(by: self.disposeBag)
    
    reactor.state.map { state -> [SearchResultSectionItem] in
      switch state.selectedSearchType {
      case .gift:
        return state.giftSearchResultItems
      case .user:
        return state.userSearchResultItems
      }
    }
    .asDriver(onErrorRecover: { _ in return .empty()})
    .drive(with: self, onNext: { owner, items in
      guard let firstItem = items.first else { return }
      var snapshot = NSDiffableDataSourceSnapshot<SearchResultSection, SearchResultSectionItem>()
      switch firstItem {
      case .empty:
        snapshot.appendSections([.result(.empty)])
        snapshot.appendItems(items, toSection: .result(.empty))
      case .gift:
        snapshot.appendSections([.result(.gift)])
        snapshot.appendItems(items, toSection: .result(.gift))
      case .user:
        snapshot.appendSections([.result(.user)])
        snapshot.appendItems(items, toSection: .result(.user))
      }
      DispatchQueue.main.async {
        owner.dataSource?.apply(snapshot, animatingDifferences: true)
      }
    })
    .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions

  public func requestSearchQuery(with searchQuery: String) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.searchRequestedWith(searchQuery))
  }

  // MARK: - UI Setups
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func setupLayouts() {
    [
      self.searchTextField,
      self.buttonStack,
      self.collectionView
    ].forEach {
      self.view.addSubview($0)
    }

    [
      self.giftSelectedButton,
      self.userSelectedButton
    ].forEach {
      self.buttonStack.addArrangedSubview($0)
    }
    self.buttonStack.addSubview(self.selectedIndicatorBarView)
  }
  
  override func setupConstraints() {
    self.searchTextField.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }

    self.buttonStack.snp.makeConstraints { make in
      make.top.equalTo(self.searchTextField.snp.bottom).offset(4)
      make.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(56)
    }

    self.selectedIndicatorBarView.snp.makeConstraints { make in
      make.centerX.equalTo(self.giftSelectedButton.snp.centerX)
      make.bottom.equalToSuperview().inset(0.5)
      make.width.equalTo(40)
      make.height.equalTo(2.5)
    }

    self.collectionView.snp.makeConstraints { make in
      make.top.equalTo(self.buttonStack.snp.bottom)
      make.directionalHorizontalEdges.equalToSuperview()
      make.bottom.equalTo(self.view.safeAreaLayoutGuide)
    }
  }
}

// MARK: - Privates

private extension SearchResultViewController {
  func makeSelectedSearchButton(with title: String) -> UIButton {
    var config = UIButton.Configuration.plain()
    config.updateAttributedTitle(title, font: .favorFont(.regular, size: 18))
    config.background.backgroundColor = .clear

    let button = UIButton(configuration: config)
    button.configurationUpdateHandler = { button in
      switch button.state {
      case .normal:
        button.configuration?.baseForegroundColor = .favorColor(.line2)
      case .selected:
        button.configuration?.baseForegroundColor = .favorColor(.icon)
      default: break
      }
    }

    return button
  }

  func updateSelectedSearchButton(to selected: SearchViewReactor.SearchType) {
    UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
      self.giftSelectedButton.isSelected = selected == .gift
      self.userSelectedButton.isSelected = selected == .user
      let selectedButton = selected == .gift ? self.giftSelectedButton : self.userSelectedButton
      self.selectedIndicatorBarView.snp.remakeConstraints { make in
        make.centerX.equalTo(selectedButton.snp.centerX)
        make.bottom.equalToSuperview().inset(0.5)
        make.width.equalTo(40)
        make.height.equalTo(2.5)
      }
      self.buttonStack.layoutSubviews()
    }.startAnimation()
  }

  func setupDataSource() {
    let emptyCellRegistration = UICollectionView.CellRegistration
    <FavorEmptyCell, SearchResultSectionItem> { [weak self] cell, _, item in
      guard
        self != nil,
        case let SearchResultSectionItem.empty(image, text) = item
      else { return }
      cell.bindEmptyData(image: image, text: text)
    }

    let giftResultCellRegistration = UICollectionView.CellRegistration
    <SearchGiftResultCell, SearchResultSectionItem> { [weak self] cell, _, item in
      guard
        self != nil,
        case let SearchResultSectionItem.gift(gift) = item
      else { return }
      cell.bind(with: gift)
    }
    
    let userResultCellRegistration = UICollectionView.CellRegistration
    <SearchUserResultCell, SearchResultSectionItem> { [weak self] cell, _, item in
      guard
        self != nil,
        case let SearchResultSectionItem.user(user, isAlreadyFriend) = item
      else { return }
      cell.bind(user: user, isAlreadyFriend: isAlreadyFriend)
      cell.delegate = self
    }

    self.dataSource = SearchResultDataSource(
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
        case .user:
          return collectionView.dequeueConfiguredReusableCell(
            using: userResultCellRegistration, for: indexPath, item: item)
        }
      }
    )
  }
}

extension SearchResultViewController: SearchUserResultCellDelegate {
  func addFriendButtonDidTap(_ friendUserNo: Int) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.addFriendButtonDidTap(friendUserNo))
  }
}
