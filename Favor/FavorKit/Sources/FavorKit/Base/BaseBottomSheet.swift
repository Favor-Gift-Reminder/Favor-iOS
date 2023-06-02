//
//  BaseBottomSheet.swift
//  Favor
//
//  Created by 김응철 on 2023/03/31.
//

import UIKit

import SnapKit
import Then

open class BaseBottomSheet: BaseViewController {

  enum Metric {
    static let bottomSheetHeight: CGFloat = 294.0
    static let dismissibleHeight: CGFloat = 200.0
  }

  // MARK: - UI Components
  
  public let containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .favorColor(.white)
    view.layer.cornerRadius = 24
    view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    view.clipsToBounds = true
    return view
  }()
  
  private let dimmedView: UIView = {
    let view = UIView()
    view.backgroundColor = .favorColor(.black)
    view.alpha = 0.0
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

  public let finishButton: UIButton = UIButton().then {
    var config = UIButton.Configuration.plain()
    var container = AttributeContainer()
    container.font = .favorFont(.bold, size: 18)
    config.attributedTitle = AttributedString("완료", attributes: container)
    config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    $0.configuration = config
    $0.configurationUpdateHandler = {
      switch $0.state {
      case .disabled:
        $0.configuration?.baseForegroundColor = .favorColor(.line2)
      default:
        $0.configuration?.baseForegroundColor = .favorColor(.icon)
      }
    }
  }

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

  public var containerViewHeight: Constraint?
  public var containerViewBottomInset: Constraint?

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
      self.finishButton
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
      self.containerViewBottomInset = make.bottom.equalToSuperview()
        .inset(-Metric.bottomSheetHeight)
        .constraint
      self.containerViewHeight = make.height.equalTo(Metric.bottomSheetHeight).constraint
    }

    self.titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(20)
      make.centerX.equalToSuperview()
    }

    self.cancelButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.centerY.equalTo(self.titleLabel)
    }

    self.finishButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(20)
      make.centerY.equalTo(self.titleLabel)
    }
  }

  // MARK: - SELECTORS

  @objc
  open func dismissBottomSheet() {
    self.animateDismissView()
  }

  @objc
  private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
    let translation = gesture.translation(in: self.view)
    let newHeight = Metric.bottomSheetHeight - translation.y

    switch gesture.state {
    case .changed:
      if newHeight < Metric.bottomSheetHeight {
        self.containerViewHeight?.update(offset: newHeight)
        self.view.layoutIfNeeded()
      }
    case .ended:
      if newHeight < Metric.dismissibleHeight {
        self.animateDismissView()
      } else {
        self.animateContainerHeight(Metric.bottomSheetHeight)
      }
    default:
      break
    }
  }

  // MARK: - HELPERS

  /// 창을 종료할 때, dismiss(animated:)가 아닌 이 메서드를 호출해야합니다.
  public func animateDismissView() {
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

  private func animatePresentContainerView() {
    UIView.animate(withDuration: 0.3) {
      self.containerViewBottomInset?.update(inset: 0)
      self.view.layoutIfNeeded()
    }
  }

  private func animateShowDimmedView() {
    dimmedView.alpha = 0
    UIView.animate(withDuration: 0.4) {
      self.dimmedView.alpha = 0.6
    }
  }

  private func animateContainerHeight(_ height: CGFloat) {
    UIView.animate(withDuration: 0.4) {
      self.containerViewHeight?.update(offset: height)
      self.view.layoutIfNeeded()
    }
  }

  // MARK: - Functions

  public func updateTitle(_ title: String) {
    self.titleLabel.text = title
  }
}
