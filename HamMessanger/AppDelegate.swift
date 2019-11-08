//
//  AppDelegate.swift
//  te
//
//  Created by Nicolas Bachschwell on 06.08.19.
//  Copyright © 2019 NBSgamesAT. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, TCPEventHandler{
  func onReceive(_ message: HamMessage){
    print("Source: " + message.source);
    print("Contact: " + String(message.contact));
    print("MSGlen: " + String(message.payloadLength))
    print("Message: " + message.payloadString)
  }
  
  
  var window: UIWindow?
  
  static var con: TCPController?;
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    openConnection();
    return true
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    
    AppDelegate.con?.stopListener();
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    openConnection();
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    closeConnection();
  }
  
  func openConnection(){
    if(AppDelegate.con == nil || AppDelegate.con!.giveUp){
      AppDelegate.con = TCPController("44.143.0.1", port: 9124, eventHandler: self)
      AppDelegate.con?.activateListener();
    }
  }
  func closeConnection(){
    if(AppDelegate.con != nil && !AppDelegate.con!.giveUp){
      AppDelegate.con?.stopListener();
    }
  }
  
}

