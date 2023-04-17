//
//  FavorCompositionalLayout+Adaptive.swift
//  Favor
//
//  Created by 이창준 on 2023/04/18.
//

public protocol Adaptive {
  var item: FavorCompositionalLayout.Item { get }
  var group: FavorCompositionalLayout.Group { get }
  var section: FavorCompositionalLayout.Section { get }
}
