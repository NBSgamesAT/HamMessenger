//
//  AppDelegate.swift
//  te
//
//  Created by Nicolas Bachschwell on 06.08.19.
//  Copyright © 2019 NBSgamesAT. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
  
  static var peopleOnline: [OnlineCall] = [];
  
  var window: UIWindow?
  
  static var con: TCPController?;
  var tableController: UITableViewController?;
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    #if targetEnvironment(macCatalyst)
      let board = UIStoryboard.init(name: "Mac", bundle: nil)
      let controller = board.instantiateInitialViewController()
      window?.rootViewController = controller;
      window?.makeKeyAndVisible()
    #endif
    let tabController = window?.rootViewController as! UITabBarController;
    tableController = (tabController.viewControllers?[0] as! UINavigationController).viewControllers[0] as? UITableViewController;
    
    
    
    self.openConnection(tableController: tableController!);
    return true
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    
    self.closeConnection();
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    self.openConnection(tableController: tableController!);
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    self.closeConnection();
  }
  
  func openConnection(tableController: UITableViewController){
    if(AppDelegate.con == nil || AppDelegate.con!.giveUp){
      AppDelegate.con = TCPController("44.143.0.1", port: 9124, eventHandler: OnlineHandler(tableController: tableController))
      AppDelegate.con?.activateListener();
    }
  }
  func closeConnection(){
    if(AppDelegate.con != nil && !AppDelegate.con!.giveUp){
      AppDelegate.con?.stopListener();
    }
  }
  
}

