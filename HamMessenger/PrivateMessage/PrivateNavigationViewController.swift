//
//  PrivateNavigationViewController.swift
//  HamMessenger
//
//  Created by Nicolas Bachschwell on 23.04.20.
//  Copyright © 2020 NBSgamesAT. All rights reserved.
//

import UIKit

class PrivateNavigationViewController: UINavigationController {

  override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationItem.leftBarButtonItem = AppDelegate.sceneDelegate?.privateSplit?.displayModeButtonItem
    self.navigationItem.leftItemsSupplementBackButton = true
    print("reloaded")
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
