//
//  SearchUserResultCell.swift
//  Favor
//
//  Created by 이창준 on 2023/04/14.
//

import UIKit

import FavorKit
import SnapKit

public protocol SearchUserResultCellDelegate: AnyObject {
  func addFriendButtonDidTap(_ friendUserNo: Int)
}

final class SearchUserResultCell: BaseCollectionViewCell {

  // MARK: - Constants

  private enum Metric {
    static let profileImageSize = 120.0
    static let buttonHeight = 56.0
  }
  
  // MARK: - Properties

  public weak var delegate: SearchUserResultCellDelegate?
  private var user: User?
  
  // MARK: - UI Components
  
  private lazy var profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.layer.cornerRadius = Metric.profileImageSize / 2
    imageView.clipsToBounds = true
    imageView.backgroundColor = .systemGray
    return imageView
  }()

  private lazy var nameLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 20)
    label.textColor = .favorColor(.icon)
    label.textAlignment = .center
    return label
  }()
  
  private lazy var idLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 14)
    label.textColor = .favorColor(.subtext)
    label.textAlignment = .center
    return label
  }()

  private lazy var labelStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 8
    return stackView
  }()
  
  fileprivate lazy var addFriendButton: FavorButton = {
    let button = FavorButton("친구해요!")
    button.baseBackgroundColor = .favorColor(.main)
    button.baseForegroundColor = .white
    button.cornerRadius = Metric.buttonHeight / 2
    button.borderWidth = 1.0
    button.font = .favorFont(.bold, size: 16.0)
    button.addTarget(self, action: #selector(self.addFriendButtonDidTap), for: .touchUpInside)
    button.configurationUpdateHandler = { button in
      guard let button = button as? FavorButton else { return }
      switch button.state {
      case .disabled:
        button.baseBackgroundColor = .favorColor(.white)
        button.baseForegroundColor = .favorColor(.subtext)
        button.borderColor = .favorColor(.divider)
        button.title = "친구가 되었어요!"
      default:
        button.baseBackgroundColor = .favorColor(.main)
        button.baseForegroundColor = .favorColor(.white)
        button.borderColor = .clear
        button.title = "친구해요!"
      }
    }
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
  
  // MARK: - Binding
  
  public func bind(user: User, isAlreadyFriend: Bool) {
    self.user = user
    self.nameLabel.text = user.name
    self.idLabel.text = "@" + user.searchID
    self.addFriendButton.isEnabled = !isAlreadyFriend
    if let urlString = user.profilePhoto?.remote {
      guard let url = URL(string: urlString) else { return }
      self.profileImageView.setImage(from: url, mapper: .init(user: user, subpath: .profilePhoto(urlString)))
      self.profileImageView.contentMode = .scaleAspectFill
    } else {
      self.profileImageView.image = .favorIcon(.friend)?.resize(newWidth: 70).withTintColor(.white)
      self.profileImageView.contentMode = .center
    }
  }
  
  // MARK: - Functions
  
  @objc
  private func addFriendButtonDidTap() {
    guard let user = user else { return }
    self.delegate?.addFriendButtonDidTap(user.identifier)
  }
}

// MARK: - UI Setups

extension SearchUserResultCell: BaseView {
  func setupStyles() {}

  func setupLayouts() {
    [
      self.profileImageView,
      self.labelStack,
      self.addFriendButton
    ].forEach {
      self.addSubview($0)
    }

    [
      self.nameLabel,
      self.idLabel
    ].forEach {
      self.labelStack.addArrangedSubview($0)
    }
  }

  func setupConstraints() {
    self.profileImageView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(140)
      make.centerX.equalToSuperview()
      make.width.height.equalTo(Metric.profileImageSize)
    }

    self.labelStack.snp.makeConstraints { make in
      make.top.equalTo(self.profileImageView.snp.bottom).offset(32)
      make.centerX.equalToSuperview()
    }

    self.addFriendButton.snp.makeConstraints { make in
      make.bottom.equalToSuperview().inset(24)
      make.directionalHorizontalEdges.equalToSuperview().inset(24.0)
      make.height.equalTo(Metric.buttonHeight)
    }
  }
}
