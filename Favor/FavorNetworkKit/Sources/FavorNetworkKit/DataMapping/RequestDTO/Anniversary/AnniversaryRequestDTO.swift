//
//  AnniversaryRequestDTO.swift
//  Favor
//
//  Created by 이창준 on 2023/04/19.
//

public struct AnniversaryRequestDTO: Encodable {
  public let anniversaryTitle: String
  public let anniversaryDate: String

  public init(
    anniversaryTitle: String,
    anniversaryDate: String
  ) {
    self.anniversaryTitle = anniversaryTitle
    self.anniversaryDate = anniversaryDate
  }
}
