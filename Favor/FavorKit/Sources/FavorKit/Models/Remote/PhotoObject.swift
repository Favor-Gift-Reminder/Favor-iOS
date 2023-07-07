//
//  PhotoObject.swift
//  Favor
//
//  Created by 이창준 on 2023/03/19.
//

import RealmSwift

public class PhotoObject: Object {
  @Persisted(primaryKey: true) var photoNo: Int
  /// Remote URL
  @Persisted var remote: String
  /// Cache Key
  @Persisted var local: String
}
