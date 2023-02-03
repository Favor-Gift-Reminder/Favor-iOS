//
//  ReuseIdentifying.swift
//  Favor
//
//  Created by 김응철 on 2023/01/16.
//

import Foundation

protocol ReuseIdentifying {
  static var reuseIdentifier: String { get }
}

extension ReuseIdentifying {
  static var reuseIdentifier: String {
    return String(describing: self)
  }
}
