//
//  OnboardingViewController.swift
//  Favor
//
//  Created by 이창준 on 2023/01/09.
//

import UIKit

import SnapKit

final class OnboardingViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let pageControl: UIPageControl = {
    let pc = UIPageControl()
    pc.numberOfPages = 3
    pc.pageIndicatorTintColor = FavorStyle.Color.box1.value
    pc.currentPageIndicatorTintColor = FavorStyle.Color.main.value
    
    return pc
  }()
  
  private lazy var collectionView: UICollectionView = {
    let cv = UICollectionView(frame: .zero, collectionViewLayout: onboardingLayout())
    cv.register(
      OnboardingCell.self,
      forCellWithReuseIdentifier: OnboardingCell.identifier
    )
    cv.isScrollEnabled = false
    cv.showsHorizontalScrollIndicator = false
    cv.dataSource = self
    cv.delegate = self
    
    return cv
  }()
  
  private lazy var onboardingSection: NSCollectionLayoutSection = {
    let size = NSCollectionLayoutSize(
      widthDimension: .absolute(view.frame.width),
      heightDimension: .absolute(collectionView.frame.height)
    )

    let item = NSCollectionLayoutItem(layoutSize: size)
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .paging

    // PageControl currentPage 반응 Closure
    section.visibleItemsInvalidationHandler = { _, offset, _ in
      let width = self.collectionView.frame.width
      self.pageControl.currentPage = Int(offset.x / width)
    }
    
    return section
  }()
  
  // MARK: - Setup
  
  override func setupStyles() {
    view.backgroundColor = .white
  }
  
  override func setupLayouts() {
    [
      pageControl,
      collectionView
    ].forEach {
      view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    pageControl.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(view.safeAreaLayoutGuide).inset(66)
    }
    
    collectionView.snp.makeConstraints { make in
      make.leading.trailing.bottom.equalToSuperview()
      make.top.equalTo(pageControl.snp.bottom)
    }
  }
}

// MARK: - Setup CollectionView

extension OnboardingViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: OnboardingCell.identifier,
      for: indexPath
    ) as? OnboardingCell else {
      return UICollectionViewCell()
    }

    if indexPath.row == 2 {
      cell.startBtn.isHidden = false
    }
    
    return cell
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    return 3
  }
  
  private func onboardingLayout() -> UICollectionViewCompositionalLayout {
    return UICollectionViewCompositionalLayout { [weak self] _, _ in
      return self?.onboardingSection
    }
  }
}
