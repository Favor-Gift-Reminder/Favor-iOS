//
//  SearchVC.swift
//  Favor
//
//  Created by 이창준 on 2023/02/07.
//

import UIKit

import ReactorKit
import RxCocoa
import RxGesture
import SnapKit

final class SearchViewController: BaseViewController, View {
  
  // MARK: - Constants
  
  let giftCategories: [String] = ["가벼운 선물", "생일", "집들이", "시험", "승진", "졸업", "기타"]
  let emotions: [String] = ["🥹", "🥰", "🙂", "😐", "😰"]
  
  // MARK: - Properties
  
  // MARK: - UI Components
  
  // SearchBar
  private lazy var searchBar: FavorSearchBar = {
    let searchBar = FavorSearchBar()
    searchBar.searchBarHeight = 40
    searchBar.placeholder = "선물, 유저 ID를 검색해보세요"
    searchBar.searchBar.autocapitalizationType = .none
    return searchBar
  }()
  
  // Gift Category
  private lazy var giftCategoryTitleLabel = self.makeTitleLabel(title: "선물 카테고리")
  
  private lazy var giftCategoryButtonStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 10
    self.giftCategories.forEach {
      stackView.addArrangedSubview(SmallFavorButton(.white, title: $0))
    }
    return stackView
  }()
  
  private lazy var giftCategoryButtonScrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.contentInset = .init(top: 0, left: 20, bottom: 0, right: 20)
    scrollView.addSubview(self.giftCategoryButtonStack)
    return scrollView
  }()
  
  // Emotion
  private lazy var emotionTitleLabel = self.makeTitleLabel(title: "선물 기록")
  
  private lazy var emotionButtonStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 34
    stackView.distribution = .equalSpacing
    self.emotions.forEach {
      stackView.addArrangedSubview(self.makeEmojiButton(emoji: $0))
    }
    return stackView
  }()
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - Binding
  
  func bind(reactor: SearchReactor) {
    // Action
    self.view.rx.anyGesture(.tap())
      .when(.recognized)
      .asDriver(onErrorDriveWith: .empty())
      .drive(with: self, onNext: { owner, _ in
        owner.searchBar.searchBar.searchTextField.resignFirstResponder()
      })
      .disposed(by: self.disposeBag)
    
    self.searchBar.rx.leftItemDidTap
      .map { Reactor.Action.backButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.searchBar.searchBar.searchTextField.rx.controlEvent([.editingDidBegin])
      .map { Reactor.Action.searchDidBegin }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.searchBar.searchBar.searchTextField.rx.controlEvent([.editingDidEnd])
      .map { Reactor.Action.searchDidEnd }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.searchBar.searchBar.searchTextField.rx.controlEvent([.editingDidEndOnExit])
      .do(onNext: {
        self.searchBar.searchBar.searchTextField.resignFirstResponder()
      })
      .map { Reactor.Action.returnKeyDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { $0.isEditing }
      .asDriver(onErrorJustReturn: false)
      .drive(with: self, onNext: { owner, isEditing in
        owner.searchBar.updateLeftItemVisibility(isHidden: isEditing)
      })
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions
  
  // MARK: - UI Setups
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func setupLayouts() {
    [
      self.searchBar,
      self.giftCategoryTitleLabel,
      self.giftCategoryButtonScrollView,
      self.emotionTitleLabel,
      self.emotionButtonStack
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.searchBar.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide)
      make.leading.trailing.equalTo(self.view.layoutMarginsGuide)
    }
    
    self.giftCategoryTitleLabel.snp.makeConstraints { make in
      make.top.equalTo(self.searchBar.snp.bottom).offset(56)
      make.leading.trailing.equalTo(self.view.layoutMarginsGuide)
    }
    self.giftCategoryButtonScrollView.snp.makeConstraints { make in
      make.top.equalTo(self.giftCategoryTitleLabel.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(32)
    }
    self.giftCategoryButtonStack.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.height.equalToSuperview()
    }
    
    self.emotionTitleLabel.snp.makeConstraints { make in
      make.top.equalTo(self.giftCategoryButtonScrollView.snp.bottom).offset(56)
      make.leading.trailing.equalTo(self.view.layoutMarginsGuide)
    }
    self.emotionButtonStack.snp.makeConstraints { make in
      make.top.equalTo(self.emotionTitleLabel.snp.bottom).offset(16)
      make.leading.trailing.equalTo(self.view.layoutMarginsGuide)
      make.height.equalTo(40)
    }
  }
}

// MARK: - Privates

private extension SearchViewController {
  func makeTitleLabel(title: String) -> UILabel {
    let label = UILabel()
    label.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 0)
    label.font = .favorFont(.bold, size: 18)
    label.textColor = .favorColor(.typo)
    label.text = title
    return label
  }
  
  func makeEmojiButton(emoji: String) -> UIButton {
    let button = UIButton()
    button.contentMode = .center
    button.setImage(emoji.emojiToImage(size: .init(width: 40, height: 40)), for: .normal)
    return button
  }
}
