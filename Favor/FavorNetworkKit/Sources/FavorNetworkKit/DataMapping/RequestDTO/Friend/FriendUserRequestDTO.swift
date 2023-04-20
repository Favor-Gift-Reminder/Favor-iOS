//
//  FriendUserRequestDTO.swift
//  Favor
//
//  Created by 이창준 on 2023/04/19.
//

import Foundation

public struct FriendUserRequestDTO: Encodable {
  let friendUserNo: Int
  let userFriendMemo: String
}
