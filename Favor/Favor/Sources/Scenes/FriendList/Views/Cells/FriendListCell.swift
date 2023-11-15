//
//  FriendListCell.swift
//  Favor
//
//  Created by 이창준 on 2023/04/25.
//

import UIKit

import FavorKit
import Reusable

final class FriendListCell: BaseFriendCell, Pressable, Reusable {

  // MARK: - Constants
  
  private enum Metric {
    static let profileImageViewSize = 48.0
    static let rightImageViewSize = 28.0
  }
  
  // MARK: - Properties
  
  var pressedScale: Double = 1.0
  var idleBackgroundColor: UIColor = .favorColor(.white)
  var pressedBackgroundColor: UIColor = .favorColor(.background)
  
  // MARK: - UI Components
  
  private let rightImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .favorIcon(.right)?
      .withRenderingMode(.alwaysTemplate)
      .resize(newWidth: 16)
      .withTintColor(.favorColor(.line2))
    imageView.contentMode = .center
    return imageView
  }()
  
  private let rightIconStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 10
    return stackView
  }()
  
  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.setupLongPressRecognizer()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - UI Setups

  override func setupLayouts() {
    super.setupLayouts()

    self.rightIconStack.addArrangedSubview(self.rightImageView)
    self.containerView.addSubview(self.rightIconStack)
  }

  override func setupConstraints() {
    super.setupConstraints()

    self.rightImageView.snp.makeConstraints { make in
      make.width.height.equalTo(Metric.rightImageViewSize)
    }

    self.rightIconStack.snp.makeConstraints { make in
      make.trailing.equalToSuperview()
      make.centerY.equalToSuperview()
    }
  }
}
