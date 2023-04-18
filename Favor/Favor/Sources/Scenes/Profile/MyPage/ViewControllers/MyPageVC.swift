//
//  MyPageVC.swift
//  Favor
//
//  Created by 이창준 on 2023/01/11.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import RxDataSources
import RxGesture
import SnapKit

final class MyPageViewController: BaseProfileViewController, View {
  
  // MARK: - Constants
  
  // MARK: - Properties

  // MARK: - UI Components
  
  // MARK: - Life Cycle
  
  // MARK: - Binding

  override func bind() {
    guard let reactor = self.reactor else { return }

    // Action
    self.collectionView.rx.contentOffset
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, offset in
        owner.updateProfileViewLayout(by: offset)
      })
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { $0.sections }
      .bind(to: self.collectionView.rx.items(dataSource: self.dataSource))
      .disposed(by: self.disposeBag)
  }
  
  func bind(reactor: MyPageViewReactor) {
    // Action
    
    // State

  }
  
  // MARK: - Functions

  // MARK: - UI Setups
  
}

// MARK: - Privates

private extension MyPageViewController {

}
