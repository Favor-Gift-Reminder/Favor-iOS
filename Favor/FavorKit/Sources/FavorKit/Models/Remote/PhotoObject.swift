//
//  PhotoObject.swift
//  Favor
//
//  Created by 이창준 on 2023/03/19.
//

import RealmSwift

public class PhotoObject: Object {
  @Persisted(primaryKey: true) public var photoNo: Int
  /// Remote URL
  @Persisted public var remote: String
  /// Cache Key
  @Persisted public var local: String

  public convenience init(photoNo: Int, remote: String, local: String) {
    self.init()
    self.photoNo = photoNo
    self.remote = remote
    self.local = local
  }
}
