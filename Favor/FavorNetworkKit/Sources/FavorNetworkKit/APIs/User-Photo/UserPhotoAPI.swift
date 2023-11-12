//
//  UserPhotoAPI.swift
//
//
//  Created by 김응철 on 11/12/23.
//

import Foundation

import Moya

public enum UserPhotoAPI {
  /// 회원 배경 사진 수정
  /// 
  /// - Parameters:
  ///   - file: 사진 파일
  case postBackground(file: MultipartFormData)
  
  /// 회원 프로필 사진 수정
  ///
  /// - Parameters:
  ///   - file: 사진 파일
  case postProfile(file: MultipartFormData)
}

extension UserPhotoAPI: BaseTargetType {
  public var path: String { self.getPath() }
  public var method: Moya.Method { self.getMethod() }
  public var task: Moya.Task { self.getTask() }
}
