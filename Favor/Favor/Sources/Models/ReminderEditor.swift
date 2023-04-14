//
//  ReminderEditor.swift
//  Favor
//
//  Created by 이창준 on 2023/04/05.
//

import Foundation

public struct ReminderEditor {
  var title: String = ""
  var date: Date = .now
  var memo: String?
  var shouldNotify: Bool = false
  var notifyTime: Date?
  var friend: Int = -1
}
