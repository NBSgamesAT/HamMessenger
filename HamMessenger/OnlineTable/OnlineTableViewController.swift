//
//  OnlineTableViewController.swift
//  HamMessanger
//
//  Created by Nicolas Bachschwell on 30.10.19.
//  Copyright © 2019 NBSgamesAT. All rights reserved.
//

import UIKit

class OnlineTableViewController: UITableViewController {
  
  @IBOutlet weak var tableNavItem: UINavigationItem!
  
  static var peopleFound: [OnlineCall] = [];
  private var peopleOnline: [OnlineCall] = [];
  private var peopleOffline: [OnlineCall] = []
  
  var selectedCall: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    OnlineTableViewController.peopleFound = AppDelegate.getAppDelegate().idb?.privateMessage.loadCallsWithChatlogs() ?? []
    
  }

  // MARK: Data is from AppDelegate

  override func numberOfSections(in tableView: UITableView) -> Int {
    peopleOnline = []
    peopleOffline = []
    for call in OnlineTableViewController.peopleFound {
      if call.isOnline {
        peopleOnline.append(call)
      }
      else{
        peopleOffline.append(call)
      }
    }
    return 2
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if(section == 0){
      return self.peopleOnline.count;
    }
    else if(section == 1){
      return self.peopleOffline.count
    }
    return 0
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    
    if(indexPath.section == 0){
      let cell = tableView.dequeueReusableCell(withIdentifier: "OnlineTableViewCell", for: indexPath)
      guard let actualCell = cell as? OnlineTableViewCell else {
        fatalError("Could not downgrade the cell");
      }
      let user = peopleOnline[indexPath.row];
      actualCell.callLabel.text = user.callSign;
      actualCell.nameLabel.text = user.name;
      actualCell.ipLabel.text = user.ip;
      actualCell.location.text = user.location;
      actualCell.locator.text = user.locator;
      actualCell.version.text = user.version;
      let num = AppDelegate.getAppDelegate().idb?.privateMessageData.getUnreadCount(forCallSign: user.callSign)
      actualCell.unread.text = num != nil ? "  " + String(num!) + "  " : "";
      actualCell.contentView.sizeToFit()
      return actualCell;
    }
    else{
      let cell = tableView.dequeueReusableCell(withIdentifier: "OfflineTableViewCell", for: indexPath)
      guard let actualCell = cell as? OnlineTableViewCellOffline else {
        fatalError("Could not downgrade the cell");
      }
      let user = peopleOffline[indexPath.row];
      actualCell.callLabel.text = user.callSign;
      let num = AppDelegate.getAppDelegate().idb?.privateMessageData.getUnreadCount(forCallSign: user.callSign)
      actualCell.unread.text = num != nil ? "  " + String(num!) + "  " : "";
      actualCell.contentView.sizeToFit()
      return actualCell;
    }
  }
  
  
  /*public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
    if indexPath.section == 0{
      selectedCall = peopleOnline[indexPath.row].callSign
    }
    else if indexPath.section == 1{
      selectedCall = peopleOffline[indexPath.row].callSign
    }
    else{
      return
    }
    //self.performSegue(withIdentifier: "toPrivMessage", sender: self)
  }*/
  
  public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toPrivMessageOnline" {
      if let indexPath = tableView.indexPathForSelectedRow {
        let cont: PrivateMessageController = (segue.destination as! UINavigationController).topViewController as! PrivateMessageController
        cont.currentSelectedCall = peopleOnline[indexPath.row].callSign
        _ = AppDelegate.getAppDelegate().idb?.privateMessageData
          .resetUnreadCount(forCallSign: peopleOnline[indexPath.row].callSign)
        self.tableView.reloadData()
        cont.navigationItem.leftBarButtonItem = AppDelegate.sceneDelegate?.privateSplit?.displayModeButtonItem
        cont.navigationItem.leftItemsSupplementBackButton = true
      }
    }
    else if(segue.identifier == "toPrivMessageOffline"){
      if let indexPath = tableView.indexPathForSelectedRow {
        let cont: PrivateMessageController = (segue.destination as! UINavigationController).topViewController as! PrivateMessageController
        cont.currentSelectedCall = peopleOffline[indexPath.row].callSign
        _ = AppDelegate.getAppDelegate().idb?.privateMessageData
        .resetUnreadCount(forCallSign: peopleOffline[indexPath.row].callSign)
        self.tableView.reloadData()
        cont.navigationItem.leftBarButtonItem = AppDelegate.sceneDelegate?.privateSplit?.displayModeButtonItem
        cont.navigationItem.leftItemsSupplementBackButton = true
      }
    }
  }
  

  /*
  // Override to support conditional editing of the table view.
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
  }
  */

  /*
  // Override to support editing the table view.
override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      // Delete the row from the data source
      tableView.deleteRows(at: [indexPath], with: .fade)
    } else if editingStyle == .insert {
      // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
  }
  */

  /*
  // Override to support rearranging the table view.
  override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

  }
  */

  /*
  // Override to support conditional rearranging of the table view.
  override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
  }
  */

  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
  }
  */

}
