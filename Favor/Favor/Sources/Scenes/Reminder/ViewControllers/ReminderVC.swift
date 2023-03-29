//
//  ReminderVC.swift
//  Favor
//
//  Created by 이창준 on 2023/01/11.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import RxCocoa
import SnapKit

final class ReminderViewController: BaseViewController, View {

  // MARK: - Constants

  // MARK: - Properties

  // MARK: - UI Components

  private lazy var selectDateButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.imagePlacement = .trailing
    config.imagePadding = 10
    config.image = .favorIcon(.down)

    let button = UIButton(configuration: config)
    return button
  }()

  private lazy var newReminderButton = FavorBarButtonItem(.addNoti)

  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: self.view.bounds,
      collectionViewLayout: self.setupCollectionViewLayout()
    )

    // register

    collectionView.backgroundColor = .clear
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    return collectionView
  }()

  // MARK: - Life Cycle

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.setupNavigationBar()
  }

  // MARK: - Binding

  func bind(reactor: ReminderViewReactor) {
    // Action
    self.selectDateButton.rx.tap
      .map { Reactor.Action.selectDateButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { $0.selectedDate }
      .asDriver(onErrorRecover: { _ in return .never()})
      .drive(with: self, onNext: { owner, date in
        owner.updateSelectedDate(to: date)
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  private func updateSelectedDate(to date: DateComponents) {
    guard let dateString = date.toYearMonthString() else { return }

    var container = AttributeContainer()
    container.font = .favorFont(.bold, size: 22)

    self.selectDateButton.configurationUpdateHandler = { button in
      button.configuration?.attributedTitle = AttributedString(dateString, attributes: container)
    }
  }

  // MARK: - UI Setups

  override func setupLayouts() {
    self.view.addSubview(self.collectionView)
  }

  override func setupConstraints() {
    self.collectionView.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
      make.bottom.equalToSuperview()
    }
  }
}

// MARK: - Privates

private extension ReminderViewController {
  func setupNavigationBar() {
    let leftButton = UIBarButtonItem(customView: self.selectDateButton)
    self.navigationItem.setLeftBarButton(leftButton, animated: false)
    self.navigationItem.setRightBarButton(self.newReminderButton, animated: false)
  }

  func setupCollectionViewLayout() -> UICollectionViewCompositionalLayout {
    return UICollectionViewCompositionalLayout(sectionProvider: { [weak self] sectionIndex, _ in
      return self?.createCollectionViewLayout()
    })
  }

  func createCollectionViewLayout(
  ) -> NSCollectionLayoutSection {
    // Item
    let item = NSCollectionLayoutItem(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .fractionalWidth(1.0)
      )
    )

    // Group
    let group = UICollectionViewCompositionalLayout.group(
      direction: .vertical,
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .fractionalWidth(1.0)),
      subItem: item,
      count: 1
    )

    // Section
    let section = NSCollectionLayoutSection(group: group)

    return section
  }
}
