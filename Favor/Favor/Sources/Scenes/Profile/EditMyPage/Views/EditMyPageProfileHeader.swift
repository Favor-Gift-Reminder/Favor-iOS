//
//  EditMyPageCollectionHeaderView.swift
//  Favor
//
//  Created by 이창준 on 2023/04/25.
//

import UIKit

import FavorKit
import SnapKit

public protocol EditMyPageProfileHeaderDelegate: AnyObject {
  func profileHeader(didTap imageType: EditMyPageProfileHeader.ImageType)
}

public final class EditMyPageProfileHeader: BaseCollectionViewCell {
  
  // MARK: - Enums
  
  public enum ImageType {
    case background, photo
  }

  // MARK: - Constants

  private enum Metric {
    static let backgroundImageHeight = 300.0
    static let profileImageSize = 120.0
  }
  
  public static let identifier = "EditMyPageCollectionHeaderView"
  
  // MARK: - Properties
  
  public weak var delegate: EditMyPageProfileHeaderDelegate?

  // MARK: - UI Components
  
  private let profileBackgroundImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .favorColor(.white)
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    return imageView
  }()
  
  private lazy var profileBackgroundButton: UIButton = {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .favorColor(.black).withAlphaComponent(0.3)
    config.baseForegroundColor = .favorColor(.white)
    config.image = .favorIcon(.gallery)?
      .resize(newWidth: 28.0)
      .withRenderingMode(.alwaysTemplate)
    config.title = "NULL"
    config.attributedTitle = AttributedString("NULL", attributes: .init([
      .foregroundColor: UIColor.clear
    ]))
    config.imagePlacement = .bottom
    config.imagePadding = 24.0
    
    let button = UIButton(configuration: config)
    button.addTarget(self, action: #selector(self.profileBackgroundDidTap(_:)), for: .touchUpInside)
    return button
  }()
  
  private let profilePhotoDefaultImage: UIImage? = .favorIcon(.friend)?
    .withTintColor(.favorColor(.white), renderingMode: .alwaysTemplate)
    .resize(newWidth: 60)
  
  private lazy var profilePhotoImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .favorColor(.line3)
    imageView.layer.cornerRadius = Metric.profileImageSize / 2
    imageView.clipsToBounds = true
    imageView.contentMode = .center
    imageView.image = self.profilePhotoDefaultImage
    imageView.clipsToBounds = true
    return imageView
  }()
  
  private lazy var profilePhotoButton: UIButton = {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .favorColor(.black).withAlphaComponent(0.3)
    config.baseForegroundColor = .favorColor(.white)
    config.image = .favorIcon(.gallery)?
      .resize(newWidth: 28.0)
      .withRenderingMode(.alwaysTemplate)
    
    let button = UIButton(configuration: config)
    button.layer.cornerRadius = Metric.profileImageSize / 2
    button.clipsToBounds = true
    button.addTarget(self, action: #selector(self.profilePhotoDidTap(_:)), for: .touchUpInside)
    return button
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

  // MARK: - Functions
  
  public func updateBackgroundImage(_ image: UIImage?) {
    self.profileBackgroundImageView.image = image
  }
  
  public func updateProfilePhotoImage(_ image: UIImage?) {
    self.profilePhotoImageView.image = image == nil ? self.profilePhotoDefaultImage : image
    self.profilePhotoImageView.contentMode = image == nil ? .center : .scaleAspectFill
  }

  @objc
  private func profileBackgroundDidTap(_ sender: UIButton) {
    self.delegate?.profileHeader(didTap: .background)
  }
  
  @objc
  private func profilePhotoDidTap(_ sender: UIButton) {
    self.delegate?.profileHeader(didTap: .photo)
  }
}

// MARK: - UI Setup

extension EditMyPageProfileHeader: BaseView {
  public func setupStyles() { }

  public func setupLayouts() {
    [
      self.profileBackgroundImageView,
      self.profileBackgroundButton,
      self.profilePhotoImageView,
      self.profilePhotoButton
    ].forEach {
      self.addSubview($0)
    }
  }

  public func setupConstraints() {
    self.profileBackgroundImageView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(Metric.backgroundImageHeight)
    }
    
    self.profileBackgroundButton.snp.makeConstraints { make in
      make.edges.equalTo(self.profileBackgroundImageView)
    }
    
    self.profilePhotoImageView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalTo(self.profileBackgroundImageView.snp.bottom)
      make.width.height.equalTo(Metric.profileImageSize)
    }
    
    self.profilePhotoButton.snp.makeConstraints { make in
      make.edges.equalTo(self.profilePhotoImageView)
    }
  }
}

// MARK: - Privates

private extension EditMyPageProfileHeader {
  
}
