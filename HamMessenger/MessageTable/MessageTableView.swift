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
  
  @IBOutlet weak var tabBar: UITabBarItem!
  
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
  
  public func numberOfSections(in tableView: UITableView) -> Int {
    //AppDelegate.messageView = tableView;
    return 1
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "tcMessageId"/*, for: indexPath*/)
    let addInfo = cell as! MessageTableViewCell;
    let message = MessageTableView.messages[indexPath.row];
    addInfo.callSign.text = message.callSign
    
    let formatter = DateFormatter();
    formatter.timeStyle = .medium
    addInfo.date.text = formatter.string(from: message.time)
    addInfo.label.text = message.label
    
    addInfo.callSign.textColor = getTextColorForContactType(message.payloadType)
    addInfo.date.textColor = getTextColorForContactType(message.payloadType)
    addInfo.label.textColor = getTextColorForContactType(message.payloadType)
    
    addInfo.backgroundColor = getBackgroundColorForContactType(message.payloadType)
    
    return addInfo
  }
  
  @IBAction func SendCQ(_ sender: Any) {
    if(enteredMessage.text == "" || enteredMessage.text == nil) {return};
    let payload = HamMessage.createLoginString() + HamMessage.getInformationSeperator() + enteredMessage.text!;
    let message = HamMessage(call: "OE1NBS/iOS", contactType: 0x01, contact: "CQ", payloadType: 0x00, payload: payload);
    AppDelegate.con?.sendMessage(message);
    enteredMessage.text = "";
  }
  
  @IBAction func sendBC(_ sender: Any) {
    if(enteredMessage.text == "" || enteredMessage.text == nil) {return};
    let message = HamMessage(call: ProtocolSettings.getCall(), contactType: 0x01, contact: "ALL", payloadType: 0x06, payload: enteredMessage.text!);
    AppDelegate.con?.sendMessage(message);
    enteredMessage.text = "";
  }
  
  
  private func getTextColorForContactType(_ contactType: PayloadTypes) -> UIColor{
    switch contactType {
    case PayloadTypes.BC_BROADCAST:
      print("Broadcast")
      return UIColor(named: "mBroadcast")!
    case PayloadTypes.GC_GROUP_CHAT:
      print("Group")
      return UIColor(named: "mGroupChat")!
    case PayloadTypes.PC_PRIVATE_CALL:
      print("Private")
      return UIColor(named: "mPrivateCall")!
    default:
      print("Default")
      return UIColor(named: "textColour")!
    }
  }
  private func getBackgroundColorForContactType(_ contactType: PayloadTypes) -> UIColor{
    switch contactType {
    case PayloadTypes.CQ:
      return UIColor(named: "mCQBackground")!
    default:
      return UIColor(named: "fieldColour")!
    }
  }
}

