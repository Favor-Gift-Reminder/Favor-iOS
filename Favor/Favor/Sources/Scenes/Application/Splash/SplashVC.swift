//
//  SplashVC.swift
//  Favor
//
//  Created by 이창준 on 2022/12/31.
//

import UIKit

import ReactorKit

final class SplashViewController: BaseViewController, View {
  typealias Reactor = SplashReactor
  
  // MARK: - Setup
  
  override func setupStyles() {
    self.view.backgroundColor = .systemBackground
  }
  
  // MARK: - Binding
  
  func bind(reactor: SplashReactor) {
    // TODO: - pre-fetch 로직 + 완료 시 coordinator 동작
  }
}
