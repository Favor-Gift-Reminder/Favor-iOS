//
//  BaseBottomSheet.swift
//  
//
//  Created by 김응철 on 2023/03/31.
//

import UIKit

import SnapKit

open class BaseBottomSheet: BaseViewController {
  
  // MARK: - UI
  
  public let containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .favorColor(.white)
    view.layer.cornerRadius = 24
    view.clipsToBounds = true
    return view
  }()
  
  private let dimmedView: UIView = {
    let view = UIView()
    view.backgroundColor = .favorColor(.black)
    view.alpha = 0.6
    return view
  }()
  
  public let titleLabel: UILabel = {
    let lb = UILabel()
    lb.textColor = .favorColor(.icon)
    lb.font = .favorFont(.bold, size: 18)
    return lb
  }()
  
  public lazy var cancelButton: UIButton = {
    let btn = UIButton()
    let attributedTitle = NSAttributedString(
      string: "취소",
      attributes: [
        .foregroundColor: UIColor.favorColor(.icon),
        .font: UIFont.favorFont(.bold, size: 18)
      ]
    )
    btn.setAttributedTitle(attributedTitle, for: .normal)
    btn.addTarget(self, action: #selector(dismissBottomSheet), for: .touchUpInside)
    return btn
  }()
  
  private lazy var tapGesture: UITapGestureRecognizer = {
    let tg = UITapGestureRecognizer(
      target: self,
      action: #selector(dismissBottomSheet)
    )
    return tg
  }()
  
  private lazy var panGesture: UIPanGestureRecognizer = {
    let pg = UIPanGestureRecognizer(
      target: self,
      action: #selector(self.handlePanGesture(_:))
    )
    pg.delaysTouchesBegan = false
    pg.delaysTouchesEnded = false
    return pg
  }()
  
  // MARK: - PROPERTIES
  
  private var containerViewHeight: Constraint?
  private var containerViewBottomInset: Constraint?
  private let maxHeight: CGFloat = 294
  private let dismissibleHeight: CGFloat = 200
  
  // MARK: - LIFE CYCLE
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.animateShowDimmedView()
    self.animatePresentContainerView()
  }
  
  // MARK: - SETUP
  
  open override func setupStyles() {
    self.view.backgroundColor = .clear
    self.dimmedView.addGestureRecognizer(self.tapGesture)
    self.view.addGestureRecognizer(self.panGesture)
  }
  
  open override func setupLayouts() {
    [
      self.dimmedView,
      self.containerView,
    ].forEach {
      self.view.addSubview($0)
    }
    
    [
      self.titleLabel,
      self.cancelButton,
    ].forEach {
      self.containerView.addSubview($0)
    }
  }
  
  open override func setupConstraints() {
    self.dimmedView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.containerView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      self.containerViewBottomInset = make.bottom.equalToSuperview().inset(-self.maxHeight).constraint
      self.containerViewHeight = make.height.equalTo(self.maxHeight).constraint
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(20)
      make.centerX.equalToSuperview()
    }
    
    self.cancelButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.centerY.equalTo(self.titleLabel)
    }
  }
  
  // MARK: - SELECTORS
  
  @objc
  private func dismissBottomSheet() {
    self.animateDismissView()
  }
  
  @objc
  private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
    let translation = gesture.translation(in: self.view)
    let newHeight = self.maxHeight - translation.y
    
    switch gesture.state {
    case .changed:
      if newHeight < self.maxHeight {
        self.containerViewHeight?.update(offset: newHeight)
        self.view.layoutIfNeeded()
      }
    case .ended:
      if newHeight < self.dismissibleHeight {
        self.animateDismissView()
      } else {
        self.animateContainerHeight(self.maxHeight)
      }
    default:
      break
    }
  }
  
  // MARK: - HELPERS
  
  func animatePresentContainerView() {
    UIView.animate(withDuration: 0.3) {
      self.containerViewBottomInset?.update(inset: 0)
      self.view.layoutIfNeeded()
    }
  }
  
  func animateShowDimmedView() {
    dimmedView.alpha = 0
    UIView.animate(withDuration: 0.4) {
      self.dimmedView.alpha = 0.6
    }
  }
  
  func animateDismissView() {
    UIView.animate(withDuration: 0.3) {
      self.containerViewBottomInset?.update(inset: -294)
      self.view.layoutIfNeeded()
    }
    
    self.dimmedView.alpha = 0.6
    UIView.animate(withDuration: 0.4) {
      self.dimmedView.alpha = 0
    } completion: { _ in
      self.dismiss(animated: false)
    }
  }
  
  func animateContainerHeight(_ height: CGFloat) {
    UIView.animate(withDuration: 0.4) {
      self.containerViewHeight?.update(offset: height)
      self.view.layoutIfNeeded()
    }
  }
  
  // MARK: - FUNCTIONS
  
  public func updateTitle(_ title: String) {
    self.titleLabel.text = title
  }
}
