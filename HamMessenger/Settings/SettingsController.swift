//
//  SettingsController.swift
//  HamMessenger
//
//  Created by Nicolas Bachschwell on 29.02.20.
//  Copyright © 2020 NBSgamesAT. All rights reserved.
//

import UIKit
import Foundation

class SettingsController: UIViewController, UITextFieldDelegate {
  
  @IBOutlet weak var tfCallSign: UITextField!
  @IBOutlet weak var tfName: UITextField!
  @IBOutlet weak var tfLocator: UITextField!
  @IBOutlet weak var tfLocation: UITextField!
  @IBOutlet weak var tfIP: UITextField!
  @IBOutlet weak var btnStart: UIButton!
  @IBOutlet var mainView: UIView!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    btnStart.layer.cornerRadius = 10;
    btnStart.clipsToBounds = true;
    
    tfCallSign.delegate = self
    tfName.delegate = self
    tfLocator.delegate = self
    tfLocation.delegate = self
    tfIP.delegate = self;
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
  }
  
  var size: CGFloat = 0;
  func textFieldDidBeginEditing(_ textField: UITextField) {
    size = textField.frame.origin.y;
    print(size)
  }
  
  @objc func keyboardWillShow(notification: Notification){
    guard let keyboardEnd = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else{
      return
    }
    
    print(keyboardEnd.height)
    var moveDown = size - 200;
    if(keyboardEnd.height < moveDown){
      moveDown = keyboardEnd.height
    }
    if(notification.name != UIResponder.keyboardDidHideNotification){
      self.view.frame.origin.y = -moveDown
    }
    else{
      self.view.frame.origin.y = 0;
    }
  }
  
  @IBAction func onStartPress(_ sender: Any) {
    UserDefaults.standard.set(true, forKey: "hasValues");
    UserDefaults.standard.set(tfCallSign.text!, forKey: "callsign")
    UserDefaults.standard.set(tfName.text!, forKey: "name")
    UserDefaults.standard.set(tfLocator.text!, forKey: "locator")
    UserDefaults.standard.set(tfLocation.text!, forKey: "location")
    UserDefaults.standard.set(tfIP.text!, forKey: "ip")
    let delegate = AppDelegate.getAppDelegate()
    #if targetEnvironment(macCatalyst)
      let board = UIStoryboard.init(name: "Mac", bundle: nil)
      let controller = board.instantiateInitialViewController()
      delegate.window?.rootViewController = controller;
      delegate.window?.makeKeyAndVisible()
    #endif
    #if !targetEnvironment(macCatalyst)
      let board = UIStoryboard.init(name: "iPhone", bundle: nil)
      let controller = board.instantiateInitialViewController()
      delegate.window?.rootViewController = controller;
      delegate.window?.makeKeyAndVisible()
    #endif
    let tabController = delegate.window?.rootViewController as! UITabBarController;
    delegate.tableController = (tabController.viewControllers?[0] as! UINavigationController).viewControllers[0] as? UITableViewController;
    delegate.openConnection(tableController: delegate.tableController!);
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true;
  }
  
}
