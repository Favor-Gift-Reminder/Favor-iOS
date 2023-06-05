//
//  MemoBottomSheet.swift
//  Favor
//
//  Created by 김응철 on 2023/05/22.
//

import UIKit

import FavorKit
import Then
import RSKPlaceholderTextView
import RxCocoa
import RxFlow
import RxSwift
import SnapKit

final class MemoBottomSheet: BaseBottomSheet, Stepper {
  
  private enum Metric {
    static let textViewTopInset: CGFloat = 32.0
    static let textViewHeight: CGFloat = 113.0
    static let componentOffset: CGFloat = 16.0
  }
  
  // MARK: - UI Components
    
  private let descriptionLabel: UILabel = UILabel().then {
    $0.text = "최대 150자까지 작성할 수 있습니다."
    $0.font = .favorFont(.regular, size: 12)
    $0.textColor = .favorColor(.line2)
  }
  
  private let textView: RSKPlaceholderTextView = RSKPlaceholderTextView().then {
    $0.textColor = .favorColor(.icon)
    $0.font = .favorFont(.regular, size: 16)
    $0.attributedPlaceholder = NSAttributedString(
      string: "친구의 취향, 관심사, 특징을 기록해보세요!",
      attributes: [
        .font: UIFont.favorFont(.bold, size: 16),
        .foregroundColor: UIColor.favorColor(.explain)
      ]
    )
  }
  
  private lazy var keyboardDismissGesture: UITapGestureRecognizer = UITapGestureRecognizer().then {
    $0.addTarget(self, action: #selector(self.dismissKeyboard))
  }
  
  private let divider = FavorDivider()
  
  // MARK: - Properties
  
  var steps = PublishRelay<Step>()
  private let memo: String?
  private var isKeyboardShowed: Bool = false
  
  // MARK: - Initializer
  
  init(_ memo: String?) {
    self.memo = memo
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    self.updateTitle("메모 수정")
    self.cancelButton.isHidden = true
    self.textView.text = self.memo
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [
      self.divider,
      self.descriptionLabel,
      self.textView
    ].forEach {
      self.view.addSubview($0)
    }
    
    self.view.addGestureRecognizer(self.keyboardDismissGesture)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.textView.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
      make.top.equalTo(self.titleLabel.snp.bottom).offset(Metric.textViewTopInset)
      make.height.equalTo(Metric.textViewHeight)
    }
    
    self.divider.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
      make.top.equalTo(self.textView.snp.bottom).offset(Metric.componentOffset)
    }
    
    self.descriptionLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.view.layoutMarginsGuide)
      make.top.equalTo(self.divider.snp.bottom).offset(Metric.componentOffset)
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    let textViewChanged = self.textView.rx.text.orEmpty.share()
    
    // 텍스트 150자 길이 제한
    textViewChanged
      .scan("") { $1.count >= 150 ? $0 : $1 }
      .bind(to: self.textView.rx.text)
      .disposed(by: self.disposeBag)
    
    // 키보드 올라옴 감지
    NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
      .asDriver(onErrorRecover: { _ in .empty() })
      .drive(with: self) { owner, noti in
        guard let keyboardFrame = noti.userInfo?[
          UIResponder.keyboardFrameEndUserInfoKey
        ] as? CGRect else { return }
        owner.isKeyboardShowed = true
        owner.containerViewBottomInset?.update(inset: keyboardFrame.height)
        owner.view.layoutIfNeeded()
      }
      .disposed(by: self.disposeBag)
    
    // 키보드 사라짐 감지
    NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.containerViewBottomInset?.update(inset: 0)
        owner.view.layoutIfNeeded()
        owner.isKeyboardShowed = false
      }
      .disposed(by: self.disposeBag)
    
    // 완료 버튼 클릭
    self.finishButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        let text = owner.textView.text
        owner.steps.accept(AppStep.memoBottomSheetIsComplete(text))
      }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Selectors
  
  // dimmedView를 클릭했을 때 호출되는 Selector 메서드입니다.
  override func dismissBottomSheet() {
    if !self.isKeyboardShowed {
      super.dismissBottomSheet()
    } else {
      self.view.endEditing(true)
    }
  }
  
  // 빈 화면을 클릭했을 때 호출됩니다.
  @objc
  private func dismissKeyboard() {
    self.view.endEditing(true)
  }
}
