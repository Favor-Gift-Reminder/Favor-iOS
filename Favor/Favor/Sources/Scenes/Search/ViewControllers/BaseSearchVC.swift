//
//  BaseSearchVC.swift
//  Favor
//
//  Created by 이창준 on 2023/04/15.
//

import UIKit

import FavorKit
import ReactorKit
import SnapKit

class BaseSearchViewController: BaseViewController, View {

  // MARK: - UI Components

  // SearchBar
  public lazy var searchTextField: FavorSearchBar = {
    let searchBar = FavorSearchBar()
    searchBar.searchBarHeight = 40
    searchBar.placeholder = "선물, 유저 ID를 검색해보세요"
    return searchBar
  }()

  // MARK: - Life Cycle

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.navigationController?.setNavigationBarHidden(true, animated: false)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    self.setEditing(false, animated: true)
  }

  // MARK: - Binding

  func bind(reactor: SearchViewReactor) {
    // Action
    Observable.combineLatest(self.rx.viewDidAppear, self.rx.viewWillAppear)
      .throttle(.nanoseconds(500), scheduler: MainScheduler.instance)
      .map { _ in Reactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.searchTextField.rx.editingDidBegin
      .map { Reactor.Action.editingDidBegin }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.searchTextField.rx.text
      .distinctUntilChanged()
      .map { Reactor.Action.textDidChanged($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.searchTextField.rx.editingDidEnd
      .map { Reactor.Action.editingDidEnd }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.searchTextField.rx.editingDidEndOnExit
      .map { Reactor.Action.returnKeyDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

//    Observable.combineLatest(self.rx.viewWillDisappear, self.searchTextField.rx.backButtonDidTap)
    self.searchTextField.rx.backButtonDidTap
      .throttle(.nanoseconds(500), scheduler: MainScheduler.asyncInstance)
      .map { _ in Reactor.Action.viewWillDisappear }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.view.rx.tapGesture(configuration: { [weak self] recognizer, delegate in
      guard let `self` = self else { return }
      recognizer.delegate = self
      delegate.simultaneousRecognitionPolicy = .never
    })
    .when(.recognized)
    .map { _ in Reactor.Action.editingDidEnd }
    .bind(to: reactor.action)
    .disposed(by: self.disposeBag)

    // State
    reactor.state.map { $0.isEditing }
      .distinctUntilChanged()
      .debug("isEditing")
      .delay(.nanoseconds(100), scheduler: MainScheduler.instance)
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, isEditing in
        owner.toggleIsEditing(to: isEditing)
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  public func toggleIsEditing(to isEditing: Bool) {
    self.searchTextField.setBackButton(toHidden: isEditing)
  }
}

// MARK: - Recognizer

extension BaseSearchViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldReceive touch: UITouch
  ) -> Bool {
    guard
      !(touch.view is UIControl),
      !(touch.view is SearchRecentCell)
    else { return false }
    return true
  }
}
