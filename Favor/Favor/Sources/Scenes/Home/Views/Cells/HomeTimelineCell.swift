//
//  HomeTimelineCell.swift
//  Favor
//
//  Created by 이창준 on 2023/01/31.
//

import UIKit

import FavorKit
import Kingfisher
import SnapKit

final class HomeTimelineCell: BaseCollectionViewCell {

  // MARK: - Constants

  private enum Metric {
    static let pinnedIconSize: CGFloat = 32.0
  }
  
  // MARK: - Properties
  
  // MARK: - UI Components
  
  private lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.layer.masksToBounds = true
    imageView.backgroundColor = .favorColor(.background)
    imageView.layer.cornerRadius = 4
    return imageView
  }()
  
  private lazy var pinnedIconView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .center
    imageView.image = .favorIcon(.pin)?.withTintColor(.favorColor(.white))
    return imageView
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
  
  public func bind(with gift: Gift) {
    guard let firstPhotoURL = gift.photos.first?.remote else { return }
    guard let url = URL(string: firstPhotoURL) else { return }
    self.imageView.setImage(from: url, mapper: CacheKeyMapper(gift: gift, subpath: .image(firstPhotoURL)))
    self.pinnedIconView.isHidden = !gift.isPinned
  }
}

extension HomeTimelineCell: BaseView {
  func setupStyles() { }
  
  func setupLayouts() {
    [
      self.imageView,
      self.pinnedIconView
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.imageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.pinnedIconView.snp.makeConstraints { make in
      make.width.height.equalTo(Metric.pinnedIconSize)
      make.top.trailing.equalToSuperview().inset(8)
    }
  }
}
