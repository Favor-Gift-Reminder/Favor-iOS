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
  
  
  
  // MARK: - Setup
  
  override func setupStyles() {
    
  }
  
  override func setupLayouts() {
    [
      pageControl
    ].forEach {
      view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    pageControl.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().inset(66)
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
