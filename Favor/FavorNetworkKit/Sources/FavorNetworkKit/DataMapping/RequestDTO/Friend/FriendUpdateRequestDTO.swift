//
//  FriendUpdateRequestDTO.swift
//  Favor
//
//  Created by 이창준 on 2023/04/19.
//

public struct FriendUpdateRequestDTO: Encodable {
  let friendName: String
  let friendMemo: String

  public init(
    friendName: String,
    friendMemo: String
  ) {
    self.friendName = friendName
    self.friendMemo = friendMemo
  }
}
