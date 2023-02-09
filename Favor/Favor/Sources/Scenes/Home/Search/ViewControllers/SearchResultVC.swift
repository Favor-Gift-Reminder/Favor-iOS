//
//  SearchResultVC.swift
//  Favor
//
//  Created by 이창준 on 2023/02/09.
//

import UIKit

import ReactorKit
import RxSwift
import SnapKit

final class SearchResultViewController: BaseViewController, View {
  
  // MARK: - Constants
  
  // MARK: - Properties
  
  // MARK: - UI Components
  
  private lazy var searchBar: FavorSearchBar = {
    let searchBar = FavorSearchBar()
    return searchBar
  }()
  
  // MARK: - Life Cycle
  
  // MARK: - Binding
  
  func bind(reactor: SearchResultReactor) {
    //
  }
  
  // MARK: - Functions
  
  // MARK: - UI Setups
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func setupLayouts() {
    [
      self.searchBar
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.searchBar.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide)
      make.leading.trailing.equalTo(self.view.layoutMarginsGuide)
    }
  }
}
