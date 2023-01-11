//
//  TabBarPage.swift
//  Favor
//
//  Created by 이창준 on 2022/12/31.
//

import UIKit

enum TabBarPage: Int, CaseIterable {
  case home = 0, reminder, myPage
  
  // TODO: - TabBarItem configuration
  var tabBarItem: UITabBarItem {
    switch self {
    case .home:
      return UITabBarItem(
        title: nil,
        image: nil,
        selectedImage: nil
      )
    case .reminder:
      return UITabBarItem(
        title: nil,
        image: nil,
        selectedImage: nil
      )
    case .myPage:
      return UITabBarItem(
        title: nil,
        image: nil,
        selectedImage: nil
      )
    }
  }
  
}
