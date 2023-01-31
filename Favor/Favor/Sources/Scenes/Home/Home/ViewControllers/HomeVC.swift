//
//  HomeVC.swift
//  Favor
//
//  Created by 이창준 on 2022/12/30.
//

import UIKit

import ReactorKit
import RxDataSources
import RxSwift
import SnapKit

final class HomeViewController: BaseViewController, View {
	typealias Reactor = HomeReactor
	
	// MARK: - Properties
  
  enum HomeSection: Int {
    case upcoming
    case timeline
  }
  
  let dataSource = RxCollectionViewSectionedAnimatedDataSource<UpcomingSection>(
    configureCell: { _, collectionView, indexPath, item in
      guard let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: ReminderCell.reuseIdentifier,
        for: indexPath
      ) as? ReminderCell else {
        return UICollectionViewCell()
      }
      cell.testLabel.text = item
      return cell
    }
  )
  
  // TODO: ReactorKit 적용
  // 초기값을 설정해주니 RxDataSources를 활용한 데이터 변경이 적용됐다.
  
  let mockSections = [
    UpcomingSection(header: "one", items: ["1"])
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    Observable.just(self.mockSections)
      .bind(to: self.collectionView.rx.items(dataSource: self.dataSource))
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - UI Components
  
  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: self.view.bounds,
      collectionViewLayout: self.setupCollectionView()
    )
    collectionView.register(ReminderCell.self, forCellWithReuseIdentifier: ReminderCell.reuseIdentifier)
    collectionView.backgroundColor = .clear
    return collectionView
  }()
	
	// MARK: - Setup
  
  override func setupLayouts() {
    [
      self.collectionView
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.collectionView.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide)
      make.leading.trailing.equalTo(self.view.layoutMarginsGuide)
      make.bottom.equalToSuperview()
    }
  }
	
	// MARK: - Binding
	
  func bind(reactor: HomeReactor) {
    // Action
    Observable.just(())
      .map { Reactor.Action.viewDidLoad }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { $0.sections }
      .bind(to: self.collectionView.rx.items(dataSource: self.dataSource))
      .disposed(by: self.disposeBag)
  }
}

private extension HomeViewController {
  
  func setupCollectionView() -> UICollectionViewLayout {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .fractionalHeight(1.0)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .estimated(95.0)
    )
    let group = {
      if #available(iOS 16.0, *) {
        let group = NSCollectionLayoutGroup.vertical(
          layoutSize: groupSize,
          repeatingSubitem: item,
          count: 3
        )
        return group
      } else {
        let group = NSCollectionLayoutGroup.vertical(
          layoutSize: groupSize,
          subitem: item,
          count: 3
        )
        return group
      }
    }()
    group.interItemSpacing = .fixed(10)
    
    let section = NSCollectionLayoutSection(group: group)
    
    let layout = UICollectionViewCompositionalLayout(section: section)
    
    return layout
  }
  
}
