//
//  MyPageVC.swift
//  Favor
//
//  Created by 이창준 on 2023/01/11.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import RxDataSources
import RxGesture
import SnapKit

final class MyPageViewController: BaseViewController, View {
  typealias MyPageDataSource = RxCollectionViewSectionedReloadDataSource<MyPageSection>
  
  // MARK: - Constants

  public static let headerHeight = 330.0

  private enum Metric {
    /// 헤더와 컬렉션뷰가 겹치는 높이
    static let collectionViewCoveringHeaderHeight = 24.0
  }
  
  // MARK: - Properties

  private var headerHeight: CGFloat {
    return MyPageViewController.headerHeight
  }

  let dataSource = MyPageDataSource(configureCell: { _, collectionView, indexPath, items in
    switch items {
    case .profileSetupHelper(let reactor):
      let cell = collectionView.dequeueReusableCell(for: indexPath) as FavorSetupProfileCell
      cell.reactor = reactor
      return cell
    case .preferences(let reactor):
      let cell = collectionView.dequeueReusableCell(for: indexPath) as FavorPrefersCell
      cell.reactor = reactor
      return cell
    case .anniversaries(let reactor):
      let cell = collectionView.dequeueReusableCell(for: indexPath) as FavorAnniversaryCell
      cell.reactor = reactor
      return cell
    }
  }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
    let header = collectionView.dequeueReusableSupplementaryView(
      ofKind: kind,
      for: indexPath
    ) as MyPageSectionHeaderView
    let section = dataSource[indexPath.section]
    header.reactor = MyPageSectionHeaderViewReactor(section: section)
    return header
  })
  private lazy var adapter = Adapter(dataSource: self.dataSource)

  // MARK: - UI Components

  private let headerView = MyPageHeaderView()

  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: self.view.bounds,
      collectionViewLayout: self.adapter.build()
    )
    
    // CollectionViewCell
    collectionView.register(cellType: FavorSetupProfileCell.self)
    collectionView.register(cellType: FavorPrefersCell.self)
    collectionView.register(cellType: FavorAnniversaryCell.self)
    
    // SupplementaryView
    collectionView.register(
      supplementaryViewType: MyPageSectionHeaderView.self,
      ofKind: UICollectionView.elementKindSectionHeader
    )

    // Configure
    collectionView.backgroundColor = .clear
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    collectionView.contentInset = UIEdgeInsets(
      top: self.headerHeight - Metric.collectionViewCoveringHeaderHeight,
      left: .zero,
      bottom: .zero,
      right: .zero
    )
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
    self.collectionView.rx.contentOffset
      .skip(1)
      .bind(with: self, onNext: { owner, offset in
//        owner.updateHeaderConstraintAndOpacity(offset: offset)
      })
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { $0.sections }
      .bind(to: self.collectionView.rx.items(dataSource: self.dataSource))
      .disposed(by: self.disposeBag)
  }
  
  func bind(reactor: MyPageViewReactor) {
    // Action
    
    // State

  }
  
  // MARK: - Functions

  // MARK: - UI Setups
  
  override func setupStyles() {
    super.setupStyles()

    self.view.backgroundColor = .favorColor(.background)
  }
  
  override func setupLayouts() {
    [
      self.headerView,
      self.collectionView
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.headerView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(self.headerHeight)
    }

    self.collectionView.snp.makeConstraints { make in
      make.directionalVerticalEdges.equalTo(self.view.safeAreaLayoutGuide)
      make.directionalHorizontalEdges.equalToSuperview()
    }
  }
}

// MARK: - Privates

private extension MyPageViewController {
  func setupNavigationBar() {
    guard let navigationController = self.navigationController else { return }

    navigationController.setNavigationBarHidden(false, animated: false)

//    let appearance = UINavigationBarAppearance()
//    appearance.configureWithTransparentBackground()
//    navigationController.navigationBar.standardAppearance = appearance
//    navigationController.navigationBar.scrollEdgeAppearance = appearance
  }
}
