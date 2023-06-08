//
//  Receivable.swift
//  Favor
//
//  Created by 이창준 on 2023/06/06.
//

import Foundation

public protocol Receivable {
  associatedtype DTO: Decodable

  init(dto: DTO)
}
