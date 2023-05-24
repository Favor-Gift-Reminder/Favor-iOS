//
//  BaseViewController.swift
//  Favor
//
//  Created by 김응철 on 2022/12/29.
//

import UIKit

import class RxSwift.DisposeBag

open class BaseViewController: UIViewController, Toastable {

  /// A dispose bag. 각 ViewController에 종속적이다.
  public final var disposeBag = DisposeBag()

  open override func viewDidLoad() {
    super.viewDidLoad()
    self.setupLayouts()
    self.setupConstraints()
    self.setupStyles()
    self.bind()
  }

  open override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    ToastManager.shared.resetToast()
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

  open func bind() { }

  // MARK: - Toast

  public var toast: FavorToastMessageView?

  open func viewNeedsLoaded(with toast: ToastMessage? = nil) { }
}
