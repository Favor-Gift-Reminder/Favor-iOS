//
//  BaseViewController.swift
//  Favor
//
//  Created by 김응철 on 2022/12/29.
//

import UIKit

import class RxSwift.DisposeBag
import SnapKit

open class BaseViewController: UIViewController, Toastable {
  
  // MARK: - Properties
  
  private let indicatorView: UIActivityIndicatorView = {
    let indicatorView = UIActivityIndicatorView()
    return indicatorView
  }()
  
  private lazy var loadingView: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    view.addSubview(self.indicatorView)
    return view
  }()

  /// A dispose bag. 각 ViewController에 종속적이다.
  public final var disposeBag = DisposeBag()

  open override func viewDidLoad() {
    super.viewDidLoad()
    self.setupLayouts()
    self.setupConstraints()
    self.setupStyles()
    self.setupLoadingView()
    self.bind()
  }

  open override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    ToastManager.shared.resetToast()
  }
  
  // MARK: - Setup

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
  
  private func setupLoadingView() {
    self.loadingView.addSubview(self.indicatorView)
    
    self.indicatorView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }

  open func bind() { }
  
  // MARK: - Functions
  
  /// `indicator`의 상태를 변경합니다.
  /// 최상단 레이어의 정중앙에서 재생됩니다.
  ///
  /// - Parameters:
  ///  - isLoading: 현재 로딩의 상태입니다.
  public func isLoadingWillChange(_ isLoading: Bool) {
    DispatchQueue.main.async {
      if isLoading {
        // 로딩 중
        self.indicatorView.startAnimating()
        self.loadingView.isHidden = false
        self.view.addSubview(self.loadingView)
        self.loadingView.snp.makeConstraints { make in
          make.edges.equalToSuperview()
        }
      } else {
        // 로딩 중이 아님
        self.indicatorView.stopAnimating()
        self.loadingView.removeFromSuperview()
      }
    }
  }

  // MARK: - Toast

  public var toast: FavorToastMessageView?

  open func viewNeedsLoaded(with toast: ToastMessage? = nil) { }
}
