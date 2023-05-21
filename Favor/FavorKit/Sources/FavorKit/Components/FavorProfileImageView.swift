//
//  FavorProfileImageView.swift
//
//
//  Created by 김응철 on 2023/05/19.
//

import UIKit

import SnapKit
import Then

/// 친구의 이미지를 직접 등록하거나, 프로필 이미지를 추가 및 변경 하려할 때 나타나는 View입니다.
public class FavorProfileImageView: UIView {
  
  public enum Metric {
    static let wholeSize: CGFloat = 120.0
    static let circlePhotoSize: CGFloat = 40.0
  }
  
  // MARK: - UI Components
  
  /// 메인이 되는 뷰 입니다.
  private let mainFriendView: UIButton = UIButton().then {
    var config = UIButton.Configuration.filled()
    config.image = .favorIcon(.friend)?
      .withTintColor(.favorColor(.white))
      .resize(newWidth: 60.0)
    config.baseBackgroundColor = .favorColor(.line3)
    config.baseForegroundColor = .favorColor(.white)
    config.background.cornerRadius = Metric.wholeSize / 2
    $0.configuration = config
    $0.isUserInteractionEnabled = false
  }
  
  /// 사진 이미지가 포함되어 있는 둥근 뷰 입니다.
  private let circlePhotoView: UIButton = UIButton().then {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .favorColor(.line2)
    config.baseForegroundColor = .favorColor(.white)
    config.image = .favorIcon(.photo)?
      .withTintColor(.favorColor(.white))
      .resize(newWidth: 16.0)
    config.background.cornerRadius = Metric.circlePhotoSize / 2
    config.background.strokeWidth = 3
    config.background.strokeColor = .favorColor(.white)
    $0.configuration = config
    $0.isUserInteractionEnabled = false
  }
  
  private let dimmedPhotoView: UIButton = UIButton().then {
    var config = UIButton.Configuration.filled()
    config.background.cornerRadius = Metric.wholeSize / 2
    config.baseBackgroundColor = .favorColor(.black).withAlphaComponent(0.3)
    config.baseForegroundColor = .favorColor(.white)
    config.image = .favorIcon(.photo)?
      .withTintColor(.favorColor(.white))
      .resize(newWidth: 28.0)
    $0.configuration = config
    $0.isUserInteractionEnabled = false
  }
  
  private let imageView: UIImageView = UIImageView().then {
    $0.layer.cornerRadius = Metric.wholeSize / 2
    $0.backgroundColor = .clear
    $0.contentMode = .scaleToFill
  }
  
  // MARK: - Properties
  
  /// + 버튼을 숨기거나 보여지게 합니다.
  /// 숨길경우, 알파처리가 되어있는 사진 아이콘이 나타납니다.
  public var isHiddenPlusView: Bool = false {
    didSet {
      circlePhotoView.isHidden = isHiddenPlusView
      dimmedPhotoView.isHidden = !isHiddenPlusView
    }
  }
  
  /// 이미지를 등록합니다.
  public var image: UIImage? {
    didSet { self.imageView.image = image }
  }
  
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
}

// MARK: - Setup

extension FavorProfileImageView: BaseView {
  public func setupStyles() {}
  
  public func setupLayouts() {
    [
      self.mainFriendView,
      self.circlePhotoView,
      self.imageView,
      self.dimmedPhotoView
    ].forEach {
      self.addSubview($0)
    }
  }
  
  public func setupConstraints() {
    self.snp.makeConstraints { make in
      make.width.height.equalTo(Metric.wholeSize)
    }
    
    self.mainFriendView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.circlePhotoView.snp.makeConstraints { make in
      make.width.height.equalTo(Metric.circlePhotoSize)
      make.bottom.trailing.equalToSuperview()
    }
    
    self.imageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.dimmedPhotoView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
