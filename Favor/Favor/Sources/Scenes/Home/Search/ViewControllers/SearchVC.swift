//
//  SearchVC.swift
//  Favor
//
//  Created by 이창준 on 2023/02/07.
//

import UIKit

import ReactorKit
import RxCocoa
import SnapKit

final class SearchViewController: BaseViewController, View {
  
  // MARK: - Constants
  
  let giftCategories: [String] = ["가벼운 선물", "생일", "집들이", "시험", "승진", "졸업", "기타"]
  let emotions: [String] = ["🥹", "🥰", "🙂", "😐", "😰"]
  
  // MARK: - Properties
  
  // MARK: - UI Components
  
  // SearchBar
  private lazy var backButton: UIButton = {
    var configuration = UIButton.Configuration.plain()
    configuration.baseForegroundColor = .favorColor(.typo)
    configuration.image = UIImage(systemName: "chevron.backward")
    
    let button = UIButton(configuration: configuration)
    return button
  }()
  
  private lazy var searchBar: FavorSearchBar = {
    let searchBar = FavorSearchBar()
    searchBar.height = 40
    searchBar.placeholder = "선물, 유저 ID를 검색해보세요"
    searchBar.autocapitalizationType = .none
    return searchBar
  }()
  
  private lazy var searchStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 18
    stackView.alignment = .center
    [
      self.backButton,
      self.searchBar
    ].forEach {
      stackView.addArrangedSubview($0)
    }
    return stackView
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
    self.backButton.rx.tap
      .map { Reactor.Action.backButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.searchBar.searchTextField.rx.controlEvent([.editingDidBegin])
      .map { Reactor.Action.searchDidBegin }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.searchBar.searchTextField.rx.controlEvent([.editingDidEnd])
      .map { Reactor.Action.searchDidEnd }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.searchBar.searchTextField.rx.controlEvent([.editingDidEndOnExit])
      .subscribe(onNext: {
        self.searchBar.searchTextField.resignFirstResponder()
      })
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { $0.isEditing }
      .asDriver(onErrorJustReturn: false)
      .drive(with: self, onNext: { owner, isEditing in
        let duration = isEditing ? 0.3 : 0.4
        DispatchQueue.main.async {
          UIView.animate(withDuration: duration) {
            owner.backButton.isHidden = isEditing
          }
        }
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
      self.searchStack,
      self.giftCategoryTitleLabel,
      self.giftCategoryButtonScrollView,
      self.emotionTitleLabel,
      self.emotionButtonStack
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.backButton.snp.makeConstraints { make in
      make.width.height.equalTo(48)
    }
    self.searchStack.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide)
      make.leading.trailing.equalTo(self.view.layoutMarginsGuide)
      make.height.greaterThanOrEqualTo(48)
    }
    
    self.giftCategoryTitleLabel.snp.makeConstraints { make in
      make.top.equalTo(self.searchStack.snp.bottom).offset(56)
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
