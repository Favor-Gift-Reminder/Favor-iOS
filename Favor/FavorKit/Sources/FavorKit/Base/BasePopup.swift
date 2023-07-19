//
//  BasePopup.swift
//  Favor
//
//  Created by 김응철 on 2023/05/27.
//

import UIKit

import SnapKit
import Then

open class BasePopup: BaseViewController {

  // MARK: - Constants  
  private enum Metric {
    static let containerViewWidth: CGFloat = 335.0
  }
  
  // MARK: - UI Components
  
  private let backgroundView: UIView = UIView().then {
    $0.backgroundColor = .clear
  }
  
  /// 팝업 창 중앙에 있는 뷰 입니다.
  /// 이 곳에 UI 컴포넌트의 레이러를 추가합니다.
  public let containerView: UIView = UIView().then {
    $0.layer.shadowOpacity = 0.1
    $0.layer.shadowColor = UIColor.favorColor(.black).cgColor
    $0.layer.shadowOffset = .zero
    $0.layer.cornerRadius = 24.0
    $0.backgroundColor = .favorColor(.white)
  }
  
  // MARK: - Properties
  
  private var containerViewHeightConstraint: Constraint?
  private var containerViewBottomInset: Constraint?
  private let containerViewHeight: CGFloat
  
  // MARK: - Initializer
  
  public init(_ containerViewHeight: CGFloat) {
    self.containerViewHeight = containerViewHeight
    super.init(nibName: nil, bundle: nil)
  }
  
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycle
  
  override public func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    self.animateContainerView()
  }
  
  // MARK: - Setup
  
  override open func setupStyles() {
    super.setupStyles()
    
    self.view.backgroundColor = .clear
  }
  
  override open func setupLayouts() {
    super.setupLayouts()
    
    [
      self.backgroundView,
      self.containerView
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override open func setupConstraints() {
    super.setupConstraints()
    
    self.backgroundView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.containerView.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
      self.containerViewBottomInset = make.bottom.equalToSuperview().inset(100.0).constraint
      make.height.equalTo(self.containerViewHeight)
    }
  }
  
  // MARK: - Bind
  
  override open func bind() {
    super.bind()
    
    self.backgroundView.rx.tapGesture()
      .skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in owner.dismissPopup() }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions
  
  /// dismiss(animated:) 대신 이 메서드를 불러서 종료시켜야 합니다.
  public func dismissPopup(_ completion: (() -> Void)? = nil) {
    UIView.animate(
      withDuration: 0.1,
      delay: 0,
      options: .curveEaseInOut,
      animations: {
        self.containerView.alpha = 0
        self.view.layoutIfNeeded()
      },
      completion: { _ in
        self.dismiss(animated: false)
        if let completion { completion() }
      }
    )
  }
  
  /// 팝업 창을 아래에서 올라오는 애니메이션 메서드입니다.
  private func animateContainerView() {
    UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut) {
      self.containerViewBottomInset?.update(
        inset: (self.view.frame.height / 2) - self.containerViewHeight / 2
      )
      self.view.layoutIfNeeded()
    }
  }
}
