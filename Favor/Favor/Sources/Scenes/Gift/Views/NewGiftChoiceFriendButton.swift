//
//  ChoiceFriendButton.swift
//  Favor
//
//  Created by 김응철 on 2023/03/30.
//

import UIKit

import FavorKit
import SnapKit
import RxCocoa
import RxSwift

final class NewGiftChoiceFriendButton: UIButton {
  
  // MARK: - UI
  
  private var textAttributes: AttributeContainer = {
    var container = AttributeContainer()
    container.font = .favorFont(.regular, size: 16)
    return container
  }()
  
  private let rightArrowImage: UIImage? = .favorIcon(.right)?
    .resize(newWidth: 11)
    .withTintColor(.favorColor(.explain))
  
  // MARK: - Properties
  
  let currentFriend = BehaviorRelay<String>(value: "")
  private let disposeBag = DisposeBag()
  
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    
    self.currentFriend
      .skip(1)
      .asDriver(onErrorJustReturn: "")
      .drive(with: self) { owner, _ in
        owner.updateUI()
      }
      .disposed(by: self.disposeBag)
    
    self.rx.tap
      .skip(1)
      .map { "안녕" }
      .bind(to: self.currentFriend)
      .disposed(by: self.disposeBag)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setupStyles() {
    var config = UIButton.Configuration.plain()
    config.attributedTitle = AttributedString("친구 선택", attributes: self.textAttributes)
    config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    config.baseForegroundColor = .favorColor(.explain)
    config.image = self.rightArrowImage
    config.imagePadding = 8
    config.imagePlacement = .trailing
    self.configuration = config
  }
  
  // MARK: - Functions
  
  func updateUI() {
    let newImage = self.rightArrowImage?.withTintColor(.favorColor(.icon))
    self.configuration?.baseForegroundColor = .favorColor(.icon)
    self.configuration?.image = newImage
    self.configuration?.attributedTitle = AttributedString(
      self.currentFriend.value,
      attributes: self.textAttributes
    )
  }
}
