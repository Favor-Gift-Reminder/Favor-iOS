//
//  AnniversaryResponseDTO.swift
//  Favor
//
//  Created by 이창준 on 2023/04/19.
//

import Foundation

public struct AnniversaryResponseDTO: Decodable {
  public let anniversaryDate: Date
  public let anniversaryNo: Int
  public let anniversaryTitle: String
  public let isPinned: Bool
  public let userNo: Int
}
