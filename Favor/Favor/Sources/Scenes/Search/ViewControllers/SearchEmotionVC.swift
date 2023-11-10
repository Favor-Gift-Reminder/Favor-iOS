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

public final class SearchEmotionViewController: BaseSearchTagViewController {

  // MARK: - Constants

  // MARK: - Properties

  // MARK: - UI Components
  
  private let emotionView = FavorEmotionView()

  // MARK: - Life Cycle

  // MARK: - Binding

  public override func bind(reactor: SearchTagViewReactor) {
    super.bind(reactor: reactor)

    // Action
    self.emotionView.emotionSubject
      .map { Reactor.Action.emotionDidSelected($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    
  }

  // MARK: - Functions

  public func requestEmotion(_ emotion: FavorEmotion) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.emotionDidSelected(emotion))
    self.emotionView.updateEmotion(emotion)
  }

  // MARK: - UI Setups

  public override func setupLayouts() {
    [
      self.emotionView,
      self.collectionView
    ].forEach {
      self.view.addSubview($0)
    }
  }

  public override func setupConstraints() {
    self.emotionView.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(32)
      make.directionalHorizontalEdges.equalToSuperview().inset(20)
    }

    self.collectionView.snp.makeConstraints { make in
      make.top.equalTo(self.emotionView.snp.bottom).offset(32.0)
      make.directionalHorizontalEdges.equalToSuperview()
      make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
    }
  }
}
