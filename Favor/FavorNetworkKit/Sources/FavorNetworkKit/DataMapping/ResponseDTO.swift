//
//  File.swift
//  
//
//  Created by 김응철 on 2023/03/14.
//

import Foundation

struct ResponseDTO<T: Decodable> {
  let responseCode: String
  let responseMessage: String
  let data: T
}
