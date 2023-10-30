//
//  APIManager.swift
//  Favor
//
//  Created by 이창준 on 2023/02/28.
//

import Foundation
import OSLog

import FavorKit

/// > Usage:
///   ``` swift
///   APIManager.mock.baseURL
///   ```
public class APIManager {
  private typealias JSON = [String: Any]
  
  public enum HeaderType {
    case json
    case jwt
    case multiPart
  }
  
  private enum ServerType: String {
    case v1 = "Deployed_v1"
  }

  // MARK: - Properties

  public static let v1 = APIManager(.v1)
  private var type: ServerType

  /// plist 파일에 포함된 API의 BaseURL입니다.
  /// URL 끝에 '/'가 없습니다. Path를 작성할 때 `/user`와 같이 작성해주세요.
  public var baseURL: String {
    guard let filePath = Bundle.module.path(forResource: "API-Info", ofType: "plist") else {
      fatalError("Couldn't find the 'API-Info.plist' file.")
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

  // MARK: - Initializer

  private init(_ type: ServerType) {
    self.type = type
  }
}

// MARK: - TYPE METHODS

extension APIManager {
  public static func decode<T: Decodable>(_ data: Data) throws -> T {
    let decoder = JSONDecoder()
    do {
      let responseModel = try decoder.decode(T.self, from: data)
      return responseModel
    } catch {
      throw APIError.decodeError(error)
    }
  }
  
  public static func header(for header: HeaderType) -> [String: String] {
    switch header {
    case .json: return ["Content-Type": "application/json"]
    case .jwt: return [
      "Content-Type": "application/json",
      "X-AUTH-TOKEN": APIManager.accessToken()
    ]
    case .multiPart: return ["Content-Type": "multipart/form-data"]
    }
  }

  private static func accessToken() -> String {
    let keychain = KeychainManager()
    if let accessToken = try? keychain.get(account: KeychainManager.Accounts.accessToken.rawValue) {
      let accessTokenString = String(decoding: accessToken, as: UTF8.self)
      return accessTokenString
    }
    return ""
  }
}
