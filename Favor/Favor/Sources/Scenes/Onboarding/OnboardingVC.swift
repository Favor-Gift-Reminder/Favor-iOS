//
//  OnboardingViewController.swift
//  Favor
//
//  Created by 이창준 on 2023/01/09.
//

import UIKit

import Reusable
import RxCocoa
import RxFlow
import RxSwift
import SnapKit

final class OnboardingViewController: BaseViewController, Stepper {
  
  // MARK: - UI COMPONENTS
  
  private let pageControl: UIPageControl = {
    let pc = UIPageControl()
    pc.numberOfPages = 3
    pc.pageIndicatorTintColor = .favorColor(.line3)
    pc.currentPageIndicatorTintColor = .favorColor(.icon)
    
    return pc
  }()
  
  private lazy var collectionView: UICollectionView = {
    let cv = UICollectionView(frame: .zero, collectionViewLayout: onboardingLayout())
    cv.register(cellType: OnboardingCell.self)
    cv.isScrollEnabled = false
    cv.showsHorizontalScrollIndicator = false
    cv.dataSource = self
    cv.delegate = self
    
    return cv
  }()
  
  private lazy var startButton: UIButton = {
    let btn = FavorLargeButton(with: .main("시작하기"))
    btn.isEnabled = false
    btn.configurationUpdateHandler = {
      switch $0.state {
      case .disabled:
        $0.configuration = LargeFavorButtonType.gray("시작하기").configuration
      default:
        $0.configuration = LargeFavorButtonType.main("시작하기").configuration
      }
    }
    
    return btn
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
  
  // MARK: - PROPERTIES
  
  private var currentPage: Int = 0 {
    didSet {
      self.pageControl.currentPage = currentPage
      self.startButton.isEnabled = self.currentPage == 2 ? true : false
    }
  }
  
  private let slides = OnboardingSlide.slides()
  var steps = PublishRelay<Step>()
  
  // MARK: - SETUP
  
  override func setupLayouts() {
    [
      self.pageControl,
      self.collectionView,
      self.startButton
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.pageControl.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.view.safeAreaLayoutGuide).inset(32)
    }
    
    self.collectionView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(self.pageControl.snp.bottom)
      make.bottom.equalTo(self.startButton.snp.top)
    }
    
    self.startButton.snp.makeConstraints { make in
      make.leading.trailing.equalTo(self.view.layoutMarginsGuide)
      make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(32)
    }
  }
}

// MARK: - Setup CollectionView

extension OnboardingViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(for: indexPath) as OnboardingCell
    cell.configure(with: self.slides[indexPath.row])
    
    return cell
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    return self.slides.count
  }
  
  private func onboardingLayout() -> UICollectionViewCompositionalLayout {
    return UICollectionViewCompositionalLayout { [weak self] _, _ in
      return self?.onboardingSection
    }
  }
}
