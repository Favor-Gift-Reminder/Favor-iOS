//
//  BasePopup.swift
//  Favor
//
//  Created by 김응철 on 2023/05/27.
//

import UIKit

import FavorKit
import SnapKit
import Then

public class BasePopup: BaseViewController {

  // MARK: - Constants

  private enum Metric {
    static let containerViewWidth: CGFloat = 335.0
  }
  
  // MARK: - UI Components
  
  private let dimmedView: UIView = UIView().then {
    $0.backgroundColor = .favorColor(.black)
    $0.alpha = 0.0
  }
  
  public let containerView: UIView = UIView().then {
    $0.layer.cornerRadius = 24.0
    $0.backgroundColor = .favorColor(.white)
  }
  
  // MARK: - Properties
  
  private var containerViewHeightConstraint: Constraint?
  private var containerViewBottomInset: Constraint?
  private let containerViewHeight: CGFloat
  
  // MARK: - Initializer
  
  init(_ containerViewHeight: CGFloat) {
    self.containerViewHeight = containerViewHeight
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycle
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.animateDimmedView()
    self.animateContainerView()
  }
  
  // MARK: - UI Setups

  public override func setupStyles() {
    super.setupStyles()
    
    self.view.backgroundColor = .clear
  }
  
  public override func setupLayouts() {
    super.setupLayouts()
    
    [
      self.dimmedView,
      self.containerView
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  public override func setupConstraints() {
    super.setupConstraints()
    
    self.dimmedView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.containerView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      self.containerViewBottomInset = make.bottom.equalToSuperview().inset(100.0).constraint
      make.width.equalTo(Metric.containerViewWidth)
      make.height.equalTo(self.containerViewHeight)
    }
  }
  
  // MARK: - Bind
  
  public override func bind() {
    super.bind()
    
    self.dimmedView.rx.tapGesture()
      .skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in owner.dismissPopup() }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions
  
  /// dismiss(animated:) 대신 이 메서드를 불러서 종료시켜야 합니다.
  public func dismissPopup(_ completion: (() -> Void)? = nil) {
    // TODO: Coordinator 삭제
    UIView.animate(
      withDuration: 0.2,
      delay: 0,
      options: .curveEaseInOut,
      animations: {
        self.dimmedView.alpha = 0
        self.containerView.alpha = 0
        self.view.layoutIfNeeded()
      },
      completion: { _ in
        self.dismiss(animated: false)
        if let completion { completion() }
      }
    )
  }
  
  /// 배경의 알파 값을 조절하는 애니메이션 메서드입니다.
  private func animateDimmedView() {
    self.dimmedView.alpha = 0.0
    UIView.animate(withDuration: 0.4) {
      self.dimmedView.alpha = 0.3
    }
    self.view.layoutIfNeeded()
  }
  
  /// 팝업 창을 아래에서 올라오는 애니메이션 메서드입니다.
  private func animateContainerView() {
    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
      self.containerViewBottomInset?.update(
        inset: (self.view.frame.height / 2) - self.containerViewHeight / 2
      )
      self.view.layoutIfNeeded()
    }
  }
}
