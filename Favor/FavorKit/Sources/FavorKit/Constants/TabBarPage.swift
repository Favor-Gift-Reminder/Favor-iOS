//
//  TabBarPage.swift
//  Favor
//
//  Created by 이창준 on 2022/12/31.
//

import UIKit

public enum TabBarPage: Int, CaseIterable {
  case home = 0, reminder, myPage
  
  public var tabBarItem: UITabBarItem {
    var tabBar = UITabBarItem()
    switch self {
    case .home:
      tabBar = UITabBarItem(
        title: nil,
        image: .favorIcon(.home)?.resize(newWidth: 25),
        selectedImage: nil
      )
    case .reminder:
      tabBar = UITabBarItem(
        title: nil,
        image: .favorIcon(.noti)?.resize(newWidth: 25),
        selectedImage: nil
      )
    case .myPage:
      tabBar = UITabBarItem(
        title: nil,
        image: .favorIcon(.friend)?.resize(newWidth: 25),
        selectedImage: nil
      )
    }
    tabBar.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
    return tabBar
  }
}
