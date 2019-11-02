//
//  OnlineTableViewController.swift
//  HamMessanger
//
//  Created by Nicolas Bachschwell on 30.10.19.
//  Copyright © 2019 NBSgamesAT. All rights reserved.
//

import UIKit

class OnlineTableViewController: UITableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
  }

  // MARK: - Table view data source
  
  let call1 = OnlineCall(callSign: "OE1WBS", name: "Wolfgang", ip: "44.143.19.1");
  let call2 = OnlineCall(callSign: "OE1NBS/iOS", name: "Nicolas", ip: "44.143.19.1");
  let call3 = OnlineCall(callSign: "OE1XAR", name: "Bisamberg", ip: "44.143.9.50");
    
  private func createTests() -> [OnlineCall]{
    let testCalls = [call1, call2, call3];
    return testCalls;
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return createTests().count;
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "OnlineTableViewCell", for: indexPath)
    guard let actualCell = cell as? OnlineTableViewCell else {
      fatalError("Could not downgrade the cell");
    }
    let user = createTests()[indexPath.row];
    actualCell.callLabel.text = user.callSign;
    actualCell.nameLabel.text = user.name;
    actualCell.ipLabel.text = user.ip;
    

    return actualCell;
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
