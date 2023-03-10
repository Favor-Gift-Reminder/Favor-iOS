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
  /// - Parameters:
  ///   - userNo: 조회하는 유저의 DB 넘버 - `Path`
  case getUser(userNo: Int)

  /// 회원 탈퇴
  /// - Parameters:
  ///   - userNo: 탈퇴하는 유저의 DB 넘버 - `Path`
  case deleteUser(userNo: Int)

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
  ///   - userNo: 수정하는 유저의 DB 넘버 - `Path`
  case patchUser(name: String, userId: String, favorList: [String], userNo: Int)

  /// 회원의 친구 전체 조회
  /// - Parameters:
  ///   - userNo: 조회하는 유저의 DB 넘버 - `Path`
  case getAllFriendList(userNo: Int)

  /// 카테고리로 회원 선물 조회
  /// - Parameters:
  ///   - category: 조회하는 선물의 카테고리 - `Path`
  ///     (*Available Values: 가벼운 선물, 생일, 집들이, 시험, 승진, 졸업, 기타*)
  ///   - userNo: 조회하는 유저의 DB 넘버 - `Path`
  case getGiftByCategory(category: String, userNo: Int)

  /// 감정으로 회원 선물 조회
  /// - Parameters:
  ///   - emotion: 조회하는 선물의 감정 - `Path`
  ///     (*Available Values: 감동이에요, 기뻐요, 좋아요, 그냥그래요, 별로에요*)
  ///   - userNo:조회하는 유저의 DB 넘버 - `Path`
  case getGiftByEmotion(emotion: String, userNo: Int)

  /// 이름으로 회원 선물 조회
  /// - Parameters:
  ///   - giftName: 조회하는 선물의 이름 - `Path`
  ///   - userNo: 조회하는 유저의 DB 넘버 - `Path`
  case getGiftByName(giftName: String, userNo: Int)

  /// 회원의 선물 전체 조회
  /// - Parameters:
  ///   - userNo: 조회하는 유저의 DB 넘버 - `Path`
  case getAllGifts(userNo: Int)

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
  ///   - userNo: 프로필을 생성하는 유저의 DB 넘버 - `Path`
  case patchProfile(userId: String, name: String, userNo: Int)

  /// 회원의 리마인더 전체 조회
  /// - Parameters:
  ///   - userNo: 조회하는 유저의 DB 넘버 - `Path`
  case getAllReminderList(userNo: Int)

  /// 회원가입
  /// ``` json
  /// // signUpDTO
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
}
