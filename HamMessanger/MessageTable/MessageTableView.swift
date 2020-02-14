//
//  MessageTableViewDelegate.swift
//  HamMessanger
//
//  Created by Nicolas Bachschwell on 20.11.19.
//  Copyright © 2019 NBSgamesAT. All rights reserved.
//

import UIKit

class MessageTableView: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var tableView: UITableView!
  
  @IBAction func test(_ sender: Any) {
    MessageTableView.messages.append(ReceivedMessage(callSign: "OE1NBS/test", time: Date(), label: "CQ: Wir jemand mit mir reden?"))
    DispatchQueue.main.async {
      self.tableView.beginUpdates()
      self.tableView.insertRows(at: [IndexPath(row: MessageTableView.messages.count - 1, section: 0)], with: UITableView.RowAnimation.none)
      self.tableView.endUpdates()
    }
  }
  
  
  static var messages: [ReceivedMessage] = [];
  
  override func viewDidLoad() {
    super.viewDidLoad();
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    AppDelegate.messageView = tableView;
  }
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return MessageTableView.messages.count;
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    AppDelegate.messageView = tableView;
    return 1
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "tcMessageId"/*, for: indexPath*/)
    let addInfo = cell as! MessageTableViewCell;
    addInfo.callSign.text = MessageTableView.messages[indexPath.row].callSign
    
    let formatter = DateFormatter();
    formatter.timeStyle = .medium
    addInfo.date.text = formatter.string(from: MessageTableView.messages[indexPath.row].time)
    addInfo.label.text = MessageTableView.messages[indexPath.row].label
    
    return addInfo
  }
}

