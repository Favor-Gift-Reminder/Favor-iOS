//
//  GiftShareVC.swift
//  Favor
//
//  Created by 이창준 on 2023/05/30.
//

import UIKit

import FavorKit
import ReactorKit
import RxGesture
import SnapKit

final class GiftShareViewController: BaseViewController, View {

  // MARK: - Constants

  private enum Metric {
    static let shareViewTopInset: CGFloat = 44.0
    static let shareViewHorizontalInset: CGFloat = 34.0
    static let shareButtonWidth: CGFloat = 56.0
  }

  // MARK: - Properties

  // MARK: - UI Components

  private let shareShadowView: UIView = {
    let view = UIView()
    view.layer.shadowRadius = 24
    view.layer.shadowOpacity = 0.2
    view.layer.shadowOffset = CGSize(width: 8, height: 8)
    view.layer.shadowColor = UIColor.favorColor(.white).cgColor
    view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
    view.layer.masksToBounds = false
    return view
  }()
  private let shareImageView = GiftShareView()

  private let shareLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 14)
    label.textColor = .favorColor(.white)
    label.textAlignment = .center
    label.text = "공유하기"
    return label
  }()

  private lazy var instagramButton = self.shareButton(.instagram(nil, nil))
  private lazy var photosButton = self.shareButton(.photos)

  private let shareButtonStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 48
    stackView.alignment = .center
    return stackView
  }()

  // MARK: - Life Cycle

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.setupShadowPath()
  }

  // MARK: - Binding

  func bind(reactor: GiftShareViewReactor) {
    // Action
    self.instagramButton.rx.tap
      .map { _ in
        let stickerImage = self.shareImageView.toImage()
        let backgroundImage = self.shareImageView.currentImage?.toBlurredBackgroundImage(self.view.frame)
        return Reactor.Action.instagramButtonDidTap(backgroundImage, stickerImage)
      }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.photosButton.rx.tap
      .map { Reactor.Action.photosButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.view.rx.tapGesture()
      .when(.recognized)
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, _ in
        owner.view.endEditing(true)
      })
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { $0.gift }
      .take(1)
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, gift in
        owner.shareImageView.bind(with: gift, image: nil)
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  // MARK: - UI Setups

  override func setupStyles() {
    super.setupStyles()

    self.view.backgroundColor = .favorColor(.black)
  }

  override func setupLayouts() {
    [
      self.instagramButton,
      self.photosButton
    ].forEach {
      self.shareButtonStack.addArrangedSubview($0)
    }

    [
      self.shareShadowView,
      self.shareImageView,
      self.shareLabel,
      self.shareButtonStack
    ].forEach {
      self.view.addSubview($0)
    }
  }

  override func setupConstraints() {
    self.shareImageView.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide).inset(Metric.shareViewTopInset)
      make.directionalHorizontalEdges.equalToSuperview().inset(Metric.shareViewHorizontalInset)
      make.centerX.equalToSuperview()
    }

    self.shareShadowView.snp.makeConstraints { make in
      make.edges.equalTo(self.shareImageView)
      make.center.equalTo(self.shareImageView)
    }

    self.shareButtonStack.snp.makeConstraints { make in
      make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(48)
      make.centerX.equalToSuperview()
    }

    self.shareLabel.snp.makeConstraints { make in
      make.bottom.equalTo(self.shareButtonStack.snp.top).offset(-24)
      make.centerX.equalToSuperview()
    }
  }
}

// MARK: - Privates

private extension GiftShareViewController {
  func shareButton(_ target: ShareTarget) -> UIButton {
    var config = UIButton.Configuration.borderless()
    config.contentInsets = .zero
    config.imagePlacement = .top
    config.imagePadding = 10
    config.image = target.icon
    config.updateAttributedTitle(target.title, font: .favorFont(.regular, size: 12))
    config.baseForegroundColor = .favorColor(.white)

    let button = UIButton(configuration: config)

    button.snp.makeConstraints { make in
      make.width.equalTo(Metric.shareButtonWidth)
      make.height.greaterThanOrEqualTo(button.snp.width)
    }
    return button
  }

  func setupShadowPath() {
    self.shareShadowView.layer.shadowPath = UIBezierPath(
      rect: self.shareShadowView.bounds).cgPath
    self.shareShadowView.layer.shouldRasterize = true
    self.shareShadowView.layer.rasterizationScale = UIScreen.main.scale
  }
}

// MARK: - ShareTarget

fileprivate extension ShareTarget {
  var icon: UIImage? {
    return UIImage(named: "share_\(self.rawValue)")
  }
}

// MARK: - UIImageView

fileprivate extension UIImage {
  func toBlurredBackgroundImage(_ frame: CGRect) -> UIImage {
    let imageView = UIImageView(frame: frame)
    imageView.contentMode = .scaleAspectFill
    imageView.image = self

    let blurEffect = UIBlurEffect(style: .dark)
    let visualEffectView = UIVisualEffectView(effect: blurEffect)
    visualEffectView.frame = frame
    visualEffectView.center = imageView.center
    imageView.addSubview(visualEffectView)
    return imageView.toImage()
  }
}
