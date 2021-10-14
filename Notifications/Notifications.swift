//
//  Notifications.swift
//  Notifications
//
//  Created by Sergey Lobanov on 15.10.2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import UIKit

class Notifications: NSObject {
    let notificationCenter = UNUserNotificationCenter.current()

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
        // для создания новой категории нужно определить уникальный идентификатор, по которой будет определяться категория действий
        let userAction = "User action"
        
        content.title = notificationType
        content.body = "This is example how to create " + notificationType
        content.sound = UNNotificationSound.default
        content.badge = 1
        // что бы включить наши дейтсвия в уведомления, надо включить нашу категорию в контент нашего уведомления.
        content.categoryIdentifier = userAction
        
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
        
        /*
         Что бы включить настраиваемые действия для пользователя уведомления, надо сначала создать и зарегистрировать категорию уведомления.
         Категория определяет тип уведомления, которая может содержать одно или несколько действий.
         Надо выполнить три основных шага:
         1. определяем действия, которые должны быть в уведомлении. Действия уведомления могут предложить разблокировать устройство, запустить приложение, выполнив какое-то действие, либо предоставить вариант с деструктивным последствием (выделено красным цветом)
        */
        // позволит пользователю отложить действие на некоторое время.
        let openAction = UNNotificationAction(identifier: "Open", title: "Open title", options: [.foreground])
        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze title", options: [])
        let deleteAction = UNNotificationAction(identifier: "Delete", title: "Delete title", options: [.destructive])
        // 2. для создания новой категории нужно определить уникальный идентификатор, по которой будет определяться категория действий. identifier: userAction
        let category = UNNotificationCategory(identifier: userAction,
                                              actions: [openAction, snoozeAction, deleteAction],
                                              intentIdentifiers: [],
                                              options: [])
        // 3. Зарегистрировать категорию в центре уведомлений.
        notificationCenter.setNotificationCategories([category])
        // что бы включить наши дейтсвия в уведомления, надо включить нашу категорию в контент нашего уведомления.
        
    }

}


extension Notifications: UNUserNotificationCenterDelegate {
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
        
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier: // срабатывает в тот момент, когда пользователь явно отклоняет уведомление
            print("Dismiss action")
        case UNNotificationDefaultActionIdentifier:
            print("Default")
        case "Snooze":
            print("Snooze")
            scheduleNotification(notificationType: "Reminder")
        case "Delete":
            print("Delete")
        case "Open":
            print("Open")
        default:
            print("Unknow action")
        }
        
        completionHandler()
    }
}

