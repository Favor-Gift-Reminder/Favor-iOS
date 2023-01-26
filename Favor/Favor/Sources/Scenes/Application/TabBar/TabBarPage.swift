//
//  TabBarPage.swift
//  Favor
//
//  Created by 이창준 on 2022/12/31.
//

import UIKit

enum TabBarPage: Int, CaseIterable {
  case home = 0, reminder, myPage
  
  var tabBarItem: UITabBarItem {
    switch self {
    case .home:
      return UITabBarItem(
        title: "홈",
        image: UIImage(named: "ic_home"),
        selectedImage: nil
      )
    case .reminder:
      return UITabBarItem(
        title: "리마인더",
        image: UIImage(named: "ic_notification"),
        selectedImage: nil
      )
    case .myPage:
      return UITabBarItem(
        title: "마이페이지",
        image: UIImage(named: "ic_person_circle"),
        selectedImage: nil
      )
    }
  }
  
}
