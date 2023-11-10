//
//  GiftManagementMemoCell.swift
//  Favor
//
//  Created by 이창준 on 2023/05/29.
//

import UIKit

import FavorKit
import RSKPlaceholderTextView
import RxCocoa
import RxSwift
import SnapKit

public protocol GiftManagementMemoCellDelegate: AnyObject {
  func memoDidUpdate(_ memo: String?)
  func emotionDidUpdate(_ emotion: FavorEmotion)
}

final class GiftManagementMemoCell: BaseCollectionViewCell {

  // MARK: - Properties
  
  public weak var delegate: GiftManagementMemoCellDelegate?
      
  // MARK: - UI Components
  
  private let memoTextView: RSKPlaceholderTextView = {
    let textView = RSKPlaceholderTextView()
    textView.attributedPlaceholder = NSAttributedString(
      string: "자유롭게 작성해보세요.",
      attributes: [
        .font: UIFont.favorFont(.regular, size: 16),
        .foregroundColor: UIColor.favorColor(.explain),
      ]
    )
    textView.backgroundColor = .favorColor(.card)
    textView.font = .favorFont(.regular, size: 16)
    textView.textColor = .favorColor(.icon)
    textView.textContainerInset = .zero
    return textView
  }()
  
  private let memoView: UIView = {
    let view = UIView()
    view.backgroundColor = .favorColor(.card)
    view.layer.cornerRadius = 24
    return view
  }()
  
  private let emotionView: FavorEmotionView = {
    let view = FavorEmotionView()
    return view
  }()
  
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
    self.bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  public func bind(with gift: Gift) {
    self.memoTextView.text = gift.memo
    self.emotionView.updateEmotion(gift.emotion)
  }
  
  private func bind() {
    self.memoTextView.rx.text
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, _ in
        owner.delegate?.memoDidUpdate(owner.memoTextView.text)
      })
      .disposed(by: self.disposeBag)
    
    self.emotionView.emotionSubject
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, emotion in
        owner.delegate?.emotionDidUpdate(emotion)
      }
      .disposed(by: self.disposeBag)
  }
}

// MARK: - UI Setups

extension GiftManagementMemoCell: BaseView {
  func setupStyles() { }

  func setupLayouts() {
    self.addSubview(self.memoView)
    self.memoView.addSubview(self.memoTextView)
    self.addSubview(self.emotionView)
  }
  
  func setupConstraints() {
    self.emotionView.snp.makeConstraints { make in
      make.top.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(40.0)
    }
    
    self.memoView.snp.makeConstraints { make in
      make.top.equalTo(self.emotionView.snp.bottom).offset(16.0)
      make.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(113.0)
    }
    
    self.memoTextView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(12.0)
    }
  }
}
