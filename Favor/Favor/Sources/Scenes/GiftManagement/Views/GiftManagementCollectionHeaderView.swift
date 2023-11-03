//
//  GiftManagementCollectionHeaderView.swift
//  Favor
//
//  Created by 이창준 on 2023/05/29.
//

import UIKit

import FavorKit
import RxCocoa
import RxSwift
import SnapKit

public protocol GiftManagementCollectionHeaderViewDelegate: AnyObject {
  func giftTypeButtonDidTap(isGiven: Bool)
}

final class GiftManagementCollectionHeaderView: UICollectionReusableView {

  // MARK: - Constants

  public static let identifier: String = "GiftManagementCollectionHeaderView"

  // MARK: - Properties

  private let disposeBag = DisposeBag()
  public weak var delegate: GiftManagementCollectionHeaderViewDelegate?

  // MARK: - UI Components

  private let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 32
    return stackView
  }()

  private lazy var receivedGiftButton = self.makeButton("받은 선물")
  private lazy var givenGiftButton = self.makeButton("준 선물")

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
    self.bind()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Bind

  private func bind() {
    self.receivedGiftButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, _ in
        owner.receivedGiftButton.isSelected = true
        owner.givenGiftButton.isSelected = false
        owner.delegate?.giftTypeButtonDidTap(isGiven: false)
      })
      .disposed(by: self.disposeBag)

    self.givenGiftButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, _ in
        owner.receivedGiftButton.isSelected = false
        owner.givenGiftButton.isSelected = true
        owner.delegate?.giftTypeButtonDidTap(isGiven: true)
      })
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions
  
  public func bind(with isGiven: Bool) {
    self.receivedGiftButton.isSelected = !isGiven
    self.givenGiftButton.isSelected = isGiven
  }
}

// MARK: - UI Setups

extension GiftManagementCollectionHeaderView: BaseView {
  func setupStyles() {
    self.receivedGiftButton.isSelected = true
  }

  func setupLayouts() {
    [
      self.receivedGiftButton,
      self.givenGiftButton
    ].forEach {
      self.stackView.addArrangedSubview($0)
    }

    self.addSubview(self.stackView)
  }

  func setupConstraints() {
    self.stackView.snp.makeConstraints { make in
      make.directionalVerticalEdges.equalToSuperview()
      make.leading.equalToSuperview()
      make.trailing.lessThanOrEqualToSuperview()
    }
  }
}

// MARK: - Privates

private extension GiftManagementCollectionHeaderView {
  func makeButton(_ title: String?) -> UIButton {
    var config = UIButton.Configuration.plain()
    config.baseBackgroundColor = .favorColor(.white)
    config.updateAttributedTitle(title, font: .favorFont(.bold, size: 20))
    config.contentInsets = .zero
    let button = UIButton(configuration: config)
    button.configurationUpdateHandler = { button in
      switch button.state {
      case .normal:
        button.configuration?.baseForegroundColor = .favorColor(.line2)
      case .selected:
        button.configuration?.baseForegroundColor = .favorColor(.icon)
      default:
        break
      }
    }
    return button
  }
}
