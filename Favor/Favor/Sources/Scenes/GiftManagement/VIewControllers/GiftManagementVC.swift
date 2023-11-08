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

    var header: String {
      switch self {
      case .received: return "받은 사람"
      case .given: return "준 사람"
      }
    }
  }

  // MARK: - Properties

  private var dataSource: GiftManagementDataSource?

  private var giftType: GiftType?

  // MARK: - UI Components

  // NavigationBar
  private let doneButton: FavorButton = {
    let button = FavorButton("등록")
    button.contentInset = .zero
    button.font = .favorFont(.bold, size: 18.0)
    button.baseBackgroundColor = .white
    button.isEnabled = false
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      guard let button = button as? FavorButton else { return }
      switch button.state {
      case .disabled:
        button.baseForegroundColor = .favorColor(.line2)
        button.configuration?.background.backgroundColor = .white
      default:
        button.baseForegroundColor = .favorColor(.main)
      }
    }
    button.configurationUpdateHandler = handler
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
    collectionView.contentInset = UIEdgeInsets(top: 16, left: .zero, bottom: 74, right: .zero)
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
    self.setupNavigationBar()
  }
  
  // MARK: - Binding
  
  func bind(reactor: GiftManagementViewReactor) {
    // Action
    
    self.rx.viewDidLoad
      .map { Reactor.Action.viewDidLoad }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // 취소 버튼 터치
    self.cancelButton.rx.tap
      .map { Reactor.Action.cancelButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // 완료/등록 버튼 터치
    self.doneButton.rx.tap
      .throttle(.seconds(1), latest: false, scheduler: MainScheduler.asyncInstance)
      .map { Reactor.Action.doneButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // 화면 빈공간 터치
    self.collectionView.rx.tapGesture { delegate, _ in
      delegate.cancelsTouchesInView = false
    }
      .skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.view.endEditing(true)
      }
      .disposed(by: self.disposeBag)
    
    // 셀 선택
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
    
    reactor.state.map { $0.viewType }
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, viewType in
        owner.doneButton.configuration?.updateAttributedTitle(
          viewType.doneButtonTitle,
          font: .favorFont(.bold, size: 18)
        )
        owner.cancelButton.configuration?.image = .favorIcon(viewType.cancelButtonImage)?
          .withRenderingMode(.alwaysTemplate)
      })
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.giftType }
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, giftType in
        owner.giftType = giftType
      })
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.isEnabledDoneButton }
      .bind(to: self.doneButton.rx.isEnabled)
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions
  
  func friendsDidAdd(_ friends: [Friend]) {
    self.reactor?.action.onNext(.friendsDidAdd(friends))
  }
  
  // MARK: - UI Setups

  override func setupLayouts() {
    self.view.addSubview(self.collectionView)
  }
  
  override func setupConstraints() {
    self.collectionView.snp.makeConstraints { make in
      make.top.directionalHorizontalEdges.equalTo(self.view.safeAreaLayoutGuide)
      make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top).inset(20.0)
    }
  }
  
  private func setupNavigationBar() {
    self.navigationItem.setLeftBarButton(self.cancelButton.toBarButtonItem(), animated: false)
    self.navigationItem.rightBarButtonItem = self.doneButton.toBarButtonItem()
    self.navigationItem.titleView = self.giftImageView
  }
}

// MARK: - DataSource

private extension GiftManagementViewController {
  func setupDataSource() {
    // Cells
    let titleCellRegistration = UICollectionView.CellRegistration
    <FavorTextFieldCell, GiftManagementSectionItem> { [weak self] cell, _, _ in
      guard let self = self, let reactor = self.reactor else { return }
      cell.delegate = self
      cell.bind(placeholder: "선물 이름 (최대 20자)")
      cell.bind(text: reactor.currentState.gift.name)
    }
    
    let categoryCellRegistration = UICollectionView.CellRegistration
    <GiftManagementCategoryViewCell, GiftManagementSectionItem> { [weak self] cell, _, _ in
      guard let self = self, let reactor = self.reactor else { return }
      cell.delegate = self
      cell.bind(with: reactor.currentState.gift.category)
    }
    
    let photoCellRegistration = UICollectionView.CellRegistration
    <GiftManagementPhotoCell, GiftManagementSectionItem> 
    { [weak self] cell, _, itemIdentifier in
      guard let self = self,
            let reactor = self.reactor,
            case let GiftManagementSectionItem.photo(imageModel) = itemIdentifier
      else { return }
      cell.delegate = self
      cell.bind(with: imageModel, gift: reactor.currentState.gift)
    }

    let friendCellRegistration = UICollectionView.CellRegistration
    <FavorSelectorCell, GiftManagementSectionItem> { [weak self] cell, _, itemIdentifier in
      guard let self = self, case let GiftManagementSectionItem.friends(friends) = itemIdentifier else {
        return }
      cell.delegate = self
      if friends.isEmpty {
        cell.bind(unselectedTitle: "선택")
      } else {
        let friendName = friends.first?.friendName ?? ""
        if friends.count == 1 {
          cell.bind(selectedTitle: "\(friendName)")
        } else {
          cell.bind(selectedTitle: "\(friendName) 외 \(friends.count - 1)")
        }
      }
    }
    
    let dateCellRegistration = UICollectionView.CellRegistration
    <FavorDateSelectorCell, GiftManagementSectionItem> { [weak self] cell, _, _ in
      guard let self = self, let reactor = self.reactor else { return }
      cell.delegate = self
      cell.bind(date: reactor.currentState.gift.date)
    }
    
    let memoCellRegistration = UICollectionView.CellRegistration
    <GiftManagementMemoCell, GiftManagementSectionItem> { [weak self] cell, _, _ in
      guard let self = self, let reactor = self.reactor else { return }
      cell.delegate = self
      cell.bind(with: reactor.currentState.gift.memo)
    }

    let pinCellRegistration = UICollectionView.CellRegistration
    <GiftManagementPinCell, GiftManagementSectionItem> { [weak self] cell, _, _ in
      guard let self = self, let reactor = self.reactor else { return }
      cell.delegate = self
      cell.bind(with: reactor.currentState.gift.isPinned)
    }
    
    self.dataSource = GiftManagementDataSource(
      collectionView: self.collectionView,
      cellProvider: { [weak self] collectionView, indexPath, item in
        guard self != nil else { return UICollectionViewCell() }
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
    ) { [weak self] header, _, _ in
      guard let self = self, let reactor = self.reactor else { return }
      header.bind(with: reactor.currentState.gift.isGiven)
      header.delegate = self
    }
    
    let sectionHeaderRegistration: UICollectionView.SupplementaryRegistration<FavorSectionHeaderCell> =
    UICollectionView.SupplementaryRegistration(
      elementKind: UICollectionView.elementKindSectionHeader
    ) { [weak self] header, _, indexPath in
      guard
        let self = self,
        let section = self.dataSource?.snapshot().sectionIdentifiers[indexPath.section]
      else { return }

      header.configurationUpdateHandler = { header, _ in
        guard
          let header = header as? FavorSectionHeaderCell,
          let giftType = self.giftType
        else { return }
        if case GiftManagementSection.friends = section {
          header.bind(title: giftType.header)
        } else {
          header.bind(title: section.header)
        }
      }
    }

    let sectionFooterRegistration: UICollectionView.SupplementaryRegistration<FavorSectionFooterView> =
    UICollectionView.SupplementaryRegistration(
      elementKind: UICollectionView.elementKindSectionFooter
    ) { _, _, _ in
      //
    }

    self.dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
      guard self != nil else { return UICollectionReusableView() }
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
    reactor.action.onNext(.giftTypeButtonDidTap(isGiven: isGiven))
  }
}

// MARK: - Title Cell

extension GiftManagementViewController: FavorTextFieldCellDelegate {
  func textField(textFieldCell cell: FavorKit.FavorTextFieldCell, didUpdate text: String?) {
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
  func removeButtonDidTap(from imageModel: GiftManagementPhotoModel?) {
    guard let reactor = self.reactor,
          let imageModel = imageModel else { return }
    reactor.action.onNext(.removeButtonDidTap(imageModel))
  }
}

// MARK: - Friends Cell

extension GiftManagementViewController: FavorSelectorCellDelegate {
  func selectorDidTap(from cell: FavorSelectorCell) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.friendsSelectorButtonDidTap)
  }
}

// MARK: - Date Cell

extension GiftManagementViewController: FavorDateSelectorCellDelegate {
  func dateSelectorDidUpdate(from cell: FavorKit.FavorDateSelectorCell, _ date: Date?) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.dateDidUpdate(date))
  }
}

// MARK: - Memo Cell

extension GiftManagementViewController: GiftManagementMemoCellDelegate {
  func memoDidUpdate(_ memo: String?) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.memoDidUpdate(memo))
  }
}

// MARK: - Pin Cell

extension GiftManagementViewController: GiftManagementPinCellDelegate {
  func pinButtonDidTap(from cell: GiftManagementPinCell, isPinned: Bool) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.pinButtonDidTap(isPinned))
  }
}

// MARK: - PHPickerViewController

extension GiftManagementViewController: PHPickerManagerDelegate {
  func pickerManager(didFinishPicking image: UIImage?) {
    self.reactor?.action.onNext(.photoDidAdd(image))
  }
}
