//
//  APIManager.swift
//  Favor
//
//  Created by 이창준 on 2023/02/28.
//

import Foundation
import OSLog

/// > Usage:
///   ``` swift
///   APIManager.mock.baseURL
///   ```
class APIManager {
  private typealias JSON = [String: Any]

  // MARK: - Properties

  static let mock = APIManager(.mock)

  private enum ServerType: String {
    case mock = "MockServer"
    case v1 = "Deployed_v1"
  }

  private var type: ServerType

  // MARK: - Initializer

  private init(_ type: ServerType) {
    self.type = type
  }

  // MARK: - Functions

  /// plist 파일에 포함된 API의 BaseURL입니다.
  /// URL 끝에 '/'가 없습니다. Path를 작성할 때 `/user`와 같이 작성해주세요.
  var baseURL: String {
    guard let filePath = Bundle.main.path(forResource: "API-Info", ofType: "plist") else {
      fatalError("Couldn't find the 'MockAPI-Info.plist' file.")
    }

    var plist: JSON = [:]
    do {
      var plistRAW: Data
      if #available(iOS 16.0, *) {
        plistRAW = try Data(contentsOf: URL(filePath: filePath))
      } else {
        plistRAW = try NSData(contentsOfFile: filePath) as Data
      }
      let root = try PropertyListSerialization.propertyList(from: plistRAW, format: nil) as! JSON
      plist = root[self.type.rawValue] as! JSON
    } catch {
      os_log(.error, "\(error)")
    }

    guard let value = plist["BaseURL"] as? String else {
      fatalError("plist file doesn't have value with key 'BaseURL'.")
    }
    return value
  }
}
