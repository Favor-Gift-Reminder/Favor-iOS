//
//  NewGiftFriendCell.swift
//  Favor
//
//  Created by 김응철 on 2023/04/15.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable

final class NewGiftFriendCell: BaseFriendCell, View, Reusable {
  
  enum RightButtonType {
    case add
    case done
    case remove
  }
  
  // MARK: - UI Components
  
  private let rightImageView: UIImageView = {
    let iv = UIImageView()
    iv.image = .favorIcon(.newGift)?.withTintColor(.favorColor(.line3))
    return iv
  }()
  
  // MARK: - Properties
  
  var currentButtonType: RightButtonType = .add {
    didSet {
      let image: UIImage?
      switch currentButtonType {
      case .add:
        image = .favorIcon(.newGift)?.withTintColor(.favorColor(.line3))
      case .remove:
        image = .favorIcon(.remove)?.withTintColor(.favorColor(.line3))
      case .done:
        image = .favorIcon(.done)?.withTintColor(.favorColor(.line3))
      }
      self.rightImageView.image = image
    }
  }
  
  // MARK: - Bind
  
  func bind(reactor: NewGiftFriendCellReactor) {
    reactor.state.map { $0.friend }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) {
        $0.friendName = $1.name
        // TODO: 이미지 설정
      }
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.rightButtonState }
      .asDriver(onErrorJustReturn: .add)
      .drive(with: self) {
        $0.currentButtonType = $1
      }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Setup
  
  override func setupLayouts() {
    super.setupLayouts()
    
    self.contentView.addSubview(self.rightImageView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.rightImageView.snp.makeConstraints { make in
      make.width.height.equalTo(18.0)
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(25.0)
    }
  }
}
