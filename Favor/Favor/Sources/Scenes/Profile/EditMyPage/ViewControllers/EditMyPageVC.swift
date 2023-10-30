//
//  EditMyPageVC.swift
//  Favor
//
//  Created by 이창준 on 2023/02/22.
//

import OSLog
import PhotosUI
import UIKit

import Composer
import FavorKit
import ReactorKit
import RxGesture
import SnapKit

final class EditMyPageViewController: BaseViewController, View {
  typealias EditMyPageDataSource = UICollectionViewDiffableDataSource<EditMyPageSection, EditMyPageSectionItem>

  // MARK: - Constants

  private enum Metric {
    static let profileImageViewSize = 120.0
  }

  // MARK: - Properties
  
//  private lazy var picker = PHPickerManager.create(for: self)
  
  private var dataSource: EditMyPageDataSource?
  
  private lazy var composer: Composer<EditMyPageSection, EditMyPageSectionItem> = {
    let composer = Composer(collectionView: self.collectionView, dataSource: self.dataSource)
    composer.configuration = Composer.Configuration(
      scrollDirection: .vertical,
      sectionSpacing: 40.0,
      header: UICollectionViewComposableLayout.BoundaryItem.header(
        height: .absolute(400),
        contentInsets: NSDirectionalEdgeInsets(
          top: .zero,
          leading: .zero,
          bottom: 40,
          trailing: .zero
        ),
        kind: EditMyPageProfileHeader.identifier
      )
    )
    return composer
  }()

  // MARK: - UI Components
  
  private let cancelButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.updateAttributedTitle("취소", font: .favorFont(.bold, size: 18))
    config.background.backgroundColor = .clear
    config.baseForegroundColor = .favorColor(.white)

    let button = UIButton(configuration: config)
    return button
  }()

  private let doneButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.updateAttributedTitle("완료", font: .favorFont(.bold, size: 18))
    config.background.backgroundColor = .clear
    config.baseForegroundColor = .favorColor(.white)

    let button = UIButton(configuration: config)
    return button
  }()
  
  private let titleView: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 18.0)
    label.textAlignment = .center
    label.textColor = .favorColor(.white)
    label.text = "프로필 수정"
    return label
  }()
  
  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewLayout()
    )

    collectionView.showsVerticalScrollIndicator = false
    collectionView.contentInsetAdjustmentBehavior = .never
    collectionView.contentInset = UIEdgeInsets(top: .zero, left: .zero, bottom: 64, right: .zero)
    return collectionView
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

  public func bind(reactor: EditMyPageViewReactor) {
    // Action
    self.rx.viewDidLoad
      .map { _ in Reactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.cancelButton.rx.tap
      .map { Reactor.Action.cancelButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.doneButton.rx.tap
      .map { Reactor.Action.doneButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.collectionView.rx.itemSelected
      .map { Reactor.Action.favorDidSelected($0.item) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.collectionView.rx.tapGesture { gesture, _ in
      gesture.cancelsTouchesInView = false
    }
      .when(.recognized)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.view.endEditing(false)
      }
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { $0.items }
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self, onNext: { owner, items in
        var snapshot: NSDiffableDataSourceSnapshot<EditMyPageSection, EditMyPageSectionItem> = .init()
        let sections: [EditMyPageSection] = [.name, .id, .favor]
        snapshot.appendSections(sections)
        items.enumerated().forEach { idx, item in
          snapshot.appendItems(item, toSection: sections[idx])
        }
        
        DispatchQueue.main.async {
          owner.dataSource?.apply(snapshot, animatingDifferences: false)
        }
      })
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.profileBackgroundImage }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self, onNext: { owner, image in
        guard
          let headerIndexPath = owner.collectionView.indexPathsForVisibleSupplementaryElements(
            ofKind: EditMyPageProfileHeader.identifier).first,
          let header = owner.collectionView.supplementaryView(
            forElementKind: EditMyPageProfileHeader.identifier,
            at: headerIndexPath) as? EditMyPageProfileHeader
        else { return }
        header.updateBackgroundImage(image)
      })
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.profilePhotoImage }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self, onNext: { owner, image in
        guard
          let headerIndexPath = owner.collectionView.indexPathsForVisibleSupplementaryElements(
            ofKind: EditMyPageProfileHeader.identifier).first,
          let header = owner.collectionView.supplementaryView(
            forElementKind: EditMyPageProfileHeader.identifier,
            at: headerIndexPath) as? EditMyPageProfileHeader
        else { return }
        header.updateProfilePhotoImage(image)
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
      make.top.equalToSuperview()
      make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top)
      make.directionalHorizontalEdges.equalToSuperview()
    }
  }
}

// MARK: - Privates

private extension EditMyPageViewController {
  func setupNavigationBar() {
    self.navigationItem.rightBarButtonItem = self.doneButton.toBarButtonItem()
    self.navigationItem.titleView = self.titleView
    self.navigationController?.navigationBar.tintColor = .favorColor(.white)
  }
  
  func setupDataSource() {
    let textFieldCellRegistration = UICollectionView.CellRegistration
    <FavorTextFieldCell, EditMyPageSectionItem> { [weak self] cell, _, item in
      guard self != nil else { return }
      guard case let EditMyPageSectionItem.textField(text, placeholder) = item else { return }
      cell.bind(text: text)
      cell.bind(placeholder: placeholder)
      cell.delegate = self
    }
    
    let favorCellRegistration = UICollectionView.CellRegistration
    <EditMyPageFavorCell, EditMyPageSectionItem> { [weak self] cell, _, item in
      guard self != nil else { return }
      guard case let EditMyPageSectionItem.favor(isSelected, favor) = item else { return }
      cell.isButtonSelected = isSelected
      cell.favor = favor
    }
    
    self.dataSource = EditMyPageDataSource(
      collectionView: self.collectionView,
      cellProvider: { [weak self] collectionView, indexPath, item in
        guard self != nil else { return UICollectionViewCell() }
        switch item {
        case .textField:
          return collectionView.dequeueConfiguredReusableCell(
            using: textFieldCellRegistration, for: indexPath, item: item)
        case .favor:
          return collectionView.dequeueConfiguredReusableCell(
            using: favorCellRegistration, for: indexPath, item: item)
        }
      }
    )
    
    let collectionHeaderRegistration = UICollectionView.SupplementaryRegistration
    <EditMyPageProfileHeader>(
      elementKind: EditMyPageProfileHeader.identifier,
      handler: { [weak self] header, _, _ in
        guard let self = self else { return }
        header.delegate = self
      }
    )
    
    let headerRegistration = UICollectionView.SupplementaryRegistration
    <FavorSectionHeaderCell>(
      elementKind: UICollectionView.elementKindSectionHeader,
      handler: { [weak self] header, _, indexPath in
        guard
          let self = self,
          let section = self.dataSource?.sectionIdentifier(for: indexPath.section)
        else { return }
        header.bind(title: section.header)
      }
    )
    
    let footerRegistration = UICollectionView.SupplementaryRegistration
    <FavorSectionFooterView>(
      elementKind: UICollectionView.elementKindSectionFooter,
      handler: { [weak self] footer, _, indexPath in
        guard
          let self = self,
          let section = self.dataSource?.sectionIdentifier(for: indexPath.section)
        else { return }
        footer.footerDescription = section.footer
      }
    )
    
    self.dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
      guard self != nil else { return UICollectionReusableView() }
      switch kind {
      case EditMyPageProfileHeader.identifier:
        return collectionView.dequeueConfiguredReusableSupplementary(
          using: collectionHeaderRegistration, for: indexPath)
      case UICollectionView.elementKindSectionHeader:
        return collectionView.dequeueConfiguredReusableSupplementary(
          using: headerRegistration, for: indexPath)
      case UICollectionView.elementKindSectionFooter:
        return collectionView.dequeueConfiguredReusableSupplementary(
          using: footerRegistration, for: indexPath)
      default:
        return UICollectionReusableView()
      }
    }
  }
}

// MARK: - EditMyPageCollectionHeader

extension EditMyPageViewController: EditMyPageProfileHeaderDelegate {
  func profileHeader(didTap imageType: EditMyPageProfileHeader.ImageType) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.profileHeaderDidTap(imageType))
//    self.picker.present(selectionLimit: 1)
  }
}

// MARK: - TextField Cell

extension EditMyPageViewController: FavorTextFieldCellDelegate {
  func textField(textFieldCell cell: FavorTextFieldCell, didUpdate text: String?) {
    if
      let reactor = self.reactor,
      let cell = self.collectionView.visibleCells.first(where: { $0 === cell }),
      let textFieldCell = cell as? FavorTextFieldCell,
      let placeholder = textFieldCell.textField.placeholder {
      if placeholder == "이름" {
        reactor.action.onNext(.nameTextFieldDidUpdate(text))
      } else if placeholder == "ID" {
        reactor.action.onNext(.searchIDTextFieldDidUpdate(text))
      }
    }
  }
}

// MARK: - PHPickerManager

extension EditMyPageViewController: PHPickerManagerDelegate {
  func pickerManager(didFinishPicking image: UIImage?) {
    
  }
}
