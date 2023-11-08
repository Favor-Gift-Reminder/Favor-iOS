//
//  SearchGiftResultCell.swift
//  Favor
//
//  Created by 이창준 on 2023/04/13.
//

import UIKit

import FavorKit
import SnapKit

final class SearchGiftResultCell: BaseCollectionViewCell {

  // MARK: - Properties

  // MARK: - UI Components
  
  private let thumbnailImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.layer.masksToBounds = true
    return imageView
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 16)
    label.textColor = .favorColor(.white)
    label.lineBreakMode = .byTruncatingTail
    label.text = "페이버"
    return label
  }()

  private let dateLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 14)
    label.textColor = .favorColor(.white)
    return label
  }()

  private lazy var labelStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 4
    return stackView
  }()

  // MARK: - Initializer
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Binding
  
  public func bind(with gift: Gift) {
    self.titleLabel.text = gift.name
    self.dateLabel.text = gift.date?.toShortenDateString()
    guard let firstUrl = gift.photos.first?.remote else { return }
    guard let url = URL(string: firstUrl) else { return }
    self.thumbnailImageView.setImage(from: url, mapper: .init(gift: gift, subpath: .image(firstUrl)))
  }
}

// MARK: - UI Setups

extension SearchGiftResultCell: BaseView {
  func setupStyles() {
    self.backgroundColor = .favorColor(.main)
  }
  
  func setupLayouts() {
    [
      self.titleLabel,
      self.dateLabel
    ].forEach {
      self.labelStack.addArrangedSubview($0)
    }

    [
      self.thumbnailImageView,
      self.labelStack
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.thumbnailImageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.labelStack.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(16)
      make.trailing.lessThanOrEqualToSuperview().inset(32)
      make.bottom.equalToSuperview().inset(16)
    }
  }
}
