//
//  ProfileFriendCell.swift
//  Favor
//
//  Created by 이창준 on 2023/02/22.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import SnapKit

final class ProfileFriendCell: BaseCollectionViewCell, Reusable, View {

  // MARK: - Constants

  // MARK: - Properties
    
  // MARK: - UI Components
  
  private let favorProfilePhotoView = FavorProfilePhotoView(.big)
  
  private let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .fill
    stackView.spacing = 8
    return stackView
  }()

  private let nameLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 14)
    label.textColor = .favorColor(.icon)
    label.textAlignment = .center
    label.text = "이름"
    return label
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
  
  func bind(reactor: ProfileFriendCellReactor) {
    // Action
    
    // State
    reactor.state.map { (friend: $0.friend, isNewFriendCell: $0.isNewFriendCell) }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, friendData in
        let friend = friendData.friend
        owner.nameLabel.text = friendData.isNewFriendCell ? "추가하기" : friend.friendName
        owner.favorProfilePhotoView.isNewFriendCell = friendData.isNewFriendCell
        owner.favorProfilePhotoView.profileImage = friend.profilePhoto
      })
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions
  
}

// MARK: - UI Setups

extension ProfileFriendCell: BaseView {
  func setupStyles() {}

  func setupLayouts() {
    [
      self.favorProfilePhotoView,
      self.nameLabel
    ].forEach {
      self.stackView.addArrangedSubview($0)
    }

    self.addSubview(self.stackView)
  }

  func setupConstraints() {
    self.stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.favorProfilePhotoView.snp.makeConstraints { make in
      make.width.height.equalTo(60)
    }
  }
}
