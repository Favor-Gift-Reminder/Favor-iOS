//
//  AnniversaryListType.swift
//  Favor
//
//  Created by 김응철 on 6/16/23.
//

import FavorKit

/// 기념일 리스트를 분기처리위한 열거형입니다.
public enum AnniversaryListType: Equatable {
  /// 나의 기념일들을 조회합니다.
  case mine
  /// 친구의 기념일들을 조회합니다.
  ///
  /// 유저일 경우와 그렇지 않을 경우를 구분해야합니다.
  ///
  /// *서버에서 데이터를 받아오기 전에 UI를 변경해야합니다.
  case friend(friend: Friend)
}
