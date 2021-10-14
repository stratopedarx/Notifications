//
//  AppDelegate.swift
//  Notifications
//
//  Created by Alexey Efimov on 21.06.2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let notificationCenter = UNUserNotificationCenter.current()  // это наш центр нотификаций.


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        requestAuthorization()
        notificationCenter.delegate = self  // delegate для протокола
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    // запрашивает у пользователя разрешение на отправку уведомлений. При каждом запуске приложения запуск происходит.
    func requestAuthorization() {
        // UNAuthorizationOptions - это сет с опциями доступными для наших уведомлений.
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("Permission granted: \(granted)")
            guard granted else { return }
            self.getNotificationSettings()
        }
    }

    // что бы отслеживать как меняет настройки пользователь
    func getNotificationSettings() {
        notificationCenter.getNotificationSettings { settings in
            print("Notification settings: \(settings)")
        }
    }

    // этот метод будет отвечать за расписание уведомлений
    func scheduleNotification(notificationType: String) {
        // создаем контент
        let content = UNMutableNotificationContent()
        content.title = notificationType
        content.body = "This is example how to create " + notificationType
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        // для каждого запрос требуется свой идентификатор
        let identifier = "Local notifications"
        
        // создаем наш запрос
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print(error)
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // если хотим получить уведомление, даже когда приложение не свернуто
    // срабатывает когда приложение открыто
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

    // если хотим что-то обрабатывать при нажатии на нотификацию
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == "Local notifications" {
            print("handling notification with Local notifications")
        }
        completionHandler()
    }
}
