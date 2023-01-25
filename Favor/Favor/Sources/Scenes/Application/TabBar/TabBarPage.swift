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
        title: "홈",
        image: UIImage(systemName: "house.fill"),
        selectedImage: nil
      )
    case .reminder:
      return UITabBarItem(
        title: "리마인더",
        image: UIImage(systemName: "bell.fill"),
        selectedImage: nil
      )
    case .myPage:
      return UITabBarItem(
        title: "마이페이지",
        image: UIImage(systemName: "person.circle.fill"),
        selectedImage: nil
      )
    }
  }
  
}
