//
//  CallSettingsController.swift
//  HamMessenger
//
//  Created by Nicolas Bachschwell on 10.06.20.
//  Copyright © 2020 NBSgamesAT. All rights reserved.
//

import UIKit

class CallSettingsController: UIViewController {
  
  var callSign: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = callSign!
  
  }
  
  @IBAction
  func deleteChat(_ sender: UIButton){
    let alertController = UIAlertController(title: "Are you sure?", message: "Deleting the chat log for " + callSign! + " cannot be undone!", preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil));
    alertController.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action) in
      let result = AppDelegate.getAppDelegate().idb!.privateMessage.deleteChatlogs(callSign: self.callSign!)
      SceneDelegate.privateMessageView!.messages.removeAll();
      SceneDelegate.privateMessageView!.messageTableView.reloadData()
      print(result ? "Chat log successfully deleted" : "Failed to delete chatlog");
      
    }));
    self.present(alertController, animated: true, completion: nil)
  }
}
