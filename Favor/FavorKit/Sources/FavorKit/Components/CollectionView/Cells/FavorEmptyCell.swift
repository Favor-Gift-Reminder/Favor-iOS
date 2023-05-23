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

  /// 외부에서 EmptyCell의 사이즈를 알아야할 때 사용하는 static 상수
  public static let totalHeight = 305.0

  private enum Metric {
    static let imageSize = 183.0
    static let topSpacing = 40.0
  }

  // MARK: - Properties

  /// descriptionLabel에 들어갈 텍스트
  var text: String = "표시할 내용이 없습니다." {
    willSet { self.descriptionLabel.text = newValue }
  }

  /// illustView에 들어갈 이미지
  var image: UIImage? {
    willSet { self.imageView.image = newValue }
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
  public func setupStyles() {
    //
  }

  public func setupLayouts() {
    [
      self.imageView,
      self.descriptionLabel
    ].forEach {
      self.addSubview($0)
    }
  }

  public func setupConstraints() {
    self.imageView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().inset(Metric.topSpacing)
      make.width.equalTo(Metric.imageSize)
      make.height.equalTo(self.imageView.snp.width)
    }

    self.descriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(self.imageView.snp.bottom).offset(32)
      make.centerX.equalToSuperview()
    }
  }
}
