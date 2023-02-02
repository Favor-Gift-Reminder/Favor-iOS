//
//  OnboardingViewController.swift
//  Favor
//
//  Created by 이창준 on 2023/01/09.
//

import UIKit

import RxCocoa
import RxFlow
import RxSwift
import SnapKit

final class OnboardingViewController: BaseViewController, Stepper {
  
  // MARK: - Properties
  
  private let pageControl: UIPageControl = {
    let pc = UIPageControl()
    pc.numberOfPages = 3
    pc.pageIndicatorTintColor = .favorColor(.box1)
    pc.currentPageIndicatorTintColor = .favorColor(.main)
    
    return pc
  }()
  
  private lazy var collectionView: UICollectionView = {
    let cv = UICollectionView(frame: .zero, collectionViewLayout: onboardingLayout())
    cv.register(
      OnboardingCell.self,
      forCellWithReuseIdentifier: OnboardingCell.reuseIdentifier
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
      self.currentPage = Int(offset.x / width)
    }
    
    return section
  }()
  
  private lazy var continueButton: LargeFavorButton = {
    let btn = LargeFavorButton(with: .white, title: "다음")
    btn.addTarget(self, action: #selector(didTapContinueButton), for: .touchUpInside)
    
    return btn
  }()
  
  private var currentPage: Int = 0 {
    didSet {
      self.pageControl.currentPage = currentPage
      let handler = UpdateHandlerManager.onboardingHandler(currentPage)
      self.continueButton.configurationUpdateHandler = handler
    }
  }
  
  var steps = PublishRelay<Step>()
  
  // MARK: - Setup
  
  override func setupStyles() {
    view.backgroundColor = .white
  }
  
  override func setupLayouts() {
    [
      self.pageControl,
      self.collectionView,
      self.continueButton
    ].forEach {
      view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.pageControl.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(view.safeAreaLayoutGuide).inset(66)
    }
    
    self.collectionView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(pageControl.snp.bottom)
      make.bottom.equalTo(continueButton.snp.top)
    }
    
    self.continueButton.snp.makeConstraints { make in
      make.leading.trailing.equalTo(view.layoutMarginsGuide)
      make.bottom.equalToSuperview().inset(53)
    }
  }
  
  // MARK: - Selectors
  
  @objc
  private func didTapContinueButton() {
    let indexPath = IndexPath(row: self.currentPage + 1, section: 0)
    self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
  }
}

// MARK: - Setup CollectionView

extension OnboardingViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: OnboardingCell.reuseIdentifier,
      for: indexPath
    ) as? OnboardingCell else {
      return UICollectionViewCell()
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
