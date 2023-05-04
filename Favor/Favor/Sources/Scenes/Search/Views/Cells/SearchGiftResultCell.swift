//
//  SearchGiftResultCell.swift
//  Favor
//
//  Created by 이창준 on 2023/04/13.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import SnapKit

final class SearchGiftResultCell: UICollectionViewCell, View, Reusable { // TODO: BaseCollectionViewCell로 변경

  // MARK: - Properties

  public var disposeBag = DisposeBag()

  // MARK: - UI Components

  private let thumbnailImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 16)
    label.lineBreakMode = .byTruncatingTail
    label.text = "페이버"
    return label
  }()

  private let dateLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 14)
    return label
  }()

  private lazy var labelStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 4
    return stackView
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

  func bind(reactor: SearchGiftResultCellReactor) {
    // Action

    // State
    reactor.state.map { $0.gift }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, gift in
        // image
        owner.titleLabel.text = gift.name
        owner.dateLabel.text = gift.date?.toShortenDateString()
      })
      .disposed(by: self.disposeBag)
  }
}

// MARK: - UI Setups

extension SearchGiftResultCell: BaseView {
  func setupStyles() {
    self.backgroundColor = .favorColor(.main)
  }

  func setupLayouts() {
    [
      self.thumbnailImageView,
      self.labelStack
    ].forEach {
      self.addSubview($0)
    }

    [
      self.titleLabel,
      self.dateLabel
    ].forEach {
      self.labelStack.addArrangedSubview($0)
    }
  }

  func setupConstraints() {
    self.thumbnailImageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.labelStack.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(16)
      make.trailing.equalToSuperview().inset(30)
      make.bottom.equalToSuperview().inset(16)
    }
  }
}
