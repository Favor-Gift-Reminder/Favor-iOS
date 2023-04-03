//
//  FavorIconImageView.swift
//  Favor
//
//  Created by 이창준 on 2023/04/02.
//

import UIKit

import SnapKit

open class FavorIconImageView: UIView {

  public enum ImageType {
    case profile, event
  }

  // MARK: - Properties

  public var type: ImageType? {
    didSet { self.update(type: self.type ?? .profile) }
  }

  public var image: UIImage? {
    didSet { self.update(image: self.image) }
  }

  public var placeholderImage: UIImage? = .favorIcon(.friend) {
    didSet { }
  }

  public var imageColor: UIColor = .favorColor(.white) {
    didSet { }
  }

  private var emptyEdgeInsets: UIEdgeInsets = .zero

  /// ImageView 자체의 `cornerRadius`
  public var cornerRadius: CGFloat = 24.0 {
    didSet { self.layer.cornerRadius = self.cornerRadius }
  }

  // MARK: - UI Components

  private lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()

  // MARK: - Initializer

  private override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }

  public convenience init(_ type: ImageType, image: UIImage? = nil) {
    self.init(frame: .zero)
    self.update(type: type)
    self.update(image: image)
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Life Cycle

  open override func layoutSubviews() {
    super.layoutSubviews()

    self.layer.cornerRadius = self.cornerRadius
  }

  // MARK: - Functions

  /// `type`을 업데이트합니다.
  public func update(type: ImageType) {
    guard type != self.type else { return }

    defer { self.type = type }

    self.backgroundColor = type == .event ? .clear : .favorColor(.line3)
    self.emptyEdgeInsets = {
      type == .event ? .zero : UIEdgeInsets(top: -12, left: -12, bottom: -12, right: -12)
    }()
  }

  /// `image`를 업데이트합니다.
  public func update(image: UIImage?) {
    guard self.type != .event else {
      fatalError("Event type icon should not be nil.")
    }

    if image == nil {
      self.imageView.image = self.placeholderImage?
        .withTintColor(self.imageColor)
        .withAlignmentRectInsets(self.emptyEdgeInsets)
    } else {
      self.imageView.image = image
    }
  }
}

extension FavorIconImageView: BaseView {
  public func setupStyles() {
    self.clipsToBounds = true
  }

  public func setupLayouts() {
    self.addSubview(self.imageView)
  }

  public func setupConstraints() {
    self.imageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
