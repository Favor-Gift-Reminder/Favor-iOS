//
//  EditMyPageVC.swift
//  Favor
//
//  Created by 이창준 on 2023/02/22.
//

import UIKit

import Composer
import FavorKit
import ReactorKit
import Reusable
import SnapKit

final class EditMyPageViewController: BaseViewController, View {
  typealias EditMyPageDataSource = UICollectionViewDiffableDataSource<EditMyPageSection, EditMyPageSectionItem>

  // MARK: - Constants

  private enum Metric {
    static let profileImageViewSize = 120.0
  }

  // MARK: - Properties
  
  private var dataSource: EditMyPageDataSource?
  
//  private lazy var dataSource: EditMyPageDataSource = {
//    let dataSource = EditMyPageDataSource(
//      collectionView: self.collectionView,
//      cellProvider: { collectionView, indexPath, item in
//        switch item {
//        case let .textField(text, placeholder):
//          let cell = collectionView.dequeueReusableCell(for: indexPath) as FavorTextFieldCell
//          cell.bind(placeholder: placeholder)
//          cell.bind(text: text)
//          return cell
//        case let .favor(isSelected, favor):
//          let cell = collectionView.dequeueReusableCell(for: indexPath) as EditMyPageFavorCell
//          cell.isButtonSelected = isSelected
//          cell.favor = favor
//          return cell
//        }
//      }
//    )
//    dataSource.supplementaryViewProvider = { _, kind, indexPath in
//      switch kind {
//      case EditMyPageCollectionHeaderView.reuseIdentifier:
//        let header = self.collectionView.dequeueReusableSupplementaryView(
//          ofKind: kind,
//          for: indexPath
//        ) as EditMyPageCollectionHeaderView
//        return header
//      case UICollectionView.elementKindSectionHeader:
//        let header = self.collectionView.dequeueReusableSupplementaryView(
//          ofKind: kind,
//          for: indexPath
//        ) as FavorSectionHeaderView
//        guard let headerTitle = dataSource.sectionIdentifier(for: indexPath.section)?.header else {
//          return UICollectionReusableView()
//        }
//        header.bind(title: headerTitle)
//        return header
//      case UICollectionView.elementKindSectionFooter:
//        let footer = self.collectionView.dequeueReusableSupplementaryView(
//          ofKind: kind,
//          for: indexPath
//        ) as FavorSectionFooterView
//        if let description = dataSource.sectionIdentifier(for: indexPath.section)?.footer {
//          footer.footerDescription = description
//        }
//        return footer
//      default:
//        return UICollectionReusableView()
//      }
//    }
//    return dataSource
//  }()
  
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
        kind: EditMyPageCollectionHeaderView.identifier
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

  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewLayout()
    )
    
    // Register
//    collectionView.register(cellType: FavorTextFieldCell.self)
//    collectionView.register(cellType: EditMyPageFavorCell.self)
//    collectionView.register(
//      supplementaryViewType: EditMyPageCollectionHeaderView.self,
//      ofKind: EditMyPageCollectionHeaderView.reuseIdentifier
//    )
//    collectionView.register(
//      supplementaryViewType: FavorSectionHeaderView.self,
//      ofKind: UICollectionView.elementKindSectionHeader
//    )
//    collectionView.register(
//      supplementaryViewType: FavorSectionFooterView.self,
//      ofKind: UICollectionView.elementKindSectionFooter
//    )

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

  override func bind() {
    guard let reactor = self.reactor else { return }
    
    // Action
    self.collectionView.rx.itemSelected
      .map { Reactor.Action.favorDidSelected($0.item) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { (sections: $0.sections, items: $0.items) }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self, onNext: { owner, sectionData in
        var snapshot: NSDiffableDataSourceSnapshot<EditMyPageSection, EditMyPageSectionItem> = .init()
        snapshot.appendSections(sectionData.sections)
        sectionData.items.enumerated().forEach { idx, item in
          snapshot.appendItems(item, toSection: sectionData.sections[idx])
        }
        
        DispatchQueue.main.async {
          owner.dataSource?.apply(snapshot, animatingDifferences: false)
        }
      })
      .disposed(by: self.disposeBag)
  }

  public func bind(reactor: EditMyPageViewReactor) {
    // Action
    self.rx.viewDidLoad
      .map { Reactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.cancelButton.rx.tap
      .map { Reactor.Action.cancelButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.doneButton.rx.tap
      .map { _ -> Reactor.Action in
        guard
          let nameCell = self.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? FavorTextFieldCell,
          let idCell = self.collectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? FavorTextFieldCell
        else { return Reactor.Action.doNothing }
        print(nameCell, idCell)
        return Reactor.Action.doneButtonDidTap(with: (nameCell.text, idCell.text))
      }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State

  }

  // MARK: - Functions

  // MARK: - UI Setups

  override func setupLayouts() {
    self.view.addSubview(self.collectionView)
  }

  override func setupConstraints() {
    self.collectionView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.bottom.equalTo(self.view.safeAreaLayoutGuide)
      make.directionalHorizontalEdges.equalToSuperview()
    }
  }
}

// MARK: - Privates

private extension EditMyPageViewController {
  func setupNavigationBar() {
    self.navigationItem.leftBarButtonItem = self.cancelButton.toBarButtonItem()
    self.navigationItem.rightBarButtonItem = self.doneButton.toBarButtonItem()

    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    self.navigationController?.navigationBar.standardAppearance = appearance
    self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
  }
  
  func setupDataSource() {
    let textFieldCellRegistration = UICollectionView.CellRegistration
    <FavorTextFieldCell, EditMyPageSectionItem> { [weak self] cell, _, item in
      guard self != nil else { return }
      guard case let EditMyPageSectionItem.textField(text, placeholder) = item else { return }
      cell.bind(text: text)
      cell.bind(placeholder: placeholder)
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
    <EditMyPageCollectionHeaderView>(
      elementKind: EditMyPageCollectionHeaderView.identifier,
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
      case EditMyPageCollectionHeaderView.identifier:
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

extension EditMyPageViewController: EditMyPageCollectionHeaderViewDelegate {
  func profileBackgroundDidTap() {
    print("Background")
  }
  
  func profilePhotoDidTap() {
    print("Photo")
  }
}
