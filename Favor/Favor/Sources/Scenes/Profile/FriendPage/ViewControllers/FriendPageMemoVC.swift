//
//  FriendPageMemoVC.swift
//  Favor
//
//  Created by 김응철 on 11/25/23.
//

import UIKit

import FavorKit
import RSKPlaceholderTextView
import ReactorKit

final class FriendPageMemoViewController: BaseViewController, View {
  
  typealias Reactor = FriendPageMemoViewReactor
  
  // MARK: - UI Components
  
  private let textView: RSKPlaceholderTextView = {
    let textView = RSKPlaceholderTextView()
    textView.attributedPlaceholder = NSAttributedString(
      string: "친구의 관심사나 특징을 기록해보세요!",
      attributes: [
        .font: UIFont.favorFont(.regular, size: 16),
        .foregroundColor: UIColor.favorColor(.explain)
      ]
    )
    textView.textColor = .favorColor(.icon)
    textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    textView.backgroundColor = .favorColor(.card)
    textView.layer.cornerRadius = 24
    return textView
  }()
  
  private let doneButton: FavorButton = {
    let button = FavorButton("완료")
    button.baseBackgroundColor = .clear
    button.font = .favorFont(.bold, size: 18)
    button.contentInset = .zero
    button.configurationUpdateHandler = { button in
      guard let button = button as? FavorButton else { return }
      switch button.state {
      case .disabled:
        button.baseForegroundColor = .favorColor(.line2)
        button.configuration?.background.backgroundColor = .white
      default:
        button.baseForegroundColor = .favorColor(.main)
      }
    }
    return button
  }()
  
  // MARK: - Bind
  
  func bind(reactor: FriendPageMemoViewReactor) {
    // Action
    
    self.textView.rx.text.orEmpty
      .map { Reactor.Action.memoDidChange($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.doneButton.rx.tap
      .map { Reactor.Action.doneButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    
    reactor.state.map { $0.isEnabledDoneButton }
      .distinctUntilChanged()
      .bind(to: self.doneButton.rx.isEnabled)
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.friend.memo }
      .take(1)
      .bind(to: self.textView.rx.text)
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    self.navigationItem.rightBarButtonItem = self.doneButton.toBarButtonItem()
    self.navigationItem.title = "메모 수정"
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    self.view.addSubview(self.textView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.textView.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide).inset(32)
      make.directionalHorizontalEdges.equalToSuperview().inset(20)
      make.height.equalTo(130)
    }
  }
}
