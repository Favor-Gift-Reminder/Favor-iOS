//
//  EditMyPageVC.swift
//  Favor
//
//  Created by 이창준 on 2023/02/22.
//

import UIKit
import OSLog

import FavorKit
import ReactorKit
import Reusable
import RxDataSources
import SnapKit

final class EditMyPageViewController: BaseViewController, View {
  typealias EditMyPageDataSource = RxCollectionViewSectionedReloadDataSource<EditMyPageSection>

  // MARK: - Constants

  private enum Metric {
    static let profileImageViewSize = 120.0
  }

  // MARK: - Properties

  private lazy var dataSource: EditMyPageDataSource = EditMyPageDataSource(
    configureCell: { [weak self] dataSource, collectionView, indexPath, item in
      switch item {
      case .name(let placeholder):
        let cell = collectionView.dequeueReusableCell(for: indexPath) as FavorTextFieldCell
        cell.bind(placeholder: placeholder)

        if let reactor = self?.reactor {
          reactor.state.map { $0.name }
            .distinctUntilChanged()
            .bind(with: cell, onNext: { owner, name in
              owner.bind(text: name)
            })
            .disposed(by: cell.disposeBag)

//          cell.rx.text
//            .distinctUntilChanged()
//            .debug("Name text")
//            .map { Reactor.Action.nameDidUpdate($0) }
//            .bind(to: reactor.action)
//            .disposed(by: cell.disposeBag)
        }
        return cell
      case .id(let placeholder):
        let cell = collectionView.dequeueReusableCell(for: indexPath) as FavorTextFieldCell
        cell.bind(placeholder: placeholder)

        if let reactor = self?.reactor {
          reactor.state.map { $0.id }
            .distinctUntilChanged()
            .bind(with: cell, onNext: { owner, id in
              owner.bind(text: id)
            })
            .disposed(by: cell.disposeBag)

//          cell.rx.text
//            .distinctUntilChanged()
//            .debug("ID text")
//            .map { Reactor.Action.idDidUpdate($0) }
//            .bind(to: reactor.action)
//            .disposed(by: cell.disposeBag)
        }
        return cell
      case let .favor(isSelected, favor):
        let cell = collectionView.dequeueReusableCell(for: indexPath) as EditMyPagePreferenceCell
        cell.isButtonSelected = isSelected
        cell.favor = favor
        return cell
      }
    }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
      switch kind {
      case EditMyPageCollectionHeaderView.reuseIdentifier:
        let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          for: indexPath
        ) as EditMyPageCollectionHeaderView
        return header
      case UICollectionView.elementKindSectionHeader:
        let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          for: indexPath
        ) as FavorSectionHeaderView
        let headerTitle = dataSource[indexPath.section].header
        header.updateTitle(headerTitle)
        return header
      case UICollectionView.elementKindSectionFooter:
        let footer = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          for: indexPath
        ) as FavorSectionFooterView
        footer.footerDescription = dataSource[indexPath.section].footer
        return footer
      default:
        return UICollectionReusableView()
      }
    }
  )
  private lazy var adapter = Adapter(dataSource: self.dataSource)

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
      collectionViewLayout: self.adapter.build(
        scrollDirection: .vertical,
        sectionSpacing: 40,
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
      .bind(to: self.collectionView.rx.items(dataSource: self.dataSource))
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
      .map { Reactor.Action.doneButtonDidTap }
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
