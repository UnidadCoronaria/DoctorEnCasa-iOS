//
//  AppDelegate.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin on 3/3/18.
//  Copyright © 2018 Agustin. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
       
        self.configureNotifications(application)
        
        var storyBoard : UIStoryboard
        

        //Get token
        if let _ : String = UserDefaults.standard.value(forKey: NavigationUtil.DATA.tokenKey) as? String {
            storyBoard = UIStoryboard(name: "Main", bundle: nil)
            
            if UserDefaults.standard.value(forKey: "passwordExpired") != nil {
                if (UserDefaults.standard.value(forKey: "passwordExpired") as? Bool)! {
                    storyBoard = UIStoryboard(name: "Login", bundle: nil)
                    let vc = storyBoard.instantiateViewController(withIdentifier: NavigationUtil.NAVIGATE.loginNavigation) as! UINavigationController
                    self.window?.rootViewController = vc
                    return true
                }
            }
            let vc = storyBoard.instantiateViewController(withIdentifier: NavigationUtil.NAVIGATE.main) as! UITabBarController
             self.window?.rootViewController = vc
        } else {
            storyBoard = UIStoryboard(name: "Login", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: NavigationUtil.NAVIGATE.loginNavigation) as! UINavigationController
             self.window?.rootViewController = vc
        }
      
        // Override point for customization after application launch.
        return true
    }
    
    private func configureNotifications(_ application: UIApplication){
        FirebaseApp.configure()
       
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // TODO CHEQUEAR SI LO NECESITO
        Messaging.messaging().shouldEstablishDirectChannel =  true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let viewController = sb.instantiateViewController(withIdentifier: "newCall") as! NewCallViewController
        viewController.accessToken = userInfo["token"] as! String
        viewController.roomName = userInfo["roomName"] as? String
        viewController.videocallId = userInfo["videocallId"] as? Int
        window?.rootViewController = viewController;
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        if userInfo["token"] != nil {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let viewController = sb.instantiateViewController(withIdentifier: "newCall") as! NewCallViewController
            viewController.accessToken = (userInfo["token"] as? String)!
            viewController.roomName = userInfo["roomName"] as? String
            viewController.videocallId = Int(userInfo["videocallId"] as! String)
            window?.rootViewController = viewController;
        }
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        if userInfo["token"] != nil {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let viewController = sb.instantiateViewController(withIdentifier: "newCall") as! NewCallViewController
            viewController.accessToken = (userInfo["token"] as? String)!
            viewController.roomName = userInfo["roomName"] as? String
            viewController.videocallId = Int(userInfo["videocallId"] as! String)
            window?.rootViewController = viewController;
        }
            // Print full message.
        print(userInfo)
        
        completionHandler()
    }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
    
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
        // Print full message.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let viewController = sb.instantiateViewController(withIdentifier: "newCall") as! NewCallViewController
        if let token = remoteMessage.appData["token"] as? String{
             viewController.accessToken = token
        } else {
            return
        }
        
        if let roomName = remoteMessage.appData["roomName"] as? String {
            viewController.roomName = roomName
        }
        if let videocallId = remoteMessage.appData["videocallId"] as? String {
            viewController.videocallId = Int(videocallId)
        }
        window?.rootViewController = viewController;
    }
    // [END ios_10_data_message]
}

