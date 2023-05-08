//
//  EditMyPageVC.swift
//  Favor
//
//  Created by 이창준 on 2023/02/22.
//

import UIKit

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

  private lazy var dataSource: EditMyPageDataSource = {
    let dataSource = EditMyPageDataSource(
      collectionView: self.collectionView,
      cellProvider: { collectionView, indexPath, item in
        switch item {
        case let .textField(text, placeholder):
          let cell = collectionView.dequeueReusableCell(for: indexPath) as FavorTextFieldCell
          cell.bind(placeholder: placeholder)
          cell.bind(text: text)
          return cell
        case let .favor(isSelected, favor):
          let cell = collectionView.dequeueReusableCell(for: indexPath) as EditMyPagePreferenceCell
          cell.isButtonSelected = isSelected
          cell.favor = favor
          return cell
        }
      }
    )
    dataSource.supplementaryViewProvider = { view, kind, indexPath in
      switch kind {
      case EditMyPageCollectionHeaderView.reuseIdentifier:
        let header = self.collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          for: indexPath
        ) as EditMyPageCollectionHeaderView
        return header
      case UICollectionView.elementKindSectionHeader:
        let header = self.collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          for: indexPath
        ) as FavorSectionHeaderView
//        let headerTitle = dataSource[index.section].header
//        header.updateTitle(headerTitle)
        return header
      case UICollectionView.elementKindSectionFooter:
        let footer = self.collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          for: indexPath
        ) as FavorSectionFooterView
//        footer.footerDescription = dataSource[index.section].footer
        return footer
      default:
        return UICollectionReusableView()
      }
    }
    return dataSource
  }()

//  private lazy var dataSource: EditMyPageDataSource = EditMyPageDataSource(
//    configureCell: { [weak self] _, collectionView, indexPath, item in
//      switch item {
//      case let .name(name, placeholder):
//        let cell = collectionView.dequeueReusableCell(for: indexPath) as FavorTextFieldCell
//        cell.bind(placeholder: placeholder)
//        cell.bind(text: name)
//        return cell
//      case let .id(name, placeholder):
//        let cell = collectionView.dequeueReusableCell(for: indexPath) as FavorTextFieldCell
//        cell.bind(placeholder: placeholder)
//        cell.bind(text: name)
//        return cell
//      case let .favor(isSelected, favor):
//        let cell = collectionView.dequeueReusableCell(for: indexPath) as EditMyPagePreferenceCell
//        cell.isButtonSelected = isSelected
//        cell.favor = favor
//        return cell
//      }
//    }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
//      switch kind {
//      case EditMyPageCollectionHeaderView.reuseIdentifier:
//        let header = collectionView.dequeueReusableSupplementaryView(
//          ofKind: kind,
//          for: indexPath
//        ) as EditMyPageCollectionHeaderView
//        return header
//      case UICollectionView.elementKindSectionHeader:
//        let header = collectionView.dequeueReusableSupplementaryView(
//          ofKind: kind,
//          for: indexPath
//        ) as FavorSectionHeaderView
//        let headerTitle = dataSource[indexPath.section].header
//        header.updateTitle(headerTitle)
//        return header
//      case UICollectionView.elementKindSectionFooter:
//        let footer = collectionView.dequeueReusableSupplementaryView(
//          ofKind: kind,
//          for: indexPath
//        ) as FavorSectionFooterView
//        footer.footerDescription = dataSource[indexPath.section].footer
//        return footer
//      default:
//        return UICollectionReusableView()
//      }
//    }
//  )
  private lazy var adapter: Adapter<EditMyPageSection, EditMyPageSectionItem> = {
    let adapter = Adapter(collectionView: self.collectionView, dataSource: self.dataSource)
    adapter.configuration = Adapter.Configuration(
      scrollDirection: .vertical,
      sectionSpacing: 40.0,
      header: FavorCompositionalLayout.BoundaryItem.header(
        height: .absolute(400),
        contentInsets: NSDirectionalEdgeInsets(
          top: .zero,
          leading: .zero,
          bottom: 40,
          trailing: .zero
        ),
        kind: EditMyPageCollectionHeaderView.reuseIdentifier
      )
    )
    return adapter
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
    collectionView.register(cellType: FavorTextFieldCell.self)
    collectionView.register(cellType: EditMyPagePreferenceCell.self)
    collectionView.register(
      supplementaryViewType: EditMyPageCollectionHeaderView.self,
      ofKind: EditMyPageCollectionHeaderView.reuseIdentifier
    )
    collectionView.register(
      supplementaryViewType: FavorSectionHeaderView.self,
      ofKind: UICollectionView.elementKindSectionHeader
    )
    collectionView.register(
      supplementaryViewType: FavorSectionFooterView.self,
      ofKind: UICollectionView.elementKindSectionFooter
    )

    collectionView.showsVerticalScrollIndicator = false
    collectionView.contentInsetAdjustmentBehavior = .never
    return collectionView
  }()

  // MARK: - Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.adapter.adapt()
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
    reactor.state.map { $0.sections }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, sections in
        var snapshot: NSDiffableDataSourceSnapshot<EditMyPageSection, EditMyPageSectionItem> = .init()
        owner.dataSource.apply(snapshot, animatingDifferences: false)
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
      make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(60)
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
}
