//
//  MyPageVC.swift
//  Favor
//
//  Created by 이창준 on 2023/01/11.
//

import UIKit

import ReactorKit
import RxDataSources
import SnapKit

final class MyPageViewController: BaseViewController, View {
  typealias MyPageDataSource = RxCollectionViewSectionedReloadDataSource<MyPageSection>
  
  // MARK: - Constants
  
  // MARK: - Properties
  
  let dataSource = MyPageDataSource(
    configureCell: { dataSource, collectionView, indexPath, items -> UICollectionViewCell in
      switch items {
      case .giftCount:
        return UICollectionViewCell()
      case .newProfile:
        return UICollectionViewCell()
      case .favor:
        return UICollectionViewCell()
      case .anniversary:
        return UICollectionViewCell()
      }
    }
  )
  
  // MARK: - UI Components
  
  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: self.setupCollectionView()
    )
    collectionView.backgroundColor = .clear
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    return collectionView
  }()
  
  // MARK: - Life Cycle
  
  // MARK: - Binding
  
  func bind(reactor: MyPageReactor) {
    // Action
    
    // State
    reactor.state.map { $0.sections }
      .do(onNext: {
        print("⬆️ Section: \($0)")
      })
      .bind(to: self.collectionView.rx.items(dataSource: self.dataSource))
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions
  
  // MARK: - UI Setups
  
  override func setupStyles() {
    super.setupStyles()
  }
  
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
}

// MARK: - CollectionView

private extension MyPageViewController {
  func setupCollectionView() -> UICollectionViewLayout {
    
    // 새 프로필
    // 취향
    // 기념일
    // 친구 (?)
    
    return UICollectionViewFlowLayout()
  }
}
