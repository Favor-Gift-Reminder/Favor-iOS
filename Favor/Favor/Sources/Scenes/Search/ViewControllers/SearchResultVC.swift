//
//  SearchResultVC.swift
//  Favor
//
//  Created by 이창준 on 2023/02/09.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import RxDataSources
import RxGesture
import RxSwift
import SnapKit

final class SearchResultViewController: BaseSearchViewController {
  typealias SearchGiftResultDataSource = RxCollectionViewSectionedReloadDataSource<SearchResultSection.SearchGiftResultModel>
  
  // MARK: - Constants
  
  // MARK: - Properties

  private let dataSource = SearchGiftResultDataSource(
    configureCell: { _, collectionView, indexPath, item in
      switch item {
      case .gift(let reactor):
        let cell = collectionView.dequeueReusableCell(for: indexPath) as SearchGiftResultCell
        cell.reactor = reactor
        return cell
      case .user(let reactor):
        let cell = collectionView.dequeueReusableCell(for: indexPath) as SearchUserResultCell
        cell.reactor = reactor
        return cell
      }
    }
  )
  
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
  private lazy var giftCollectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: self.makeCompositionalLayout()
    )

    // register
    collectionView.register(cellType: SearchGiftResultCell.self)
    collectionView.register(cellType: SearchUserResultCell.self)

    // Configure
    collectionView.showsHorizontalScrollIndicator = false
    return collectionView
  }()
  
  // MARK: - Life Cycle
  
  // MARK: - Binding

  override func bind() {
    guard let reactor = self.reactor else { return }

    // Action

    // State
    reactor.state
      .map { state in
        switch state.selectedSearchType {
        case .gift:
          return [state.giftResults]
        case .user:
          return [state.userResult]
        }
      }
      .bind(to: self.giftCollectionView.rx.items(dataSource: self.dataSource))
      .disposed(by: self.disposeBag)
  }
  
  override func bind(reactor: SearchViewReactor) {
    super.bind(reactor: reactor)
    
    // Action
    self.giftSelectedButton.rx.tap
      .map { Reactor.Action.searchTypeDidSelected(.gift) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.userSelectedButton.rx.tap
      .map { Reactor.Action.searchTypeDidSelected(.user) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.giftCollectionView.rx.didScroll
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
      .skip(1)
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, selected in
        owner.updateSelectedSearchButton(to: selected)
        owner.giftCollectionView.isScrollEnabled = selected == .gift
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
      self.searchTextField,
      self.buttonStack,
      self.giftCollectionView
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
      make.leading.trailing.equalTo(self.view.layoutMarginsGuide)
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

    self.giftCollectionView.snp.makeConstraints { make in
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
}

// MARK: - CollectionView

private extension SearchResultViewController {
  func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
    return UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, _ in
      let sectionType = self.dataSource[sectionIndex].model
      return self.makeCompositionalSection(sectionType: sectionType)
    })
  }

  func makeCompositionalSection(
    sectionType: SearchResultSectionType
  ) -> NSCollectionLayoutSection {
    let item = NSCollectionLayoutItem(
      layoutSize: sectionType.cellSize
    )

    let group = UICollectionViewCompositionalLayout.group(
      direction: .horizontal,
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: sectionType.cellSize.heightDimension
      ),
      subItem: item,
      count: sectionType.columns
    )
    group.interItemSpacing = .fixed(sectionType.spacing)

    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = sectionType.sectionInset
    section.interGroupSpacing = sectionType.spacing

    return section
  }
}
