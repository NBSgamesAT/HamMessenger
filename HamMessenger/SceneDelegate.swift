//
//  SceneDelegate.swift
//  HamMessenger
//
//  Created by Nicolas Bachschwell on 24.04.20.
//  Copyright © 2020 NBSgamesAT. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UISplitViewControllerDelegate {

  var window: UIWindow?
  
  static var messageView: UITableView?
  static var privateMessageView: PrivateMessageController?
  static var con: TCPController?
  var privateSplit: UISplitViewController?
  var tableController: UITableViewController?;
  var onlineHandler: OnlineHandler?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    
    guard let window = window else { return }
    
    AppDelegate.sceneDelegate = self
    
    if(!UserDefaults.standard.bool(forKey: "hasValues")){
      /*#if targetEnvironment(macCatalyst)
      let board = UIStoryboard.init(name: "Mac", bundle: nil)
      let controller = board.instantiateInitialViewController()
      window?.rootViewController = controller;
      window?.makeKeyAndVisible()
      #endif*/
      privateSplit = (window.rootViewController as! TabBarController).viewControllers!.first! as? UISplitViewController
      if privateSplit == nil {
        return
      }
      tableController = (privateSplit?.viewControllers.first as! UINavigationController).viewControllers.first as! OnlineTableViewController
      self.openConnection(tableController: tableController!);
      guard let navigationController = privateSplit!.viewControllers.last as? UINavigationController else { return }
      navigationController.topViewController?.navigationItem.leftBarButtonItem = privateSplit!.displayModeButtonItem
      navigationController.topViewController?.navigationItem.leftItemsSupplementBackButton = true
      privateSplit!.delegate = self
    }
    else{
      //let board = UIStoryboard.init(name: "FirstStart", bundle: nil)
      //let controller = board.instantiateInitialViewController()
      let controller = UIHostingController(rootView: FirstStartUI())
      window.rootViewController = controller;
      window.makeKeyAndVisible()
    }
    
  }

  func sceneDidDisconnect(_ scene: UIScene) {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
  }

  func sceneWillResignActive(_ scene: UIScene) {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
  }

  // MARK: - Split view

  func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
      guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
      guard let topAsDetailController = secondaryAsNavController.topViewController as? PrivateMessageController else { return false }
      if topAsDetailController.currentSelectedCall == nil || topAsDetailController.currentSelectedCall == "" {
          // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
          return true
      }
      return false
  }
  
  
  func openConnection(tableController: UITableViewController){
    if(SceneDelegate.con == nil || SceneDelegate.con!.giveUp){
      self.onlineHandler = OnlineHandler(tableController: tableController)
      SceneDelegate.con = self.createTCPController()
      SceneDelegate.con?.activateListener();
    }
  }
  func closeConnection(){
    if(SceneDelegate.con != nil && !SceneDelegate.con!.giveUp){
      SceneDelegate.con?.stopListenerWithOfflineMessage();
    }
  }
  
  func createTCPController() -> TCPController{
    let url = UserDefaults.standard.value(forKey: "server") as? String ?? "44.143.0.1"
    return TCPController(url, port: 9124, eventHandler: self.onlineHandler!)
  }

}

