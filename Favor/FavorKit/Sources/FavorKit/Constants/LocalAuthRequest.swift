//
//  LocalAuthRequest.swift
//  Favor
//
//  Created by 이창준 on 6/30/23.
//

import Foundation

public enum LocalAuthRequest {
  public typealias ResultHandler = ((Data?) throws -> Void)

  case authenticate(ResultHandler)
  case askCurrent(ResultHandler)
  case askNew(ResultHandler)
  case confirmNew(String, ResultHandler)
  case disable(ResultHandler)
}
