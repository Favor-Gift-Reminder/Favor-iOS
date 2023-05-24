//
//  FavorEmptyCell.swift
//  Favor
//
//  Created by 이창준 on 2023/02/04.
//

import UIKit

import Reusable
import SnapKit

public final class FavorEmptyCell: BaseCollectionViewCell, Reusable {

  // MARK: - Constants

  private enum Metric {
    static let imageSize: CGFloat = 150.0
  }

  // MARK: - Properties

  /// descriptionLabel에 들어갈 텍스트
  var text: String = "표시할 내용이 없습니다." {
    didSet { self.descriptionLabel.text = self.text }
  }

  /// illustView에 들어갈 이미지
  var image: UIImage? {
    didSet { self.imageView.image = self.image }
  }

  // MARK: - UI Components

  private lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .favorColor(.background)
    return imageView
  }()

  private lazy var descriptionLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 18)
    label.textColor = .favorColor(.explain)
    label.textAlignment = .center
    label.text = self.text
    return label
  }()

  private lazy var stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.alignment = .center
    return stackView
  }()

  // MARK: - Initializer

  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  public func bindEmptyData(image: UIImage? = nil, text: String) {
    self.image = image
    self.text = text
  }
}

// MARK: - Setup

extension FavorEmptyCell: BaseView {
  public func setupStyles() { }

  public func setupLayouts() {
    [
      self.imageView,
      self.descriptionLabel
    ].forEach {
      self.stackView.addArrangedSubview($0)
    }

    self.addSubview(self.stackView)
  }

  public func setupConstraints() {
    self.imageView.snp.makeConstraints { make in
      make.width.equalTo(Metric.imageSize)
      make.height.equalTo(self.imageView.snp.width)
    }

    self.stackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
}
