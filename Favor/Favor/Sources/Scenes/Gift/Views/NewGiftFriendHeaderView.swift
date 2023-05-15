//
//  NewGiftFriendHeaderView.swift
//  Favor
//
//  Created by 김응철 on 2023/04/15.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import SnapKit

final class NewGiftFriendHeaderView: UICollectionReusableView, Reusable, View {
  
  // MARK: - UI Components
  
  private let titleLabel: UILabel = {
    let lb = UILabel()
    lb.font = .favorFont(.bold, size: 18)
    lb.textColor = .favorColor(.icon)
    return lb
  }()
  
  private let countLabel: UILabel = {
    let lb = UILabel()
    lb.font = .favorFont(.bold, size: 18)
    lb.textColor = .favorColor(.icon)
    return lb
  }()
  
  let searchBar: FavorSearchBar = {
    let sb = FavorSearchBar()
    sb.hasBackButton = false
    return sb
  }()
  
  // MARK: - Properties
  
  var disposeBag = DisposeBag()
  var textFieldChanged: ((String) -> Void)?

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
  
  func bind(reactor: NewGiftFriendHeaderViewReactor) {
    // Action
    self.searchBar.rx.text
      .orEmpty
      .asDriver()
      .skip(1)
      .debug()
      .drive(with: self) { $0.textFieldChanged?($1) }
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { $0.sectionModel }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, sectionModel in
        switch sectionModel.model {
        case .friendList:
          owner.titleLabel.text = "친구"
          owner.searchBar.isHidden = false
        case .selectedFriends:
          owner.titleLabel.text = "선택한 친구"
          owner.searchBar.isHidden = true
        }
        
        var count: Int = 0
        sectionModel.items.forEach {
          switch $0 {
          case .empty:
            break
          case .friend:
            count += 1
          }
        }
        owner.countLabel.text = "\(count)"
      }
      .disposed(by: self.disposeBag)
  }
}

extension NewGiftFriendHeaderView: BaseView {
  func setupStyles() {}
  
  func setupLayouts() {
    [
      self.titleLabel,
      self.countLabel,
      self.searchBar
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.titleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.equalToSuperview().inset(32)
    }
    
    self.countLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.titleLabel.snp.trailing).offset(8)
      make.centerY.equalTo(self.titleLabel)
    }
    
    self.searchBar.snp.makeConstraints { make in
      make.top.equalTo(self.titleLabel.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
}
