//
//  OnlineSplitViewController.swift
//  HamMessenger
//
//  Created by Nicolas Bachschwell on 19.04.20.
//  Copyright © 2020 NBSgamesAT. All rights reserved.
//

import UIKit

public class PrivateSplitViewController: UISplitViewController, UISplitViewControllerDelegate {

  public override func viewDidLoad() {
    super.viewDidLoad()
    self.delegate = self
  }


  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      // Get the new view controller using segue.destination.
      // Pass the selected object to the new view controller.
  }
  */
  public func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
    guard let detailController = secondaryViewController as? PrivateMessageController else { return false }
    if detailController.currentSelectedCall == nil {
      return true
    }
    return false;
  }
}
