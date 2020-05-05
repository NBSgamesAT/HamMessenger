//
//  OnlineSplitViewController.swift
//  HamMessenger
//
//  Created by Nicolas Bachschwell on 19.04.20.
//  Copyright © 2020 NBSgamesAT. All rights reserved.
//

import UIKit

public class TabBarController: UITabBarController, UITabBarControllerDelegate {
  
  @IBOutlet weak var navBar: UINavigationItem?

  public override func viewDidLoad() {
    super.viewDidLoad()
    self.delegate = self
  }
  
  public func setNevigationString(newText: String){
    //self.
  }
  
  public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    if viewController is MessageTableViewController {
      MessageTableViewController.unread = 0
    }
  }

  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      // Get the new view controller using segue.destination.
      // Pass the selected object to the new view controller.
  }
  */
  
}
