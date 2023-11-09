//
//  SearchCategoryVC.swift
//  Favor
//
//  Created by 이창준 on 6/15/23.
//

import UIKit

import Composer
import FavorKit
import ReactorKit
import SnapKit

public final class SearchCategoryViewController: BaseSearchTagViewController {

  // MARK: - Constants

  // MARK: - Properties

  // MARK: - UI Components

  private let categoryView: FavorCategoryView = {
    let categoryView = FavorCategoryView()
    categoryView.contentInset = UIEdgeInsets(top: .zero, left: 20, bottom: .zero, right: 20)
    return categoryView
  }()

  // MARK: - Life Cycle

  // MARK: - Binding

  public override func bind(reactor: SearchTagViewReactor) {
    super.bind(reactor: reactor)
    
    // Action
    self.categoryView.currentCategory
      .distinctUntilChanged()
      .map { Reactor.Action.categoryDidSelected($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { $0.category }
      .take(1)
      .observe(on: MainScheduler.asyncInstance)
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, category in
        owner.categoryView.setSelectedCategory(category)
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - UI Setups
  
  public override func setupLayouts() {
    [
      self.categoryView,
      self.collectionView
    ].forEach {
      self.view.addSubview($0)
    }
  }

  public override func setupConstraints() {
    self.categoryView.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(32)
      make.directionalHorizontalEdges.equalToSuperview()
    }

    self.collectionView.snp.makeConstraints { make in
      make.top.equalTo(self.categoryView.snp.bottom).offset(16.0)
      make.directionalHorizontalEdges.equalToSuperview()
      make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
    }
  }
}
