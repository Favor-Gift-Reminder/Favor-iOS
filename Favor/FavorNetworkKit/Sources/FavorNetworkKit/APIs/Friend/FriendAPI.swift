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

  /// 친구 메모 수정
  /// ``` json
  /// // friendRequestDTO
  /// {
  ///   "memo": "메모수정완료",
  /// }
  /// ```
  /// - Parameters:
  ///   - memo: 수정하는 친구의 메모 - `Body`
  ///   - friendNo: 수정하는 친구의 DB 넘버 - `Path`
  case patchFriendMemo(memo: String, friendNo: Int)
  
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
  @available(
    *,
     deprecated,
     renamed: "postUserFriend",
     message: "비회원 친구추가 API는 삭제되었습니다. 대신 `postUserFriend`을 이용하세요."
  )
  case postFriend(friendName: String, friendMemo: String, userNo: Int)
  
  /// 회원친구 추가
  /// ``` json
  /// // friendRequestDTO
  /// {
  ///   "userFriendNo": 1,
  /// }
  /// ```
  /// - Parameters:
  ///   - userFriendNo: 추가하는 유저 친구의 친구 목록 넘버 - `Body`
  case postUserFriend(userFriendNo: Int)
  
  /// 친구가 준 선물 전체 조회
  /// - Parameters:
  ///  - friendNo: 조회하는 친구의 DB 넘버 - `Path`
  case getFriendGivenGifts(friendNo: Int)
  
  /// 친구가 받은 선물 전체 조회
  /// - Parameters:
  ///  - friendNo: 조회하는 친구의 DB 넘버 - `Path`
  case getFriendReceivedGifts(friendNo: Int)

  /// 친구의 선물 전체 조회
  /// - Parameters:
  ///  - friendNo: 조회하는 친구의 DB 넘버 - `Path`
  case getFriendTotalGifts(friendNo: Int)

}

extension FriendAPI: BaseTargetType {
  public var path: String { self.getPath() }
  public var method: Moya.Method { self.getMethod() }
  public var task: Moya.Task { self.getTask() }
}
