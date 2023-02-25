//
//  GiftStatsCell.swift
//  Favor
//
//  Created by 이창준 on 2023/02/12.
//

import UIKit

import ReactorKit
import SnapKit

final class GiftStatsCell: UICollectionViewCell, ReuseIdentifying, View {

  // MARK: - Constants

  private enum Metric {
    static let twoItemsSpacing = 120.0
    static let threeItemsSpacing = 72.0
  }
  
  // MARK: - Properties
  
  var disposeBag = DisposeBag()
  
  // MARK: - UI Components
  
  private lazy var hStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.distribution = .equalSpacing
    stackView.spacing = Metric.threeItemsSpacing
    return stackView
  }()

  private lazy var totalStack: UIStackView = self.makeGiftStackItem(title: "총 선물")

  private lazy var receivedStack: UIStackView = self.makeGiftStackItem(title: "받은 선물")

  private lazy var givenGiftStack: UIStackView = self.makeGiftStackItem(title: "준 선물")
  
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
  
  func bind(reactor: GiftStatsCellReactor) {
    // Action
    
    // State
    
  }
}

// MARK: - Setup

extension GiftStatsCell: BaseView {
  func setupStyles() {
    self.backgroundColor = .favorColor(.background)
    self.round(corners: [.topLeft, .topRight], radius: 24)
  }
  
  func setupLayouts() {
    [
      self.hStack
    ].forEach {
      self.addSubview($0)
    }

    // TODO: Stack을 넣고 뺴는 로직 필요
    [
      self.totalStack,
      self.receivedStack,
      self.givenGiftStack
    ].forEach {
      self.hStack.addArrangedSubview($0)
    }
  }
  
  func setupConstraints() {
    self.hStack.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(30)
      make.bottom.equalToSuperview().inset(40)
      make.centerX.equalToSuperview()
    }

    let numberOfItems = self.hStack.arrangedSubviews.count
    self.hStack.spacing = (numberOfItems == 2) ? Metric.twoItemsSpacing : Metric.threeItemsSpacing
  }
}

// MARK: - Privates

private extension GiftStatsCell {
  func makeGiftStackItem(title: String) -> UIStackView {
    let stackView = self.makeGiftStackView()
    let countLabel = self.makeCountLabel()
    let titleLabel = self.makeTitleLabel(title: title)
    [
      countLabel,
      titleLabel
    ].forEach {
      stackView.addArrangedSubview($0)
    }
    return stackView
  }

  func makeGiftStackView() -> UIStackView {
    let vStack = UIStackView()
    vStack.axis = .vertical
    vStack.spacing = 16
    vStack.distribution = .fillProportionally
    return vStack
  }
  
  func makeCountLabel() -> UILabel {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 22)
    label.textAlignment = .center
    label.text = "-1"
    return label
  }
  
  func makeTitleLabel(title: String) -> UILabel {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 16)
    label.textAlignment = .center
    label.text = title
    return label
  }
}
