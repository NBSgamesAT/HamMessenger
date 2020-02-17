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
  
  @IBAction func sendBC(_ sender: Any) {
    if(enteredMessage.text == "" || enteredMessage.text == nil) {return};
    let message = HamMessage(call: "OE1NBS/iOS", contactType: 0x01, contact: "ALL", payloadType: 0x06, payload: enteredMessage.text!);
    AppDelegate.con?.sendMessage(message);
    enteredMessage.text = "";
  }
  @IBAction func SendCQ(_ sender: Any) {
    if(enteredMessage.text == "" || enteredMessage.text == nil) {return};
    let payload = "Nicolas" + "\t" + "Wien" + "\t" + "44.0.0.0" + "\t" + "JN88EG" + "\t" + "iOS1.0\t" + enteredMessage.text!;
    let message = HamMessage(call: "OE1NBS/iOS", contactType: 0x01, contact: "CQ", payloadType: 0x00, payload: payload);
    AppDelegate.con?.sendMessage(message);
    enteredMessage.text = "";
  }
  @IBOutlet weak var enteredMessage: UITextField!
  
  @IBAction func resignKeyboard(_ sender: UITapGestureRecognizer) {
    enteredMessage.resignFirstResponder();
  }
  
  @IBOutlet weak var buttonCQ: UIButton!
  @IBOutlet weak var buttonBC: UIButton!
  
  
  
  static var messages: [ReceivedMessage] = [];
  
  override func viewDidLoad() {
    buttonCQ.layer.cornerRadius = 10;
    buttonCQ.clipsToBounds = true;
    buttonBC.layer.cornerRadius = 10;
    buttonBC.clipsToBounds = true;
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

