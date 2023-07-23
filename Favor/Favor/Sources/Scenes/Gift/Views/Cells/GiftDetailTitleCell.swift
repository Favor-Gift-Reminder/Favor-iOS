//
//  GiftDetailTitleCell.swift
//  Favor
//
//  Created by 이창준 on 2023/05/26.
//

import UIKit

import FavorKit
import Reusable
import RxCocoa
import RxSwift
import SnapKit

public protocol GiftDetailTitleCellDelegate: AnyObject {
  func pinButtonDidTap()
}

final class GiftDetailTitleCell: BaseCollectionViewCell {

  // MARK: - Properties

  public weak var delegate: GiftDetailTitleCellDelegate?

  public var gift: Gift = Gift() {
    didSet { self.updateGift() }
  }

  // MARK: - UI Components

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 22)
    label.text = "집들이"
    return label
  }()
  
  private let pinButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.background.backgroundColor = .clear
    let pinImage: UIImage? = .favorIcon(.pin)
    config.contentInsets = .zero
    
    let button = UIButton(configuration: config)
    button.configurationUpdateHandler = { button in
      switch button.state {
      case .normal:
        button.configuration?.image = pinImage?.withTintColor(.favorColor(.line2))
      case .selected:
        button.configuration?.image = pinImage?.withTintColor(.favorColor(.icon))
      default:
        break
      }
    }
    return button
  }()
  
  private let titleStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 10
    return stackView
  }()

  private let dateLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 14)
    label.text = "2023. 1. 1"
    return label
  }()

  private let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.alignment = .leading
    return stackView
  }()
  
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

  func bind() {
    self.pinButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, _ in
        owner.delegate?.pinButtonDidTap()
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions
  
  private func updateGift() {
    self.titleLabel.text = self.gift.name
    self.pinButton.isSelected = self.gift.isPinned
    self.dateLabel.text = self.gift.date?.toShortenDateString()
  }
}

// MARK: - UI Setups

extension GiftDetailTitleCell: BaseView {
  func setupStyles() { }

  func setupLayouts() {
    [
      self.titleLabel,
      self.pinButton
    ].forEach {
      self.titleStack.addArrangedSubview($0)
    }

    [
      self.titleStack,
      self.dateLabel
    ].forEach {
      self.stackView.addArrangedSubview($0)
    }

    self.addSubview(self.stackView)
  }

  func setupConstraints() {
    self.stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
