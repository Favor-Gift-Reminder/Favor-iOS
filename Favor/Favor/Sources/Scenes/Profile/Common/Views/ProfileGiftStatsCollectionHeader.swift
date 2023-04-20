//
//  ProfileGiftStatsCollectionHeader.swift
//  Favor
//
//  Created by 이창준 on 2023/02/12.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import SnapKit

final class ProfileGiftStatsCollectionHeader: UICollectionReusableView, Reusable, View {

  // MARK: - Constants
  
  // MARK: - Properties
  
  var disposeBag = DisposeBag()
  
  // MARK: - UI Components
  
  private lazy var statsStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.distribution = .equalCentering
    return stackView
  }()

  private lazy var totalGiftsButton = self.makeButton(title: "총 선물")
  private lazy var receivedGiftsButton = self.makeButton(title: "받은 선물")
  private lazy var givenGiftsButton = self.makeButton(title: "준 선물")
  
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
  
  func bind(reactor: ProfileGiftStatsCollectionHeaderReactor) {
    // Action
    
    // State
    
  }
}

// MARK: - Setup

extension ProfileGiftStatsCollectionHeader: BaseView {
  func setupStyles() {
    self.backgroundColor = .favorColor(.white)
    self.round(corners: [.topLeft, .topRight], radius: 24)
  }
  
  func setupLayouts() {
    self.addSubview(self.statsStack)

    [
      self.totalGiftsButton,
      self.receivedGiftsButton,
      self.givenGiftsButton
    ].forEach {
      self.statsStack.addArrangedSubview($0)
    }
  }
  
  func setupConstraints() {
    self.statsStack.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(24)
      make.directionalHorizontalEdges.equalToSuperview().inset(40)
      make.centerX.equalToSuperview()
    }
  }
}

// MARK: - Privates

private extension ProfileGiftStatsCollectionHeader {
  func makeButton(title: String) -> UIButton {
    var config = UIButton.Configuration.plain()
    config.updateAttributedTitle("-1", font: .favorFont(.bold, size: 22))
    config.titleAlignment = .center
    config.titlePadding = 16

    var container = AttributeContainer()
    container.font = .favorFont(.regular, size: 16)
    config.attributedSubtitle = AttributedString(title, attributes: container)

    config.background.backgroundColor = .clear
    config.baseForegroundColor = .favorColor(.icon)

    let button = UIButton(configuration: config)
    return button
  }
}
