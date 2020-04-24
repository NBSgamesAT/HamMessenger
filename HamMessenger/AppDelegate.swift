//
//  AppDelegate.swift
//  HamMessenger
//
//  Created by Nicolas Bachschwell on 24.04.20.
//  Copyright © 2020 NBSgamesAT. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var idb: DBMan?
  static var sceneDelegate: SceneDelegate?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    SettingsManager.registerSettingsBundle()
    do{
      self.idb = try DBMan();
    }
    catch {
      print("NO DATABASE AVAILABLE")
    }
    return true
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }
  
  static func getAppDelegate() -> AppDelegate{
    let delegate = UIApplication.shared.delegate as! AppDelegate
    return delegate;
  }
  func applicationDidEnterBackground(_ application: UIApplication) {
    SceneDelegate.con?.stopListenerWithOfflineMessage()
    SceneDelegate.con = nil
  }
  func applicationWillTerminate(_ application: UIApplication) {
    AppDelegate.sceneDelegate?.closeConnection()
  }
  func applicationWillEnterForeground(_ application: UIApplication) {
    SceneDelegate.con = AppDelegate.sceneDelegate!.createTCPController()
    SceneDelegate.con?.activateListener()
  }
}

