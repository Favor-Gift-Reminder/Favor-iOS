//
//  AnniversaryManagementVC.swift
//  Favor
//
//  Created by 이창준 on 2023/05/18.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import SnapKit

final class AnniversaryManagementViewController: BaseViewController, View {
  typealias AnniversaryManagementDataSource = UICollectionViewDiffableDataSource<AnniversaryManagementSection, AnniversaryManagementSectionItem>

  // MARK: - Constants

  public enum ViewType {
    case new, edit

    var title: String {
      switch self {
      case .new: return "새 기념일"
      case .edit: return "기념일 수정"
      }
    }
  }

  // MARK: - Properties

  private lazy var dataSource: AnniversaryManagementDataSource = {
    let dataSource = AnniversaryManagementDataSource(
      collectionView: self.collectionView,
      cellProvider: { [weak self] collectionView, indexPath, item in
        guard
          let self = self,
          let reactor = self.reactor
        else { return UICollectionViewCell() }
        switch item {
        case .name(let title):
          let cell = collectionView.dequeueReusableCell(for: indexPath) as FavorTextFieldCell
          cell.bind(placeholder: "내 기념일 이름 (최대 10자)")
          cell.bind(text: title)

          cell.rx.text
            .map { Reactor.Action.titleDidUpdate($0) }
            .bind(to: reactor.action)
            .disposed(by: cell.disposeBag)

          return cell
        case .category:
          let cell = collectionView.dequeueReusableCell(for: indexPath) as FavorSelectorCell
          cell.bind(unselectedTitle: "종류 선택")
          return cell
        case .date:
          let cell = collectionView.dequeueReusableCell(for: indexPath) as FavorDateSelectorCell

          cell.rx.date
            .map { Reactor.Action.dateDidUpdate($0) }
            .bind(to: reactor.action)
            .disposed(by: cell.disposeBag)

          return cell
        }
      })
    dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
      switch kind {
      case UICollectionView.elementKindSectionHeader:
        let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          for: indexPath
        ) as FavorSectionHeaderView
        let currentSnapshot = self.dataSource.snapshot()
        let section = currentSnapshot.sectionIdentifiers[indexPath.section]
        header.bind(title: section.headerTitle)
        return header
      case UICollectionView.elementKindSectionFooter:
        let footer = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          for: indexPath
        ) as FavorSectionFooterView
        return footer
      default:
        return UICollectionReusableView()
      }
    }
    return dataSource
  }()

  // MARK: - UI Components

  private let doneButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.background.backgroundColor = .clear
    config.baseForegroundColor = .favorColor(.icon)
    config.updateAttributedTitle("완료", font: .favorFont(.bold, size: 18))

    let button = UIButton(configuration: config)
    return button
  }()

  private lazy var adapter: Adapter<AnniversaryManagementSection, AnniversaryManagementSectionItem> = {
    let adapter = Adapter(collectionView: self.collectionView, dataSource: self.dataSource)
    adapter.configuration = Adapter.Configuration(
      scrollDirection: .vertical,
      sectionSpacing: 40
    )
    return adapter
  }()

  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewLayout()
    )

    // Register
    collectionView.register(cellType: FavorTextFieldCell.self)
    collectionView.register(cellType: FavorSelectorCell.self)
    collectionView.register(cellType: FavorDateSelectorCell.self)
    collectionView.register(
      supplementaryViewType: FavorSectionHeaderView.self,
      ofKind: UICollectionView.elementKindSectionHeader
    )
    collectionView.register(
      supplementaryViewType: FavorSectionFooterView.self,
      ofKind: UICollectionView.elementKindSectionFooter
    )

    collectionView.isScrollEnabled = false
    collectionView.contentInset = UIEdgeInsets(top: 32, left: .zero, bottom: 32, right: .zero)
    collectionView.contentInsetAdjustmentBehavior = .never
    return collectionView
  }()

  private let deleteButton = FavorLargeButton(with: .main2("삭제하기"))

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

  func bind(reactor: AnniversaryManagementViewReactor) {
    // Action
    self.doneButton.rx.tap
      .map { Reactor.Action.doneButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.deleteButton.rx.tap
      .map { Reactor.Action.deleteButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { $0.viewType }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, viewType in
        owner.title = viewType.title
        owner.deleteButton.isHidden = viewType == .new
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { (sections: $0.sections, items: $0.items) }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, sectionData in
        var snapshot = NSDiffableDataSourceSnapshot<AnniversaryManagementSection, AnniversaryManagementSectionItem>()
        snapshot.appendSections(sectionData.sections)
        sectionData.sections.enumerated().forEach { idx, section in
          snapshot.appendItems([sectionData.items[idx]], toSection: section)
        }
        owner.dataSource.apply(snapshot)
        owner.collectionView.collectionViewLayout.invalidateLayout()
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  // MARK: - UI Setups

  private func setupNavigationBar() {
    self.navigationItem.setRightBarButton(self.doneButton.toBarButtonItem(), animated: false)
  }

  override func setupLayouts() {
    [
      self.collectionView,
      self.deleteButton
    ].forEach {
      self.view.addSubview($0)
    }
  }

  override func setupConstraints() {
    self.collectionView.snp.makeConstraints { make in
      make.directionalVerticalEdges.equalTo(self.view.safeAreaLayoutGuide)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }

    self.deleteButton.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
      make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top).offset(-32)
    }
  }
}
