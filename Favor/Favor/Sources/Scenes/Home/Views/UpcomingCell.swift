//
//  UpcomingCell.swift
//  Favor
//
//  Created by 이창준 on 2023/01/31.
//

import UIKit

import ReactorKit
import SnapKit

final class UpcomingCell: UICollectionViewCell, ReuseIdentifying, View {
  
  // MARK: - Properties
  
  var disposeBag = DisposeBag()
  
  // MARK: - UI Components
  
  lazy var testLabel: UILabel = {
    let label = UILabel()
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
  
  func bind(reactor: UpcomingCellReactor) {
    // State
    reactor.state.map { $0.text }
      .do(onNext: {
        print("📝 Test text for upcoming: \($0)")
      })
      .bind(to: self.testLabel.rx.text)
      .disposed(by: self.disposeBag)
  }
  
}

extension UpcomingCell: BaseView {
  
  func setupStyles() {
    self.clipsToBounds = true
    self.layer.cornerRadius = 24
    self.backgroundColor = .magenta// .favorColor(.background)
  }
  
  func setupLayouts() {
    [
      self.testLabel
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.testLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
}
