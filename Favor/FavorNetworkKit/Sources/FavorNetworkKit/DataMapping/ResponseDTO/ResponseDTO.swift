//
//  ResponseDTO.swift
//  
//
//  Created by 김응철 on 2023/03/14.
//

import Foundation

public struct ResponseDTO<T: Decodable>: Decodable {
  public let responseCode: String
  public let responseMessage: String
  public let data: T
}
