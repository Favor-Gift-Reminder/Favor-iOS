//
//  UserAPI.swift
//  Favor
//
//  Created by 김응철 on 2023/03/08.
//

import Foundation

import Moya

public enum UserAPI {
  /// 전체 회원 조회
  case getAllUsers

  /// 단일 회원 조회
  case getUser

  /// 회원 탈퇴
  case deleteUser
  
  /// 회원 수정
  /// ``` json
  /// // userUpdateRequestDTO
  /// {
  ///   "name": "페이버",
  ///   "userId": "Favor",
  ///   "favorList": [
  ///     "심플한",
  ///     "귀여운"
  ///   ]
  /// }
  /// ```
  /// - Parameters:
  ///   - name: 수정하는 유저의 이름 - `Body`
  ///   - userId: 수정하는 유저의 검색 아이디(@) - `Body`
  ///   - favorList: 수정하는 유저의 취향 목록 - `Body`
  case patchUser(name: String, userId: String, favorList: [String])
  
  /// 회원의 기념일 전체 조회
  case getAllAnnivesaryList
  
  /// 회원의 친구 전체 조회
  case getAllFriendList
  
  /// 회원의 선물 전체 조회
  case getAllGifts

  /// 카테고리로 회원 선물 조회
  /// - Parameters:
  ///   - category: 조회하는 선물의 카테고리 - `Path`
  ///     (*Available Values: 가벼운 선물, 생일, 집들이, 시험, 승진, 졸업, 기타*)
  case getGiftByCategory(category: String)

  /// 감정으로 회원 선물 조회
  /// - Parameters:
  ///   - emotion: 조회하는 선물의 감정 - `Path`
  ///     (*Available Values: 감동이에요, 기뻐요, 좋아요, 그냥그래요, 별로에요*)
  case getGiftByEmotion(emotion: String)

  /// 이름으로 회원 선물 조회
  /// - Parameters:
  ///   - giftName: 조회하는 선물의 이름 - `Path`
  case getGiftByName(giftName: String)
  
  /// 유저가 준 선물 전체 조회
  /// - Parameters:
  ///  - userNo: 조회하는 유저의 DB 넘버 - `Path`
  case getGiftsGivenByUser(userNo: Int)
  
  /// 유저가 받은 선물 전체 조회
  /// - Parameters:
  ///  - userNo: 조회하는 유저의 DB 넘버 - `Path`
  case getGiftsReceivedByUser(userNo: Int)

  /// 아이디로 회원 조회
  /// - Parameters:
  ///   - userId: 조회하는 유저의 검색 아이디(@) - `Path`
  case getUserId(userId: String)

  /// 프로필 생성
  /// ``` json
  /// // profileDTO
  /// {
  ///   "userId": "Favor",
  ///   "name": "페이버"
  /// }
  /// ```
  /// - Parameters:
  ///   - userId: 생성하는 유저 프로필의 검색 아이디(@) - `Body`
  ///   - name: 생성하는 유저 프로필의 이름 - `Body`
  case patchProfile(userId: String, name: String)

  /// 회원의 리마인더 전체 조회
  case getAllReminderList
  
  /// 회원의 리마인더 필터 조회
  /// - Parameters:
  ///  - year: 리마인더를 조회할 년도 값입니다.
  ///  - month: 리마인더를 조회할 월 값입니다.
  case getAllFilterReminderList(year: Int, month: Int)
  
  
  /// 로그인
  /// ``` json
  /// // signDTO
  /// {
  ///   "email": "favor@gmail.com",
  ///   "password": "********",
  /// }
  /// ```
  /// - Parameters:
  ///   - email: 로그인하는 회원의 이메일 주소 - `Body`
  ///   - password: 로그인하는 회원의 비밀번호 - `Body`
  case postSignIn(email: String, password: String)

  /// 회원가입
  /// ``` json
  /// // signDTO
  /// {
  ///   "email": "favor@gmail.com",
  ///   "password": "********",
  /// }
  /// ```
  /// - Parameters:
  ///   - email: 가입하는 회원의 이메일 주소 - `Body`
  ///   - password: 가입하는 회원의 비밀번호 - `Body`
  case postSignUp(email: String, password: String)
}

extension UserAPI: BaseTargetType {
  public var path: String { self.getPath() }
  public var method: Moya.Method { self.getMethod() }
  public var task: Moya.Task { self.getTask() }
  public var authorizationType: JWTAuthorizationType? {
    switch self {
    case .postSignIn, .postSignUp:
      return .none
    default:
      return .accessToken
    }
  }
}
