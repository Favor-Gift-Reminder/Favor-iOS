//
//  FriendResponseDTO.swift
//
//
//  Created by 김응철 on 10/13/23.
//

import Foundation

public struct FriendResponseDTO: Decodable {
  public let friendName: String
  public let friendNo: Int
  public let photo: [PhotoResponseDTO]?
}
