//
//  FriendSectionCollectionHeader.swift
//  Favor
//
//  Created by 이창준 on 2023/04/25.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import SnapKit

final class FriendSectionCollectionHeader: UICollectionReusableView, Reusable, View {

  // MARK: - Constants

  // MARK: - Properties

  public var disposeBag = DisposeBag()

  // MARK: - UI Components

  private let searchBar: FavorSearchBar = {
    let searchBar = FavorSearchBar()
    searchBar.hasBackButton = false
    searchBar.placeholder = "친구를 검색해보세요"
    return searchBar
  }()

  private let addButton: FavorAddButton = {
    let button = FavorAddButton()
    button.titleString = "직접 추가하기"
    return button
  }()

  private let divider = FavorDivider()

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Binding

  func bind(reactor: FriendSectionCollectionHeaderReactor) {
    // Action

    // State

  }

  // MARK: - Functions

}

// MARK: - UI Setups

extension FriendSectionCollectionHeader: BaseView {
  func setupStyles() { }

  func setupLayouts() {
    [
      self.searchBar,
      self.addButton,
      self.divider
    ].forEach {
      self.addSubview($0)
    }
  }

  func setupConstraints() {
    self.searchBar.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.directionalHorizontalEdges.equalToSuperview()
    }

    self.addButton.snp.makeConstraints { make in
      make.top.equalTo(self.searchBar.snp.bottom).offset(32)
      make.directionalHorizontalEdges.equalToSuperview()
    }

    self.divider.snp.makeConstraints { make in
      make.top.equalTo(self.addButton.snp.bottom).offset(16)
      make.directionalHorizontalEdges.equalToSuperview()
    }
  }
}
