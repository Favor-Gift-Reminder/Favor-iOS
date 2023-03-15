//
//  TimelineCell.swift
//  Favor
//
//  Created by 이창준 on 2023/01/31.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import RxCocoa
import SnapKit

final class TimelineCell: UICollectionViewCell, Reusable, View {
  
  // MARK: - Properties
  
  var disposeBag = DisposeBag()
  
  // MARK: - UI Components

  private lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.backgroundColor = .favorColor(.background)
    return imageView
  }()

  private lazy var pinnedIconView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .center
    imageView.image = .favorIcon(.pin)?.withTintColor(.favorColor(.white))
    return imageView
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
  
  func bind(reactor: TimelineCellReactor) {
    // Action
    
    // State
    reactor.state.map { $0.image }
      .bind(to: self.imageView.rx.image)
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.isPinned }
      .asDriver(onErrorRecover: { _ in return .never()})
      .drive(with: self, onNext: { owner, isPinned in
        owner.pinnedIconView.isHidden = !isPinned
      })
      .disposed(by: self.disposeBag)
  }
}

extension TimelineCell: BaseView {
  func setupStyles() {
    //
  }
  
  func setupLayouts() {
    [
      self.imageView,
      self.pinnedIconView
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.imageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.pinnedIconView.snp.makeConstraints { make in
      make.width.height.equalTo(32)
      make.top.trailing.equalToSuperview().inset(8)
    }
  }
}
