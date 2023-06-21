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

  private let emotionButtonStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.distribution = .equalCentering

    FavorEmotion.allCases.forEach {
      stackView.addArrangedSubview(FavorEmotionButton($0))
    }

    return stackView
  }()

  // MARK: - Life Cycle

  // MARK: - Binding

  public override func bind(reactor: SearchTagViewReactor) {
    super.bind(reactor: reactor)

    // Action
    self.emotionButtonStack.arrangedSubviews.forEach { arrangedSubviews in
      guard let button = arrangedSubviews as? FavorEmotionButton else { return }
      button.rx.tap
        .map { Reactor.Action.emotionDidSelected(button.emotion) }
        .bind(to: reactor.action)
        .disposed(by: self.disposeBag)
    }

    // State
    
  }

  // MARK: - Functions

  public func requestEmotion(_ emotion: FavorEmotion) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.emotionDidSelected(emotion))
  }

  // MARK: - UI Setups

  public override func setupLayouts() {
    [
      self.emotionButtonStack,
      self.collectionView
    ].forEach {
      self.view.addSubview($0)
    }
  }

  public override func setupConstraints() {
    self.emotionButtonStack.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(32)
      make.directionalHorizontalEdges.equalToSuperview().inset(20)
    }

    self.collectionView.snp.makeConstraints { make in
      make.top.equalTo(self.emotionButtonStack.snp.bottom)
      make.directionalHorizontalEdges.equalToSuperview()
      make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
    }
  }
}
