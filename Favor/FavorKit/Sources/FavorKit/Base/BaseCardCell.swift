//
//  BaseCardCell.swift
//  Favor
//
//  Created by 이창준 on 2023/03/13.
//

import UIKit

import RxSwift
import SnapKit

open class BaseCardCell: UICollectionViewCell, BaseView {

  // MARK: - Constants

  public enum CellType {
    case undefined
    /// 이미지가 친구의 프로필 사진인 셀
    case friend
    /// 이미지가 이벤트 아이콘인 셀
    case event

    var inset: UIEdgeInsets {
      switch self {
      case .event:
        return UIEdgeInsets(top: -6, left: -6, bottom: -6, right: -6)
      default:
        return .zero
      }
    }
  }

  private enum Metric {
    static let iconImageSize = 48.0
  }

  // MARK: - Properties

  public var disposeBag = DisposeBag()

  public var type: CellType = .undefined {
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
    imageView.image = .favorIcon(.friend)?.withTintColor(.favorColor(.white))
    imageView.contentMode = .center
    imageView.layer.cornerRadius = Metric.iconImageSize / 2
    imageView.clipsToBounds = true
    imageView.isHidden = true
    return imageView
  }()

  private lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .clear
    imageView.contentMode = .scaleAspectFill
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
    switch self.type {
    case .undefined: break
    case .friend:
      self.profileDefaultImageView.isHidden = false
      self.imageView.layer.cornerRadius = Metric.iconImageSize / 2
    case .event:
      self.profileDefaultImageView.isHidden = true
      self.imageView.layer.cornerRadius = 0
    }
  }

  func updateImage() {
    self.imageView.image = self.image?.withAlignmentRectInsets(self.type.inset)
  }

  func updateLabels() {
    self.titleLabel.text = self.title
    self.subtitleLabel.text = self.subtitle
  }
}
