//
//  GiftManagementPhotoCell.swift
//  Favor
//
//  Created by 이창준 on 2023/05/29.
//

import UIKit

import FavorKit
import RxCocoa
import RxSwift
import SnapKit

public protocol GiftManagementPhotoCellDelegate: AnyObject {
  func removeButtonDidTap(from cell: GiftManagementPhotoCell)
}

public final class GiftManagementPhotoCell: BaseCollectionViewCell {

  // MARK: - Constants

  private enum Metric {
    static let closeButtonInset: CGFloat = 12.0
  }

  // MARK: - Properties

  public weak var delegate: GiftManagementPhotoCellDelegate?

  // MARK: - UI Components

  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .favorColor(.line3)
    imageView.contentMode = .center
    imageView.image = .favorIcon(.gallery)?
      .withRenderingMode(.alwaysTemplate)
      .resize(newWidth: 40)
      .withTintColor(.favorColor(.white))
    return imageView
  }()

  private let removeButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.baseForegroundColor = .favorColor(.white)
    config.image = .favorIcon(.remove)?
      .withRenderingMode(.alwaysTemplate)
    config.contentInsets = .zero

    let button = UIButton(configuration: config)
    button.contentMode = .center
    button.isHidden = true
    return button
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

  private func bind() {
    self.removeButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, _ in
        owner.delegate?.removeButtonDidTap(from: self)
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  public func bind(with image: UIImage?) {
    guard let image else { return }
    self.imageView.contentMode = .scaleAspectFill
    self.imageView.image = image
    self.removeButton.isHidden = false
  }
}

// MARK: - UI Setups

extension GiftManagementPhotoCell: BaseView {
  public func setupStyles() {
    self.layer.cornerRadius = 8
    self.clipsToBounds = true
  }

  public func setupLayouts() {
    [
      self.imageView,
      self.removeButton
    ].forEach {
      self.contentView.addSubview($0)
    }
  }

  public func setupConstraints() {
    self.imageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.removeButton.snp.makeConstraints { make in
      make.top.trailing.equalToSuperview().inset(Metric.closeButtonInset)
    }
  }
}
