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
  func removeButtonDidTap(from imageModel: GiftManagementPhotoModel?)
}

public final class GiftManagementPhotoCell: BaseCollectionViewCell {

  // MARK: - Constants

  private enum Metric {
    static let closeButtonInset: CGFloat = 12.0
  }

  // MARK: - Properties

  public weak var delegate: GiftManagementPhotoCellDelegate?
  public var removeButtonTapped: ((UIImage?) -> Void)?
  private var imageModel: GiftManagementPhotoModel?

  // MARK: - UI Components

  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .favorColor(.line3)
    imageView.contentMode = .center
    imageView.contentMode = .scaleAspectFill
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
        owner.delegate?.removeButtonDidTap(from: self.imageModel)
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  public func bind(with model: GiftManagementPhotoModel?, gift: Gift = Gift()) {
    guard let model = model else {
      self.imageView.contentMode = .center
      self.imageView.image = .favorIcon(.gallery)?
        .withRenderingMode(.alwaysTemplate)
        .resize(newWidth: 40)
        .withTintColor(.favorColor(.white))
      return
    }
    
    self.imageModel = model
    if let urlString = model.url {
      // URL을 가지고 있는 기존에 저장되어 있는 이미지
      guard let url = URL(string: urlString) else { return }
      self.imageView.setImage(from: url, mapper: CacheKeyMapper(gift: gift, subpath: .image(urlString)))
    } else {
      // 갤러리에서 추가된 이미지
      self.imageView.image = model.image
    }
    self.imageView.contentMode = .scaleAspectFill
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
