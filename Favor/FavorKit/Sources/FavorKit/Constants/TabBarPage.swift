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
      let image: UIImage = .favorIcon(.home)!.resize(newWidth: 19)
      tabBar = UITabBarItem(
        title: nil,
        image: image,
        selectedImage: nil
      )
    case .reminder:
      let image: UIImage = .favorIcon(.noti)!.resize(newWidth: 18)
      tabBar = UITabBarItem(
        title: nil,
        image: image,
        selectedImage: nil
      )
    case .myPage:
      let image: UIImage = .favorIcon(.friend)!.resize(newWidth: 19)
      tabBar = UITabBarItem(
        title: nil,
        image: image,
        selectedImage: nil
      )
    }
    tabBar.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
    return tabBar
  }
}
