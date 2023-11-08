//
//  GiftDetailImageCell.swift
//  Favor
//
//  Created by 이창준 on 2023/05/25.
//

import UIKit

import FavorKit
import Reusable
import SnapKit

public final class GiftDetailImageCell: BaseCollectionViewCell {

  // MARK: - UI Components

  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.layer.masksToBounds = true
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
  
  // MARK: - Configure
  
  public func configure(gift: Gift, index: Int) {
    let urlString = gift.photos[index].remote
    guard let url = URL(string: urlString) else { return }
    self.imageView.setImage(from: url, mapper: CacheKeyMapper(gift: gift, subpath: .image(urlString)))
  }
}

// MARK: - UI Setups

extension GiftDetailImageCell: BaseView {
  public func setupStyles() {}

  public func setupLayouts() {
    self.addSubview(self.imageView)
  }

  public func setupConstraints() {
    self.imageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
