//
//  ReminderEditor.swift
//  Favor
//
//  Created by 이창준 on 2023/04/05.
//

import Foundation

public struct ReminderEditor {
  let pk: Int
  var title: String
  var date: Date
  var memo: String?
  var shouldNotify: Bool
  var notifyTime: Date?
  var friend: Int
}
