//
//  AppDelegate.swift
//  Timer
//
//  Created by nuomi1 on 13/8/18.
//  Copyright © 2018年 nuomi1. All rights reserved.
//

import SVProgressHUD
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder {
    var window: UIWindow?
}

// MARK: - UIApplicationDelegate

extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        prepareSVProgressHUD()
        prepareUserNotification()
        cleanBadgeNumber()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        cleanBadgeNumber()
    }
}

// MARK: - SVProgressHUD

extension AppDelegate {
    func prepareSVProgressHUD() {
        SVProgressHUD.setMaximumDismissTimeInterval(1)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        cleanBadgeNumber()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }

    func prepareUserNotification() {
        UNUserNotificationCenter.current().delegate = self

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                debug { print(error) }
                return
            }

            if !granted {
                debug { print("禁止通知权限") }
            }
        }
    }

    func cleanBadgeNumber() {
        UIApplication.shared.applicationIconBadgeNumber = -1
    }
}
