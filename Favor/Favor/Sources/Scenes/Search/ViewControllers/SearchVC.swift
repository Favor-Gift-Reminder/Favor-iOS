//
//  SearchVC.swift
//  Favor
//
//  Created by 이창준 on 2023/02/07.
//

import UIKit

import FavorKit
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
  private lazy var searchTextField: FavorSearchBar = {
    let searchBar = FavorSearchBar()
    searchBar.searchBarHeight = 40
    searchBar.placeholder = "선물, 유저 ID를 검색해보세요"
    return searchBar
  }()
  
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

  private lazy var recentSearchTableView: UITableView = {
    let tableView = UITableView()
    tableView.showsHorizontalScrollIndicator = false
    tableView.showsVerticalScrollIndicator = false
    tableView.isHidden = true
    return tableView
  }()
  
  // MARK: - Life Cycle
  
  // MARK: - Binding
  
  func bind(reactor: SearchViewReactor) {
    // Action
    self.rx.viewDidAppear
      .map { _ in Reactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.searchTextField.rx.backButtonDidTap
      .map { Reactor.Action.backButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.searchTextField.rx.editingDidBegin
      .map { Reactor.Action.editingDidBegin }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.searchTextField.rx.text
      .map { Reactor.Action.textDidChanged($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.searchTextField.rx.editingDidEnd
      .map { Reactor.Action.editingDidEnd }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.view.rx.anyGesture(.tap())
      .when(.recognized)
      .map { _ in Reactor.Action.editingDidEnd }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.searchTextField.rx.editingDidEndOnExit
      .map { Reactor.Action.returnKeyDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { $0.isEditing }
      .distinctUntilChanged()
      .delay(.nanoseconds(100), scheduler: MainScheduler.asyncInstance)
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, isEditing in
        owner.searchTextField.setBackButton(toHidden: isEditing)
        if isEditing {
          owner.searchTextField.textField.becomeFirstResponder()
        } else {
          owner.searchTextField.textField.resignFirstResponder()
        }
        owner.toggleRecentSearch(to: !isEditing)
      })
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions
  
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
      self.recentSearchTableView
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

    self.recentSearchTableView.snp.makeConstraints { make in
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
  
  func makeEmojiButton(emoji: String) -> UIButton {
    let button = UIButton()
    button.contentMode = .center
    button.setImage(emoji.emojiToImage(size: .init(width: 40, height: 40)), for: .normal)
    return button
  }

  func toggleRecentSearch(to isHidden: Bool) {
    let duration = isHidden ? 0.2 : 0.3
    self.recentSearchTableView.isHidden = false
    let animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) {
      self.recentSearchTableView.layer.opacity = isHidden ? 0.0 : 1.0
    }
    animator.addCompletion { _ in
      self.recentSearchTableView.isHidden = isHidden
    }
    animator.startAnimation()
  }
}
