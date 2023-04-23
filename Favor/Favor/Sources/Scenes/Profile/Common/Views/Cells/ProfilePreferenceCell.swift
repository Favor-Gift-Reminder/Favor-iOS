//
//  ProfilePreferenceCell.swift
//  Favor
//
//  Created by 이창준 on 2023/02/12.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import SnapKit

class ProfilePreferenceCell: UICollectionViewCell, Reusable, View {
  
  // MARK: - Properties
  
  var disposeBag = DisposeBag()
  
  // MARK: - UI Components
  
  private let button = FavorSmallButton(with: .darkWithHashTag("취향"))
  
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
  
  // MARK: - Bind
  
  func bind(reactor: ProfilePreferenceCellReactor) {
    // Action
    
    // State
    reactor.state.map { $0.preference }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, preference in
        owner.button.configuration?.updateAttributedTitle(preference, font: .favorFont(.bold, size: 14))
      })
      .disposed(by: self.disposeBag)
  }
}

// MARK: - Setup

extension ProfilePreferenceCell: BaseView {
  func setupStyles() {
    //
  }
  
  func setupLayouts() {
    [
      self.button
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.button.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
