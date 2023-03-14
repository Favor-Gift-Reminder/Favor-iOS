//
//  BaseViewController.swift
//  Favor
//
//  Created by 김응철 on 2022/12/29.
//

import UIKit

import class RxSwift.DisposeBag

open class BaseViewController: UIViewController {

  /// A dispose bag. 각 ViewController에 종속적이다.
  public final var disposeBag = DisposeBag()

  private var toast: FavorToastMessageView?

  open override func viewDidLoad() {
    super.viewDidLoad()
    setupLayouts()
    setupConstraints()
    setupStyles()
  }

  /// UI 프로퍼티를 view에 할당합니다.
  ///
  /// ```
  /// func setupLayouts() {
  ///   self.view.addSubview(label)
  ///   self.stackView.addArrangedSubview(label)
  ///   self.label.layer.addSubLayer(gradientLayer)
  ///   // codes..
  /// }
  /// ```
  open func setupLayouts() { }

  /// UI 프로퍼티의 제약조건을 설정합니다.
  ///
  /// ```
  /// func setupConstraints() {
  ///   // with SnapKit
  ///   label.snp.makeConstraints { make in
  ///     make.edges.equalToSuperview()
  ///   }
  ///   // codes..
  /// }
  /// ```
  open func setupConstraints() { }

  /// View와 관련된 Style을 설정합니다.
  ///
  /// ```
  /// func setupStyles() {
  ///   navigationController?.navigationBar.tintColor = .white
  ///   view.backgroundColor = .white
  ///   // codes..
  /// }
  /// ```
  open func setupStyles() {
    self.view.backgroundColor = .favorColor(.white)
    self.view.directionalLayoutMargins = NSDirectionalEdgeInsets(
      top: 0, leading: 20.0, bottom: 0, trailing: 20.0
    )
  }
}

// MARK: - Toast

public extension BaseViewController {
  func presentToast(_ message: String, duration: ToastManager.duration) {
    self.toast = ToastManager.shared.prepareToast(message)
    guard let toast = self.toast else { return }
    ToastManager.shared.showToast(toast, at: self)
  }

  func dismissToast() {
    guard let toast = self.toast else { return }
    ToastManager.shared.hideToast(toast, from: self)
  }
}
