//
//  BaseCardCell.swift
//  Favor
//
//  Created by 이창준 on 2023/03/13.
//

import UIKit

import RxSwift
import SnapKit

open class BaseCardCell: BaseCollectionViewCell, BaseView {

  // MARK: - Constants

  public enum CardCellType {
    /// 기념일 아이콘을 사용
    case anniversary
    /// 리마인더 대상의 프로필 사진을 사용
    case reminder

    public var imageSize: CGFloat {
      switch self {
      case .anniversary: return 36
      case .reminder: return 24
      }
    }

    public var imageColor: UIColor {
      switch self {
      case .anniversary: return .favorColor(.icon)
      case .reminder: return .favorColor(.white)
      }
    }
  }

  private enum Metric {
    static let iconImageSize = 48.0
  }

  // MARK: - Properties

  /// Cell의 좌측에 위치한 아이콘에 들어가는 이미지의 타입
  public var cardCellType: CardCellType? {
    didSet { self.transformToType() }
  }

  /// Cell의 좌측에 위치한 아이콘 ImageView의 UIImage
  public var image: UIImage? {
    didSet { self.updateImage() }
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
  private lazy var profileDefaultImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .favorColor(.line3)
    imageView.image = .favorIcon(.friend)?
      .withRenderingMode(.alwaysTemplate)
      .resize(newWidth: 24)
      .withTintColor(.favorColor(.white))
    imageView.contentMode = .center
    imageView.layer.cornerRadius = Metric.iconImageSize / 2
    imageView.clipsToBounds = true
    return imageView
  }()

  private lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .clear
    imageView.image = .favorIcon(.favor)?
      .withRenderingMode(.alwaysTemplate)
      .resize(newWidth: 36)
      .withTintColor(.favorColor(.icon))
    imageView.contentMode = .center
    imageView.clipsToBounds = true
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
      self.profileDefaultImageView,
      self.imageView,
      self.labelStack
    ].forEach {
      self.addSubview($0)
    }
  }

  open func setupConstraints() {
    self.imageView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.centerY.equalToSuperview()
      make.width.height.equalTo(Metric.iconImageSize)
    }

    self.profileDefaultImageView.snp.makeConstraints { make in
      make.edges.equalTo(self.imageView)
    }

    self.labelStack.snp.makeConstraints { make in
      make.leading.equalTo(self.profileDefaultImageView.snp.trailing).offset(16)
      make.centerY.equalToSuperview()
    }
  }
}

// MARK: - Privates

private extension BaseCardCell {
  func transformToType() {
    guard let cellType = self.cardCellType else {
      fatalError("CellType of Card Cell should be defined.")
    }
    switch cellType {
    case .anniversary:
      self.profileDefaultImageView.isHidden = true
      self.imageView.layer.cornerRadius = 0
    case .reminder:
      self.profileDefaultImageView.isHidden = false
      self.imageView.layer.cornerRadius = Metric.iconImageSize / 2
    }
  }

  func updateImage() {
    guard let cellType = self.cardCellType else {
      fatalError("CellType of Card Cell should be defined.")
    }
    self.imageView.image = self.image?
      .withRenderingMode(.alwaysTemplate)
      .resize(newWidth: cellType.imageSize)
      .withTintColor(cellType.imageColor)
  }

  func updateLabels() {
    self.titleLabel.text = self.title
    self.subtitleLabel.text = self.subtitle
  }
}
