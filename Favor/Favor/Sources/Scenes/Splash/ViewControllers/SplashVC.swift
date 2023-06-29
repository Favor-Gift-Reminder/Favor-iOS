//
//  SplashVC.swift
//  Favor
//
//  Created by 이창준 on 2022/12/31.
//

import UIKit

import FavorKit
import ReactorKit
import RxCocoa
import RxFlow
import SnapKit

public final class SplashViewController: BaseViewController, View {

  // MARK: - Constants

  private enum Metric {
    static let logoImageSize: CGFloat = 75.0
  }

  // MARK: - Properties

  // MARK: - UI Components

  private let logoImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "SplashLogo")
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()

  // MARK: - Binding

  public func bind(reactor: SplashViewReactor) {
    // Action
    self.rx.viewDidLoad
      .map { Reactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State

  }

  // MARK: - UI Setups

  public override func setupStyles() {
    super.setupStyles()

    self.view.backgroundColor = .favorColor(.main)
  }

  public override func setupLayouts() {
    self.view.addSubview(self.logoImageView)
  }

  public override func setupConstraints() {
    self.logoImageView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.height.equalTo(Metric.logoImageSize)
    }
  }
}
