//
//  ReminderAlertManager.swift
//  Favor
//
//  Created by 김응철 on 2023/12/17.
//

class NotificationManager {
    
    static let shared = NotificationManager()
    
    private init() {}
    
    // 알림 권한 요청
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                print("알림 권한이 허용되었습니다.")
            } else {
                print("알림 권한이 거부되었습니다.")
            }
        }
    }
    
    // 특정 시간에 알림 설정
    func scheduleNotification(at date: Date, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("알림 설정에 실패했습니다. 오류: \(error.localizedDescription)")
            } else {
                print("알림이 성공적으로 설정되었습니다.")
            }
        }
    }
    
    // 특정 시간에 설정된 알림 해제
    func cancelNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}


import Foundation
import UserNotifications
import OSLog

import FavorNetworkKit
import RxSwift
import RxCocoa

final class ReminderAlertManager {
  
  // MARK: - Properties
  
  static let shared = ReminderAlertManager()
  private var reminders: [Reminder] = []
  
  // MARK: - Init
  
  private init() {}
  
  // MARK: - Functions
  
  func requestAuthorization() {
    UNUserNotificationCenter.current().requestAuthorization(
      options: [.alert, .sound]
    ) { granted, error in
      if granted {
        os_log(.info, "🚨 알림 권한이 승인되었습니다.")
      } else {
        os_log(.info, "🚨 알림 권한이 거절되었습니다.")
      }
    }
  }
  
  func fetchReminders() {
    let networking = UserNetworking()
    _ = networking.request(.getAllReminderList)
      .map(ResponseDTO<[ReminderResponseDTO]>.self)
      .map { $0.data.map { Reminder(dto: $0) } }
      .subscribe(onNext: { reminders in
        ReminderAlertManager.shared.reminders = reminders
        self.addAllNotifications()
      })
  }
  
  /// 리마인더 삭제
  func removeReminder(_ reminder: Reminder) {
    guard
      let firstIndex = self.reminders.firstIndex(where: { $0.identifier == reminder.identifier })
    else { return }
    self.reminders.remove(at: firstIndex)
    self.cancelNotification(withIdentifier: "\(reminder.identifier)")
  }
  
  /// 리마인더 배열에 추가합니다.
  func addReminders(_ reminder: Reminder) {
    self.reminders.append(reminder)
    self.addNotification(reminder)
  }
  
  /// 리마인더가 수정됐을 때의 메서드입니다.
  ///
  /// - Parameters:
  ///   - reminder: 수정된 리마인더
  func reminderDidEdit(_ reminder: Reminder) {
    guard let firstIndex = self.reminders
      .firstIndex(where: { $0.identifier == reminder.identifier })
    else { return }
    self.reminders[firstIndex] = reminder
    self.cancelNotification(withIdentifier: "\(reminder.identifier)")
    if reminder.shouldNotify {
      self.addNotification(reminder)
    }
  }
  
  /// 모든 리마인더의 알람을 일괄 취소합니다.
  func cancelAllNotifications() {
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
  }
  
  /// 모든 리마인더의 알람을 일괄 등록합니다.
  func addAllNotifications() {
    self.reminders
      .filter { $0.shouldNotify }
      .forEach { reminder in
        self.addNotification(reminder)
      }
  }
}

// MARK: - Private

private extension ReminderAlertManager {
  func addNotification(_ reminder: Reminder) {
    let content = UNMutableNotificationContent()
    content.title = "리마인더"
    content.subtitle = reminder.name
    content.body = reminder.memo
    content.sound = .default
    
    var components = Calendar.current.dateComponents(
      [.year, .month, .day, .minute],
      from: reminder.notifyDate
    )
    components.hour = Int(reminder.notifyDate.toHourString())
    print(components)
    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    let request = UNNotificationRequest(
      identifier: "\(reminder.identifier)",
      content: content,
      trigger: trigger
    )
    UNUserNotificationCenter.current().add(request) { (error) in
      if let error = error {
        print("🔕 알림 설정에 실패했습니다. 오류: \(error.localizedDescription)")
      }
    }
    os_log(.default, "🔔 알림이 등록되었습니다. \(reminder.name) \(reminder.notifyDate)")
  }
  
  /// 특정 리마인더의 알랑을 취소합니다.
  func cancelNotification(withIdentifier identifier: String) {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    os_log(.default, "🔕 알림이 취소되었습니다. \(identifier)")
  }
}
