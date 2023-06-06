//
//  URLSchemes.swift
//  Favor
//
//  Created by 이창준 on 2023/05/30.
//

import Foundation
import OSLog

public enum URLSchemes {
  case instagramStory

  public var url: String {
    switch self {
    case .instagramStory:
      return "instagram-stories://share?source_application=\(self.appID)"
    }
  }

  public var appID: String {
    switch self {
    case .instagramStory:
      return self.fetchAppID()
    }
  }
}

// MARK: - Privates

private extension URLSchemes {
  private typealias JSON = [String: Any]

  private var plistKey: String {
    switch self {
    case .instagramStory:
      return "InstagramStory"
    }
  }

  func fetchAppID() -> String {
    guard let filePath = Bundle.module.path(forResource: "API-Info", ofType: "plist") else {
      fatalError("Couldn't find the 'API-Info.plist' file.")
    }

    var value: String = ""
    var plist: JSON = [:]
    do {
      var plistRAW: Data
      if #available(iOS 16.0, *) {
        plistRAW = try Data(contentsOf: URL(filePath: filePath))
      } else {
        plistRAW = try NSData(contentsOfFile: filePath) as Data
      }
      let root = try PropertyListSerialization.propertyList(from: plistRAW, format: nil) as! JSON
      plist = root["AppID"] as! JSON
      value = plist[self.plistKey] as! String
    } catch {
      os_log(.error, "\(error)")
    }

    return value
  }
}
