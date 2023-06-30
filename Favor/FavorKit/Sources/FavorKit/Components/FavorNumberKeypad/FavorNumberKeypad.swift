//
//  FavorNumberKeypad.swift
//  Favor
//
//  Created by 이창준 on 6/29/23.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

// MARK: - CellModel

public enum FavorNumberKeypadCellModel: Hashable {
  case keyString(String)
  case keyImage(UIImage)

  public static func == (lhs: FavorNumberKeypadCellModel, rhs: FavorNumberKeypadCellModel) -> Bool {
    switch (lhs, rhs) {
    case let (.keyString(lhsKeyString), .keyString(rhsKeyString)):
      return lhsKeyString == rhsKeyString
    case let (.keyImage(lhsKeyImage), .keyImage(rhsKeyImage)):
      return lhsKeyImage == rhsKeyImage
    default:
      return false
    }
  }

  public func hash(into hasher: inout Hasher) {
    switch self {
    case .keyString(let keyString):
      hasher.combine(keyString)
    case .keyImage(let keyImage):
      hasher.combine(keyImage)
    }
  }
}

// MARK: - Cell

public final class FavorNumberKeypadCell: UICollectionViewCell {

  // MARK: - Properties

  public var key: FavorNumberKeypadCellModel? {
    didSet {
      guard let key = self.key else { fatalError() }
      switch key {
      case .keyString(let keyString):
        self.button.configuration?.image = nil
        self.button.configuration?.updateAttributedTitle(keyString, font: .favorFont(.bold, size: 24))
      case .keyImage(let keyImage):
        self.button.configuration?.title = nil
        self.button.configuration?.image = keyImage.withRenderingMode(.alwaysTemplate)
      }
    }
  }

  // MARK: - UI Components

  public let button: UIButton = {
    var config = UIButton.Configuration.filled()
    config.cornerStyle = .capsule
    config.baseForegroundColor = .favorColor(.icon)

    let button = UIButton(configuration: config)
    button.configurationUpdateHandler = { button in
      switch button.state {
      case .normal:
        button.configuration?.baseBackgroundColor = .favorColor(.white)
      case .selected:
        button.configuration?.baseBackgroundColor = .favorColor(.card)
      default:
        break
      }
    }
    button.isUserInteractionEnabled = false
    return button
  }()

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.addSubview(self.button)
    self.button.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.height.greaterThanOrEqualTo(72.0).priority(.required)
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Protocol

public protocol FavorNumberKeypadDelegate: AnyObject {
  func padSelected(_ selected: FavorNumberKeypadCellModel)
}

// MARK: - Keypad

public final class FavorNumberKeypad: UIView {
  typealias NumPadDataSource = UICollectionViewDiffableDataSource<Int, FavorNumberKeypadCellModel>

  // MARK: - Constants

  public enum Metric {
    static let defaultHorizontalSpacing: CGFloat = 32.0
    static let defaultVerticalSpacing: CGFloat = 24.0
  }

  // MARK: - Properties

  private let disposeBag = DisposeBag()
  public weak var delegate: FavorNumberKeypadDelegate?

  public var horizontalSpacing: CGFloat = Metric.defaultHorizontalSpacing
  public var verticalSpacing: CGFloat = Metric.defaultVerticalSpacing

  private var dataSource: NumPadDataSource?
  private var data: [FavorNumberKeypadCellModel]! {
    didSet { self.setupData() }
  }

  // MARK: - UI Components

  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: self.setupLayout()
    )

    collectionView.isScrollEnabled = false
    collectionView.showsVerticalScrollIndicator = false
    collectionView.showsHorizontalScrollIndicator = false
    return collectionView
  }()

  // MARK: - Initializer

  private override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
    self.setupDataSource()

    self.collectionView.rx.itemSelected
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self, onNext: { owner, indexPath in
        guard let item = owner.dataSource?.itemIdentifier(for: indexPath) else { return }
        owner.delegate?.padSelected(item)
        HapticManager.haptic(style: .light)
      })
      .disposed(by: self.disposeBag)
  }

  public convenience init(_ data: [FavorNumberKeypadCellModel]) {
    self.init(frame: .zero)
    self.data = data
    self.setupData()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  private func setupData() {
    var snapshot = NSDiffableDataSourceSnapshot<Int, FavorNumberKeypadCellModel>()
    snapshot.appendSections([0])
    snapshot.appendItems(self.data)

    DispatchQueue.main.async {
      self.dataSource?.apply(snapshot)
    }
  }
}

// MARK: - UI Setups

extension FavorNumberKeypad: BaseView {
  public func setupStyles() { }

  public func setupLayouts() {
    self.addSubview(self.collectionView)
  }

  public func setupConstraints() {
    self.collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}

// MARK: - Privates

private extension FavorNumberKeypad {
  func setupDataSource() {
    let cellRegistration = UICollectionView.CellRegistration
    <FavorNumberKeypadCell, FavorNumberKeypadCellModel> { [weak self] cell, _, item in
      guard self != nil else { return }
      cell.key = item

      cell.configurationUpdateHandler = { cell, state in
        guard let cell = cell as? FavorNumberKeypadCell else { return }
        cell.button.isSelected = state.isHighlighted
      }
    }

    self.dataSource = NumPadDataSource(
      collectionView: self.collectionView
    ) { [weak self] collectionView, indexPath, item in
      guard self != nil else { return UICollectionViewCell() }
      return collectionView.dequeueConfiguredReusableCell(
        using: cellRegistration, for: indexPath, item: item)
    }
  }

  func setupLayout() -> UICollectionViewLayout {
    let item = NSCollectionLayoutItem(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0 / 3.0),
        heightDimension: .fractionalWidth(1.0 / 3.0))
    )

    let innerGroup: NSCollectionLayoutGroup
    let innerGroupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .fractionalWidth(1.0 / 3.0))
    if #available(iOS 16.0, *) {
      innerGroup = NSCollectionLayoutGroup.horizontal(
        layoutSize: innerGroupSize, repeatingSubitem: item, count: 3)
    } else {
      innerGroup = NSCollectionLayoutGroup.horizontal(
        layoutSize: innerGroupSize, subitem: item, count: 3)
    }
    innerGroup.interItemSpacing = .fixed(0)

    let group: NSCollectionLayoutGroup
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .fractionalHeight(1.0))
    if #available(iOS 16.0, *) {
      group = NSCollectionLayoutGroup.vertical(
        layoutSize: groupSize, repeatingSubitem: innerGroup, count: 4)
    } else {
      group = NSCollectionLayoutGroup.vertical(
        layoutSize: groupSize, subitem: innerGroup, count: 4)
    }

    let section = NSCollectionLayoutSection(group: group)

    let layout = UICollectionViewCompositionalLayout(section: section)
    return layout
  }
}
