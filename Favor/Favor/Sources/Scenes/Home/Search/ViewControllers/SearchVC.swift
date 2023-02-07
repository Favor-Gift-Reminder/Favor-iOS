//
//  SearchVC.swift
//  Favor
//
//  Created by 이창준 on 2023/02/07.
//

import UIKit

import ReactorKit
import SnapKit

final class SearchViewController: BaseViewController, View {
  
  // MARK: - Constants
  
  // MARK: - Properties
  
  // MARK: - UI Components
  
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
    return searchBar
  }()
  
  private lazy var searchStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 26
    stackView.alignment = .center
    [
      self.backButton,
      self.searchBar
    ].forEach {
      stackView.addArrangedSubview($0)
    }
    return stackView
  }()
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - Binding
  
  func bind(reactor: SearchReactor) {
    //
  }
  
  // MARK: - Functions
  
  // MARK: - UI Setups
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func setupLayouts() {
    [
      self.searchStack
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
      make.leading.equalTo(self.view.layoutMarginsGuide)
      make.trailing.equalToSuperview().inset(6)
    }
  }
}
