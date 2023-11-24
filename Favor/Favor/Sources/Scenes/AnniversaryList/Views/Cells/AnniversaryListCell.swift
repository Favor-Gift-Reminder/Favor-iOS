//
//  AnniversaryListCell.swift
//  Favor
//
//  Created by 이창준 on 2023/05/16.
//

import UIKit

import FavorKit
import Reusable
import RxCocoa
import RxSwift
import SnapKit

public final class AnniversaryListCell: BaseCardCell, Reusable {

  // MARK: - Properties

  public weak var delegate: CellModelTransferDelegate?

  // MARK: - Constants

  public enum CellType: Hashable {
    case list
    case edit
    case friend

    public var rightButtonImage: UIImage? {
      switch self {
      case .list:
        return .favorIcon(.pin)
      case .edit:
        return .favorIcon(.edit)
      case .friend:
        return .favorIcon(.addnoti)
      }
    }
  }
  
  private enum Metric {
    static let rightButtonSize = 48.0
    static let rightButtonImageSize = 22.0
  }

  // MARK: - Properties

  public var cellModel: AnniversaryListCellModel? {
    didSet { self.updateCell() }
  }

  // MARK: - UI Components

  fileprivate let rightButton: FavorButton = {
    let button = FavorButton()
    button.baseBackgroundColor = .clear
    button.image = .favorIcon(.addnoti)
    button.contentInset = .zero
    return button
  }()

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.bind()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  public func bind(_ cellModel: AnniversaryListCellModel) {
    self.cellModel = cellModel
  }

  public func bind() {
    self.rightButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, _ in
        owner.delegate?.transfer(self.cellModel, from: self)
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - UI Setups
  
  public override func setupLayouts() {
    super.setupLayouts()

    self.addSubview(self.rightButton)
  }

  public override func setupConstraints() {
    super.setupConstraints()

    self.rightButton.snp.makeConstraints { make in
      make.right.equalToSuperview().inset(16)
      make.centerY.equalToSuperview()
      make.width.height.equalTo(Metric.rightButtonSize)
    }
  }
}

// MARK: - Privates

private extension AnniversaryListCell {
  func updateCell() {
    guard let cellModel else { return }
    self.image = nil
    self.title = cellModel.item.name
    self.subtitle = cellModel.item.date.toShortenDateString()
    
    // type == .list이고 isPinned일때만 .icon
    // 아니면 line2
    let iconColor: UIColor = cellModel.item.isPinned && cellModel.cellType == .list ?
      .favorColor(.icon) :
      .favorColor(.line2)
    if cellModel.cellType == .friend {
      self.rightButton.image = .favorIcon(.addnoti)?
        .resize(newWidth: Metric.rightButtonImageSize)
    } else {
      self.rightButton.image = cellModel.cellType.rightButtonImage?
        .resize(newWidth: Metric.rightButtonImageSize)
        .withTintColor(iconColor)
    }
    self.imageView.contentMode = .center
    self.image = cellModel.item.category.image
  }
}
