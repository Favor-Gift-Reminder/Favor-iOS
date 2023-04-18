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
    case check
    case close
  }
  
  // MARK: - UI Components
  
  private let rightImageView: UIImageView = {
    let iv = UIImageView()
    iv.tintColor = .favorColor(.divider)
    return iv
  }()
  
  // MARK: - Bind
  
  func bind(reactor: NewGiftFriendCellReactor) {
    reactor.state.map { $0.friendName }
      .asDriver(onErrorJustReturn: "")
      .drive(with: self) { $0.friendName = $1 }
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.profileImage }
      .asDriver(onErrorJustReturn: .undefined)
      .drive(with: self) {
        switch $1 {
        case .undefined:
          $0.cellType = .undefined
        case .user(let image):
          $0.cellType = .user(image)
        }
      }
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.rightButtonState }
      .asDriver(onErrorJustReturn: .add)
      .drive(with: self) {
        let icon: UIImage?
        switch $1 {
        case .add:
          icon = .favorIcon(.add)
        case .check:
          icon = .favorIcon(.check)
        case .close:
          icon = .favorIcon(.close)
        }
        $0.rightImageView.image = icon
      }
      .disposed(by: self.disposeBag)
  }
}
