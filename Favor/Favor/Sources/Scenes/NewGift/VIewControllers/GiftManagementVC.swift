//
//  GiftManagementVC.swift
//  Favor
//
//  Created by 이창준 on 2023/05/29.
//

import UIKit

import Composer
import FavorKit
import ReactorKit
import SnapKit

final class GiftManagementViewController: BaseViewController, View {
  typealias GiftManagementDataSource = UICollectionViewDiffableDataSource<GiftManagementSection, GiftManagementSectionItem>

  // MARK: - Constants

  public enum ViewType {
    case new, edit

    public var doneButtonTitle: String {
      switch self {
      case .new: return "등록"
      case .edit: return "완료"
      }
    }

    public var cancelButtonImage: UIImage.FavorIcon {
      switch self {
      case .new: return .down
      case .edit: return .left
      }
    }
  }

  public enum GiftType {
    case received, given
  }

  // MARK: - Properties

  /// 선물 등록/수정 페이지 여부
  public var viewType: ViewType? {
    didSet { self.updateViewType() }
  }

  private var dataSource: GiftManagementDataSource?

  // MARK: - UI Components

  // NavigationBar
  private lazy var doneButton: UIButton = {
    var config = UIButton.Configuration.plain()

    let button = UIButton(configuration: config)
    button.configurationUpdateHandler = { button in
      switch button.state {
      case .disabled:
        button.configuration?.baseForegroundColor = .favorColor(.line2)
      case .normal:
        button.configuration?.baseForegroundColor = .favorColor(.icon)
      default:
        break
      }
    }
    return button
  }()
  private var cancelButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.baseForegroundColor = .favorColor(.icon)

    let button = UIButton(configuration: config)
    return button
  }()
  private let giftImageView = UIImageView(image: .favorIcon(.gift))

  // Contents
  private let collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewLayout()
    )

    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    collectionView.contentInset = UIEdgeInsets(top: 16, left: .zero, bottom: 16, right: .zero)
    return collectionView
  }()

  private lazy var composer: Composer<GiftManagementSection, GiftManagementSectionItem> = {
    let composer = Composer(collectionView: self.collectionView, dataSource: self.dataSource)
    composer.configuration = Composer.Configuration(
      scrollDirection: .vertical,
      sectionSpacing: 40,
      header: .header(
        height: .absolute(65),
        contentInsets: NSDirectionalEdgeInsets(top: .zero, leading: 20, bottom: 40, trailing: 20),
        kind: GiftManagementCollectionHeaderView.identifier
      )
    )
    return composer
  }()

  // MARK: - Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupDataSource()
    self.composer.compose()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.setupNavigationBar()
  }

  // MARK: - Binding

  func bind(reactor: GiftManagementViewReactor) {
    // Action
    self.cancelButton.rx.tap
      .map { Reactor.Action.cancelButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.collectionView.rx.itemSelected
      .map { [weak self] indexPath in
        guard
          let self = self,
          let snapshot = self.dataSource?.snapshot()
        else { return .doNothing }
        let section = snapshot.sectionIdentifiers[indexPath.section]
        let item = snapshot.itemIdentifiers(inSection: section)[indexPath.item]
        switch section {
        case .photos:
          return .photoDidSelected(item)
        default:
          return .doNothing
        }
      }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State
    let sectionData = reactor.state.map { state in
      (sections: state.sections, items: state.items)
    }
    Observable.combineLatest(self.rx.viewDidLoad, sectionData)
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, datas in
        let sectionData = datas.1
        var snapshot = NSDiffableDataSourceSnapshot<GiftManagementSection, GiftManagementSectionItem>()
        snapshot.appendSections(sectionData.sections)
        sectionData.items.enumerated().forEach { idx, items in
          snapshot.appendItems(items, toSection: sectionData.sections[idx])
        }

        DispatchQueue.main.async {
          owner.dataSource?.apply(snapshot)
        }
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  // MARK: - UI Setups

  override func setupLayouts() {
    self.view.addSubview(self.collectionView)
  }

  override func setupConstraints() {
    self.collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  private func setupNavigationBar() {
    self.navigationItem.setRightBarButton(self.doneButton.toBarButtonItem(), animated: false)
    self.navigationItem.setLeftBarButton(self.cancelButton.toBarButtonItem(), animated: false)
    self.navigationItem.titleView = self.giftImageView
  }
}

// MARK: - Privates

private extension GiftManagementViewController {
  func updateViewType() {
    guard let viewType = self.viewType else { return }
    self.doneButton.configuration?.updateAttributedTitle(
      viewType.doneButtonTitle,
      font: .favorFont(.bold, size: 18)
    )
    self.cancelButton.configuration?.image = .favorIcon(viewType.cancelButtonImage)?
      .withRenderingMode(.alwaysTemplate)
  }
}

// MARK: - DataSource

private extension GiftManagementViewController {
  func setupDataSource() {
    // Cells
    let titleCellRegistration = UICollectionView.CellRegistration
    <FavorTextFieldCell, GiftManagementSectionItem> { [weak self] cell, _, _ in
      guard let self = self else { return }
      cell.bind(placeholder: "선물 이름 (최대 20자)")
      cell.delegate = self
    }

    let categoryCellRegistration = UICollectionView.CellRegistration
    <GiftManagementCategoryViewCell, GiftManagementSectionItem> { [weak self] cell, _, _ in
      guard let self = self else { return }
      cell.delegate = self
    }

    let photoCellRegistration = UICollectionView.CellRegistration
    <GiftManagementPhotoCell, GiftManagementSectionItem> { [weak self] cell, _, itemIdentifier in
      guard
        let self = self,
        case let GiftManagementSectionItem.photo(image) = itemIdentifier
      else { return }
      cell.bind(with: image)
      cell.delegate = self
    }

    let friendCellRegistration = UICollectionView.CellRegistration
    <FavorSelectorCell, GiftManagementSectionItem> { [weak self] cell, _, _ in
      cell.delegate = self
    }

    let dateCellRegistration = UICollectionView.CellRegistration
    <FavorDateSelectorCell, GiftManagementSectionItem> { [weak self] cell, _, itemIdentifier in
      //
    }

    let memoCellRegistration = UICollectionView.CellRegistration
    <GiftManagementMemoCell, GiftManagementSectionItem> { [weak self] cell, indexPath, itemIdentifier in
      //
    }

    let pinCellRegistration = UICollectionView.CellRegistration
    <GiftManagementPinCell, GiftManagementSectionItem> { [weak self] cell, _, _ in
      guard let self = self else { return }
      cell.delegate = self
    }

    self.dataSource = GiftManagementDataSource(
      collectionView: self.collectionView,
      cellProvider: { [weak self] collectionView, indexPath, item in
        switch item {
        case .title:
          return collectionView.dequeueConfiguredReusableCell(
            using: titleCellRegistration, for: indexPath, item: item)
        case .category:
          return collectionView.dequeueConfiguredReusableCell(
            using: categoryCellRegistration, for: indexPath, item: item)
        case .photo:
          return collectionView.dequeueConfiguredReusableCell(
            using: photoCellRegistration, for: indexPath, item: item)
        case .friends:
          return collectionView.dequeueConfiguredReusableCell(
            using: friendCellRegistration, for: indexPath, item: item)
        case .date:
          return collectionView.dequeueConfiguredReusableCell(
            using: dateCellRegistration, for: indexPath, item: item)
        case .memo:
          return collectionView.dequeueConfiguredReusableCell(
            using: memoCellRegistration, for: indexPath, item: item)
        case .pin:
          return collectionView.dequeueConfiguredReusableCell(
            using: pinCellRegistration, for: indexPath, item: item)
        }
      }
    )

    // Supplementary Views
    let collectionHeaderRegistration: UICollectionView.SupplementaryRegistration<GiftManagementCollectionHeaderView> =
    UICollectionView.SupplementaryRegistration(
      elementKind: GiftManagementCollectionHeaderView.identifier
    ) { [weak self] header, _, indexPath in
      guard let self = self else { return }
      header.delegate = self
    }

    let sectionHeaderRegistration: UICollectionView.SupplementaryRegistration<FavorSectionHeaderView> =
    UICollectionView.SupplementaryRegistration(
      elementKind: UICollectionView.elementKindSectionHeader
    ) { [weak self] header, _, indexPath in
      guard
        let self = self,
        let section = self.dataSource?.snapshot().sectionIdentifiers[indexPath.section]
      else { return }
      header.bind(title: section.header)
    }

    let sectionFooterRegistration: UICollectionView.SupplementaryRegistration<FavorSectionFooterView> =
    UICollectionView.SupplementaryRegistration(
      elementKind: UICollectionView.elementKindSectionFooter
    ) { footer, _, indexPath in
      //
    }

    self.dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
      guard let self = self else { return UICollectionReusableView() }
      switch kind {
      case GiftManagementCollectionHeaderView.identifier:
        return collectionView.dequeueConfiguredReusableSupplementary(
          using: collectionHeaderRegistration, for: indexPath)
      case UICollectionView.elementKindSectionHeader:
        return collectionView.dequeueConfiguredReusableSupplementary(
          using: sectionHeaderRegistration, for: indexPath)
      case UICollectionView.elementKindSectionFooter:
        return collectionView.dequeueConfiguredReusableSupplementary(
          using: sectionFooterRegistration, for: indexPath)
      default:
        return UICollectionReusableView()
      }
    }
  }
}

// MARK: - CollectionHeaderView

extension GiftManagementViewController: GiftManagementCollectionHeaderViewDelegate {
  func giftTypeButtonDidTap(isGiven: Bool) {
    guard let reactor = self.reactor else { return }
  }
}

// MARK: - Title Cell

extension GiftManagementViewController: FavorTextFieldCellDelegate {
  func textFieldDidUpdate(from cell: FavorKit.FavorTextFieldCell, _ text: String?) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.titleDidUpdate(text))
  }
}

// MARK: - CategoryView Cell

extension GiftManagementViewController: GiftManagementCategoryViewCellDelegate {
  func categoryDidUpdate(to category: FavorCategory) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.categoryDidUpdate(category))
  }
}

// MARK: - Photo Cell

extension GiftManagementViewController: GiftManagementPhotoCellDelegate {
  func removeButtonDidTap(from cell: GiftManagementPhotoCell) {
//    guard let reactor = self.reactor else { return }
    print("Remove")
    // TODO: 이미지 다중 선택 / 삭제
  }
}

// MARK: - Friends Cell

extension GiftManagementViewController: FavorSelectorCellDelegate {
  func selectorDidTap(from cell: FavorSelectorCell) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.friendsSelectorButtonDidTap)
  }
}

// MARK: - Pin Cell

extension GiftManagementViewController: GiftManagementPinCellDelegate {
  func pinButtonDidTap(from cell: GiftManagementPinCell) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.pinButtonDidTap(cell.isPinned))
  }
}
