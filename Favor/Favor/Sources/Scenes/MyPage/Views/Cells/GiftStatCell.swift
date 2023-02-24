//
//  GiftStatCell.swift
//  Favor
//
//  Created by 이창준 on 2023/02/12.
//

import UIKit

import ReactorKit
import SnapKit

final class GiftStatCell: UICollectionViewCell, ReuseIdentifying, View {
  
  // MARK: - Properties
  
  var disposeBag = DisposeBag()
  
  // MARK: - UI Components
  
  private lazy var hStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.distribution = .equalSpacing
    stackView.spacing = 72
    return stackView
  }()
  
  private lazy var totalGiftCountLabel: UILabel = self.makeCountLabel()
  private lazy var totalGiftTitleLabel: UILabel = self.makeTitleLabel(title: "총 선물")
  private lazy var totalGiftStack: UIStackView = self.makeGiftItem(
    countLabel: self.totalGiftCountLabel,
    titleLabel: self.totalGiftTitleLabel
  )
  
  private lazy var receivedGiftCountLabel: UILabel = self.makeCountLabel()
  private lazy var receivedGiftTItleLabel: UILabel = self.makeTitleLabel(title: "받은 선물")
  private lazy var receivedGiftStack: UIStackView = self.makeGiftItem(
    countLabel: self.receivedGiftCountLabel,
    titleLabel: self.receivedGiftTItleLabel
  )
  
  private lazy var givenGiftCountLabel: UILabel = self.makeCountLabel()
  private lazy var givenGiftTitleLabel: UILabel = self.makeTitleLabel(title: "준 선물")
  private lazy var givenGiftStack: UIStackView = self.makeGiftItem(
    countLabel: self.givenGiftCountLabel,
    titleLabel: self.givenGiftTitleLabel
  )
  
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
  
  func bind(reactor: GiftStatCellReactor) {
    // Action
    
    // State
    
  }
}

// MARK: - Setup

extension GiftStatCell: BaseView {
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
    
    [
      self.totalGiftStack,
      self.receivedGiftStack,
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
  }
}

// MARK: - Privates

private extension GiftStatCell {
  func makeGiftItem(countLabel: UILabel, titleLabel: UILabel) -> UIStackView {
    let stackView = self.makeGiftStackView()
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
