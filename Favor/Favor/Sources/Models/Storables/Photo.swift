//
//  Photo.swift
//  Favor
//
//  Created by 이창준 on 2023/07/07.
//

import Foundation

import FavorKit
import FavorNetworkKit
import class RealmSwift.ThreadSafe

public struct Photo: Receivable, Storable, Hashable {
  
  // MARK: - Properties
  
  public let identifier: Int
  /// 서버 이미지의 주소
  public let remote: String
  /// 로컬 이미지의 Cache Key
  public let local: String
  
  // MARK: - Receivable
  
  public init(singleDTO: PhotoResponseDTO) {
    self.identifier = singleDTO.id
    self.remote = singleDTO.photoUrl
    self.local = ""
  }
  
  // MARK: - Storable
  
  public init(realmObject: PhotoObject) {
    @ThreadSafe var rlmObjectRef = realmObject
    guard let realmObject = rlmObjectRef else { fatalError() }
    
    self.identifier = realmObject.photoNo
    self.remote = realmObject.remote
    self.local = realmObject.local
  }
  
  public func realmObject() -> PhotoObject {
    PhotoObject(
      photoNo: self.identifier,
      remote: self.remote,
      local: self.local
    )
  }
}

// MARK: - PropertyValue

extension Photo {
  public enum PropertyValue: PropertyValueType {
    case identifier(Int)
    case remote(String)
    case local(String)
    
    public var propertyValuePair: PropertyValuePair {
      switch self {
      case .identifier(let identifier):
        return ("identifier", identifier)
      case .remote(let remote):
        return ("remote", remote)
      case .local(let local):
        return ("local", local)
      }
    }
  }
}
