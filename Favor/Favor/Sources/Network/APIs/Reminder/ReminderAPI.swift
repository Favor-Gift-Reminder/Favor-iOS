//
//  ReminderAPI.swift
//  Favor
//
//  Created by 김응철 on 2023/03/08.
//

import Foundation

import Moya

enum ReminderAPI {
  /// 전체 리마인더 조회
  case getAllReminders

  /// 단일 리마인더 조회
  /// - Parameters:
  ///   - reminderNo: 조회하는 리마인더의 DB 넘버 - `Path`
  case getReminder(reminderNo: Int)

  /// 리마인더 삭제
  /// - Parameters:
  ///   - reminderNo: 삭제하는 리마인더의 DB 넘버 - `Path`
  case deleteReminder(reminderNo: Int)

  /// 리마인더 수정
  /// ``` json
  /// // reminderRequestDTO
  /// {
  ///   "title": "제목",
  ///   "reminderDate": "1996-02-29",
  ///   "isAlarmSet": false,
  ///   "alarmTime": "2023-03-09T05:53:14.131Z",
  ///   "reminderMemo": "페이버"
  /// }
  /// ```
  /// - Parameters:
  ///   - dto: 수정하는 리마인더의 정보를 담은 리퀘스트 DTO - `Body`
  ///   - friendNo: 수정하는 리마인더와 관련된 친구의 DB 넘버 - `Query`
  ///   - reminderNo: 수정하는 리마인더의 DB 넘버 - `Path`
  case patchReminder(ReminderRequestDTO, friendNo: Int, reminderNo: Int)

  /// 리마인더 생성
  /// ``` json
  /// // reminderRequestDTO
  /// {
  ///   "title": "제목",
  ///   "reminderDate": "1996-02-29",
  ///   "isAlarmSet": false,
  ///   "alarmTime": "2023-03-09T05:53:14.131Z",
  ///   "reminderMemo": "페이버"
  /// }
  /// ```
  /// - Parameters:
  ///   - dto: 리마인더 리퀘스트 DTO - `Body`
  ///   - friendNo: 리마인더와 관련된 친구의 DB 넘버 - `Path`
  ///   - userNo: 리마인더를 생성하는 유저의 DB 넘버 - `Path`
  case postReminder(ReminderRequestDTO, friendNo: Int, userNo: Int)
}

extension ReminderAPI: BaseTargetType {
  var path: String { self.getPath() }
  var method: Moya.Method { self.getMethod() }
  var task: Moya.Task { self.getTask() }
}
