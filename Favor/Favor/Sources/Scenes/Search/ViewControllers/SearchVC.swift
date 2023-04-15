//
//  SearchVC.swift
//  Favor
//
//  Created by 이창준 on 2023/02/07.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import RxCocoa
import RxDataSources
import RxGesture
import SnapKit

final class SearchViewController: BaseSearchViewController {
  typealias RecentSearchDataSource = RxCollectionViewSectionedReloadDataSource<SearchRecentSection.SearchRecentModel>
  
  // MARK: - Constants
  
  let giftCategories: [String] = ["가벼운 선물", "생일", "집들이", "시험", "승진", "졸업", "기타"]
  let emotions: [String] = ["🥹", "🥰", "🙂", "😐", "😰"]

  private enum Constants {
    static let fadeInDuration = 0.15
    static let fadeOutDuration = 0.2
  }
  
  // MARK: - Properties

  private var dataSource = RecentSearchDataSource(
    configureCell: { _, collectionView, indexPath, item in
      switch item {
      case .recent(let recentSearch):
        let cell = collectionView.dequeueReusableCell(for: indexPath) as SearchRecentCell
        cell.updateText(recentSearch)
        return cell
      }
    }, configureSupplementaryView: { _, collectionView, kind, indexPath in
      let header = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        for: indexPath
      ) as SearchRecentHeader
      return header
    }
  )
  
  // MARK: - UI Components
  
  // Gift Category
  private lazy var giftCategoryTitleLabel = self.makeTitleLabel(title: "선물 카테고리")
  
  private lazy var giftCategoryButtonStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 10
    self.giftCategories.forEach {
      stackView.addArrangedSubview(FavorSmallButton(with: .mainWithIcon($0, image: nil)))
    }
    stackView.distribution = .fillProportionally
    return stackView
  }()
  
  private lazy var giftCategoryButtonScrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    return scrollView
  }()
  
  // Emotion
  private lazy var emotionTitleLabel = self.makeTitleLabel(title: "선물 기록")
  
  private lazy var emotionButtonStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.distribution = .equalSpacing
    stackView.spacing = 34
    return stackView
  }()

  // SearchRecent
  private lazy var recentSearchCollectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: self.makeSearchRecentCompositionalLayout()
    )

    // Register
    collectionView.register(cellType: SearchRecentCell.self)
    collectionView.register(
      supplementaryViewType: SearchRecentHeader.self,
      ofKind: SearchRecentCell.reuseIdentifier
    )

    // Setup
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    collectionView.isHidden = true
    return collectionView
  }()
  
  // MARK: - Life Cycle
  
  // MARK: - Binding

  override func bind() {
    guard let reactor = self.reactor else { return }

    // Action
    self.recentSearchCollectionView.rx.modelSelected(SearchRecentSection.SearchRecentItem.self)
      .map { item in Reactor.Action.searchRecentDidSelected(item) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { [$0.searchRecents] }
      .bind(to: self.recentSearchCollectionView.rx.items(dataSource: self.dataSource))
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
    self.giftCategories.forEach {
      self.giftCategoryButtonStack.addArrangedSubview(FavorSmallButton(with: .gray($0)))
    }
    self.giftCategoryButtonScrollView.addSubview(self.giftCategoryButtonStack)

    self.emotions.forEach {
      self.emotionButtonStack.addArrangedSubview(self.makeEmojiButton(emoji: $0))
    }

    [
      self.searchTextField,
      self.giftCategoryTitleLabel,
      self.giftCategoryButtonScrollView,
      self.emotionTitleLabel,
      self.emotionButtonStack,
      self.recentSearchCollectionView
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
      make.top.equalTo(self.searchTextField.snp.bottom).offset(56)
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

    self.recentSearchCollectionView.snp.makeConstraints { make in
      make.top.equalTo(self.searchTextField.snp.bottom).offset(40)
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
  
  func makeEmojiButton(emoji: String) -> UIButton {
    let button = UIButton()
    button.contentMode = .center
    button.setImage(emoji.emojiToImage(size: .init(width: 40, height: 40)), for: .normal)
    return button
  }

  func toggleRecentSearch(to isHidden: Bool) {
    let duration = isHidden ? Constants.fadeInDuration : Constants.fadeOutDuration
    self.recentSearchCollectionView.isHidden = false
    let animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) {
      self.recentSearchCollectionView.layer.opacity = isHidden ? 0.0 : 1.0
    }
    animator.addCompletion { _ in
      self.recentSearchCollectionView.isHidden = isHidden
    }
    animator.startAnimation()
  }
}

// MARK: - CollectionView

private extension BaseSearchViewController {
  func makeSearchRecentCompositionalLayout() -> UICollectionViewCompositionalLayout {
    let item = NSCollectionLayoutItem(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .fractionalHeight(1.0)
      )
    )
    let group = UICollectionViewCompositionalLayout.group(
      direction: .vertical,
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(44)
      ),
      subItem: item,
      count: 1
    )
    let section = NSCollectionLayoutSection(group: group)

    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(21)
      ),
      elementKind: SearchRecentCell.reuseIdentifier,
      alignment: .topLeading
    )
    section.boundarySupplementaryItems = [header]

    section.contentInsets = NSDirectionalEdgeInsets(
      top: 16,
      leading: 20,
      bottom: 16,
      trailing: 20
    )

    let layout = UICollectionViewCompositionalLayout(section: section)
    return layout
  }
}
