//
//  MessageTableViewDelegate.swift
//  HamMessanger
//
//  Created by Nicolas Bachschwell on 20.11.19.
//  Copyright © 2019 NBSgamesAT. All rights reserved.
//

import UIKit

class MessageTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
  
  static var messages: [ReceivedMessage] = [];
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return MessageTableView.messages.count;
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "tcMessageId", for: indexPath)
    let addInfo = cell as! MessageTableViewCell;
    addInfo.callSign.text = MessageTableView.messages[indexPath.row].callSign
    
    let formatter = DateFormatter();
    formatter.timeStyle = .medium
    addInfo.date.text = formatter.string(from: MessageTableView.messages[indexPath.row].time)
    addInfo.label.text = MessageTableView.messages[indexPath.row].label
    
    return addInfo
  }
  
}

