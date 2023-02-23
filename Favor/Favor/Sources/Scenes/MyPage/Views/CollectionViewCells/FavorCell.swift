//
//  FavorCell.swift
//  Favor
//
//  Created by 이창준 on 2023/02/12.
//

import UIKit

import ReactorKit
import SnapKit

class FavorCell: UICollectionViewCell, ReuseIdentifying, View {
  
  // MARK: - Properties
  
  var disposeBag = DisposeBag()
  
  // MARK: - UI Components
  
  private lazy var button = SmallFavorButton(with: .darkWithHeart("취향"))
  
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
  
  func bind(reactor: FavorCellReactor) {
    // Action
    
    // State
    
  }
}

// MARK: - Setup

extension FavorCell: BaseView {
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
