//
//  FavorFriendCell.swift
//  
//
//  Created by 김응철 on 2023/04/14.
//

import UIKit

import ReactorKit
import RxCocoa
import RxGesture
import RxSwift
import SnapKit

open class BaseFriendCell: BaseCollectionViewCell, BaseView {
  
  public enum FriendCellType {
    case undefined
    case user(UIImage?)
  }
  
  enum Constants {
    static let imageViewSize: CGFloat = 48.0
  }
  
  // MARK: - Properties
  
  public var friendName: String = "" {
    didSet {
      self.nameLabel.text = friendName
    }
  }
  
  public var userImage: FriendCellType = .undefined {
    didSet {
      switch userImage {
      case .undefined:
        self.imageView.isHidden = true
        self.circleView.isHidden = false
        self.friendImageView.isHidden = false
      case .user(let image):
        self.imageView.image = image
        self.imageView.isHidden = false
        self.circleView.isHidden = true
        self.friendImageView.isHidden = true
      }
    }
  }
  
  // MARK: - UI Components
  
  private let imageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    iv.backgroundColor = .clear
    iv.layer.cornerRadius = Constants.imageViewSize / 2
    iv.layer.masksToBounds = true
    return iv
  }()
  
  private let circleView: UIView = {
    let view = UIView()
    view.backgroundColor = .favorColor(.line3)
    view.layer.cornerRadius = Constants.imageViewSize / 2
    return view
  }()
  
  private let nameLabel: UILabel = {
    let lb = UILabel()
    lb.font = .favorFont(.regular, size: 16)
    lb.textColor = .favorColor(.icon)
    return lb
  }()
  
  private let friendImageView: UIImageView = {
    let iv = UIImageView()
    iv.image = .favorIcon(.friend)?.withTintColor(.favorColor(.white))
    return iv
  }()
  
  // MARK: - Initializer
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  open func setupStyles() {}
  
  open func setupLayouts() {
    [
      self.imageView,
      self.circleView,
      self.friendImageView,
      self.nameLabel
    ].forEach {
      self.contentView.addSubview($0)
    }
  }
  
  open func setupConstraints() {
    self.imageView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.centerY.equalToSuperview()
      make.width.height.equalTo(Constants.imageViewSize)
    }
    
    self.circleView.snp.makeConstraints { make in
      make.edges.equalTo(self.imageView)
    }
    
    self.friendImageView.snp.makeConstraints { make in
      make.center.equalTo(self.imageView)
      make.width.height.equalTo(Constants.imageViewSize / 2)
    }
    
    self.nameLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.imageView.snp.trailing).offset(16.0)
      make.centerY.equalToSuperview()
    }
  }
}
