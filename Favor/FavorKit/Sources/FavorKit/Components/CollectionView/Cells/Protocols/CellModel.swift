//
//  CellModel.swift
//  Favor
//
//  Created by 이창준 on 2023/05/20.
//

import RealmSwift

public protocol CellModel {
  associatedtype T: Object

  var item: T { get set }
}
