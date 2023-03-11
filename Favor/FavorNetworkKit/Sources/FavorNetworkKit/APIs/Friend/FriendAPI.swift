//
//  FriendTarget.swift
//  Favor
//
//  Created by 김응철 on 2023/03/08.
//

import Foundation

import Moya

public enum FriendAPI {
  /// 전체 친구 조회
  case getAllFriends

  /// 단일 친구 조회
  /// - Parameters:
  ///   - friendNo: 조회하는 친구의 DB 넘버 - `Path`
  case getFriend(friendNo: Int)

  /// 친구 삭제
  /// - Parameters:
  ///   - friendNo: 삭제하는 친구의 DB 넘버 - `Path`
  case deleteFriend(friendNo: Int)

  /// 친구 수정
  /// ``` json
  /// // friendRequestDTO
  /// {
  ///   "friendName": "이름",
  ///   "friendMemo": "메모",
  /// }
  /// ```
  /// - Parameters:
  ///   - friendName: 수정하는 친구의 이름 - `Body`
  ///   - friendMemo: 수정하는 친구의 메모 - `Body`
  ///   - friendNo: 수정하는 친구의 DB 넘버 - `Path`
  case patchFriend(friendName: String, friendMemo: String, friendNo: Int)

  /// 친구 생성
  /// ``` json
  /// // friendRequestDTO
  /// {
  ///   "friendName": "이름",
  ///   "friendMemo": "메모",
  /// }
  /// ```
  /// - Parameters:
  ///   - friendName: 추가하는 친구의 이름 - `Body`
  ///   - friendMemo: 추가하는 친구의 메모 - `Body`
  ///   - friendNo: 추가하는 친구의 DB 넘버 - `Path`
  case postFriend(friendName: String, friendMemo: String, userNo: Int)

  /// 회원친구 추가
  /// ``` json
  /// // friendRequestDTO
  /// {
  ///   "userFriendNo": 1,
  ///   "userFriendMemo": "메모",
  /// }
  /// ```
  /// - Parameters:
  ///   - userFriendNo: 추가하는 유저 친구의 친구 목록 넘버 - `Body`
  ///   - userFriendMemo: 추가하는 유저 친구의 메모 - `Body`
  ///   - userNo: 추가하는 친구의 회원 DB 넘버 - `Path`
  case postUserFriend(userFriendNo: Int, userFriendMemo: String, userNo: Int)
}

extension FriendAPI: BaseTargetType {
  public var path: String { self.getPath() }
  public var method: Moya.Method { self.getMethod() }
  public var task: Moya.Task { self.getTask() }
}
