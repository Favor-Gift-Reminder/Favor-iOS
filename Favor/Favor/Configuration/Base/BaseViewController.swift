//
//  BaseViewController.swift
//  Favor
//
//  Created by 김응철 on 2022/12/29.
//

import UIKit

import class RxSwift.DisposeBag

class BaseViewController: UIViewController {

  /// A dispose bag. 각 ViewController에 종속적이다.
  final var disposeBag = DisposeBag()
	
  override func viewDidLoad() {
    super.viewDidLoad()
    setupLayouts()
    setupConstraints()
    setupStyles()
    bind()
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
  func setupLayouts() { }

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
  func setupConstraints() { }

  /// View와 관련된 Style을 설정합니다.
  ///
  /// ```
  /// func setupStyles() {
  ///   navigationController?.navigationBar.tintColor = .white
  ///   view.backgroundColor = .white
  ///   // codes..
  /// }
  /// ```
  func setupStyles() {
    self.view.backgroundColor = .favorColor(.white)
    self.view.directionalLayoutMargins = NSDirectionalEdgeInsets(
      top: 0, leading: 20.0, bottom: 0, trailing: 20.0
    )
  }
  
  func bind() { }
}
