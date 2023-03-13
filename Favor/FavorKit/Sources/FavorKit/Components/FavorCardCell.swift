//
//  FavorCardCell.swift
//  Favor
//
//  Created by 이창준 on 2023/03/13.
//

import UIKit

import RxSwift
import SnapKit

open class FavorCardCell: UICollectionViewCell, BaseView {

  // MARK: - Constants

  // MARK: - Properties

  public var disposeBag = DisposeBag()

  /// Cell의 좌측에 위치한 아이콘 ImageView의 UIImage
  public var iconImage: UIImage? {
    didSet { self.updateIcon() }
  }

  /// Cell의 제목 String
  public var title: String? {
    didSet { self.updateLabels() }
  }

  /// Cell의 제목 밑에 있는 부제목 String
  public var subtitle: String? {
    didSet { self.updateLabels() }
  }

  // MARK: - UI Components

  /// Cell 좌측에 위치한 아이콘이나 프로필 사진 등의 이미지가 채워지는 ImageView
  private lazy var iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.image = UIImage(systemName: "questionmark.square.dashed")
    return imageView
  }()

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 18)
    label.textAlignment = .left
    label.text = "타이틀"
    return label
  }()

  private lazy var subtitleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 16)
    label.textAlignment = .left
    label.text = "서브타이틀"
    return label
  }()

  private lazy var labelStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 8
    return stackView
  }()

  // MARK: - Initializer

  public override init(frame: CGRect) {
    super.init(frame: frame)

    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  // MARK: - UI Setup

  open func setupStyles() {
    self.clipsToBounds = true
    self.layer.cornerRadius = 24
    self.backgroundColor = .favorColor(.card)
  }

  open func setupLayouts() {
    [
      self.titleLabel,
      self.subtitleLabel
    ].forEach {
      self.labelStack.addArrangedSubview($0)
    }

    [
      self.iconImageView,
      self.labelStack
    ].forEach {
      self.addSubview($0)
    }
  }

  open func setupConstraints() {
    self.iconImageView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.centerY.equalToSuperview()
      make.height.width.equalTo(48)
    }

    self.labelStack.snp.makeConstraints { make in
      make.leading.equalTo(self.iconImageView.snp.trailing).offset(16)
      make.centerY.equalToSuperview()
    }
  }
}

// MARK: - Privates

private extension FavorCardCell {
  func updateIcon() {
    self.iconImageView.image = self.iconImage
  }

  func updateLabels() {
    self.titleLabel.text = self.title
    self.subtitleLabel.text = self.subtitle
  }
}
