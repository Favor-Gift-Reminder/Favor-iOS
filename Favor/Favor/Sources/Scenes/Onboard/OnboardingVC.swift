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
    let layout = UICollectionViewFlowLayout()
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    
    return cv
  }()
  
  // MARK: - Setup
  
  override func setupStyles() {}
  
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
      make.top.equalToSuperview().inset(66)
    }
    
    collectionView.snp.makeConstraints { make in
      make.leading.trailing.bottom.equalToSuperview()
      make.top.equalTo(pageControl.snp.bottom)
    }
  }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct OnboardingVC_PreView: PreviewProvider {
  static var previews: some View {
    OnboardingViewController().toPreview()
  }
}
#endif
