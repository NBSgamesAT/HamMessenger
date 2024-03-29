//
//  MessageTableViewDelegate.swift
//  HamMessanger
//
//  Created by Nicolas Bachschwell on 20.11.19.
//  Copyright © 2019 NBSgamesAT. All rights reserved.
//

import UIKit

class MessageTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  
  @IBOutlet weak var tabBar: UITabBarItem!
  
  @IBOutlet weak var enteredMessage: UITextView!
  
  @IBAction func resignKeyboard(_ sender: UITapGestureRecognizer) {
    enteredMessage.resignFirstResponder();
  }
  
  @IBOutlet weak var buttonCQ: UIButton!
  @IBOutlet weak var buttonBC: UIButton!
  @IBOutlet weak var buttonEM: UIButton!
  @IBOutlet weak var textViewHeight: NSLayoutConstraint!
  
  static var messages: [ReceivedMessage] = []
  static var unread = 0
  
  var textViewOldHeight: CGFloat = 0
  
  override func viewDidLoad() {
    buttonCQ.layer.cornerRadius = 10;
    buttonCQ.clipsToBounds = true;
    buttonBC.layer.cornerRadius = 10;
    buttonBC.clipsToBounds = true;
    buttonEM.layer.cornerRadius = 10
    buttonEM.clipsToBounds = true
    
    self.enteredMessage.layer.borderWidth = 1
    self.enteredMessage.layer.borderColor = UIColor.systemGray.cgColor
    self.enteredMessage.layer.cornerRadius = 10
    self.enteredMessage.delegate = self
    self.textViewOldHeight = self.enteredMessage.contentSize.height
    
    super.viewDidLoad();
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    SceneDelegate.messageView = tableView
  }
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return MessageTableViewController
      .messages.count;
  }
  
  func updateTabBar(){
    DispatchQueue.main.async {
      if MessageTableViewController.unread != 0{
        self.tabBar.badgeValue = String(MessageTableViewController.unread)
      }
      else{
        self.tabBar.badgeValue = nil
      }
    }
    
  }
  
  public func numberOfSections(in tableView: UITableView) -> Int {
    //AppDelegate.messageView = tableView;
    return 1
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "tcMessageId"/*, for: indexPath*/)
    let addInfo = cell as! MessageTableViewCell;
    let message = MessageTableViewController.messages[indexPath.row];
    addInfo.callSign.text = message.callSign
    
    let formatter = DateFormatter();
    formatter.timeStyle = .medium
    addInfo.date.text = formatter.string(from: message.time)
    addInfo.contact.text = message.contact
    addInfo.label.text = message.label
    addInfo.label.sizeToFit()
    
    addInfo.callSign.textColor = getTextColorForContactType(message.payloadType)
    addInfo.date.textColor = getTextColorForContactType(message.payloadType)
    addInfo.contact.textColor = getTextColorForContactType(message.payloadType)
    addInfo.label.textColor = getTextColorForContactType(message.payloadType)
    
    addInfo.backgroundColor = getBackgroundColorForContactType(message.payloadType)
    
    return addInfo
  }
  
  @IBAction func SendCQ(_ sender: Any) {
    if(enteredMessage.text == "" || enteredMessage.text == nil) {return};
    let payload = HamMessageUtility.createCqLoginString(name: ProtocolSettings.getName(), location: ProtocolSettings.getLocation(), ip: ProtocolSettings.getIP(), qthLocator: ProtocolSettings.getLocator()) + HamMessageUtility.cqSeperator + enteredMessage.text!
    let message = try! HamMessage(source: ProtocolSettings.getCall(), contact: "CQ", path: nil, payload: payload, payloadType: PayloadTypes.CQ)
    SceneDelegate.con?.sendMessage(message);
    enteredMessage.text = "";
    self.textViewDidChange(enteredMessage)
  }
  
  @IBAction func sendBC(_ sender: Any) {
    if(enteredMessage.text == "" || enteredMessage.text == nil) {return};
    let message = try! HamMessage(source: ProtocolSettings.getCall(), contact: "ALL", path: nil, payload: enteredMessage.text!, payloadType: PayloadTypes.BC_BROADCAST)
    SceneDelegate.con?.sendMessage(message);
    enteredMessage.text = "";
    self.textViewDidChange(enteredMessage)
  }
  
  @IBAction func sendEM(_ sender: Any){
    if enteredMessage.text == "" || enteredMessage.text == nil {return}
    let message = try! HamMessage(source: ProtocolSettings.getCall(), contact: "ALL", path: nil, payload: enteredMessage.text!, payloadType: PayloadTypes.EM_EMERGENCY)
    SceneDelegate.con?.sendMessage(message);
    enteredMessage.text = ""
    self.textViewDidChange(enteredMessage)
  }
  
  
  private func getTextColorForContactType(_ contactType: PayloadTypes) -> UIColor{
    switch contactType {
    case PayloadTypes.BC_BROADCAST:
      return UIColor(named: "mBroadcast")!
    case PayloadTypes.GC_GROUP_CHAT:
      return UIColor(named: "mGroupChat")!
    case PayloadTypes.PC_PRIVATE_CALL:
      return UIColor(named: "mPrivateCall")!
    default:
      return UIColor(named: "textColour")!
    }
  }
  private func getBackgroundColorForContactType(_ contactType: PayloadTypes) -> UIColor{
    switch contactType {
    case PayloadTypes.CQ:
      return UIColor(named: "mCQBackground")!
    case PayloadTypes.EM_EMERGENCY:
      return UIColor(named: "mEMBackground")!
    default:
      return UIColor(named: "fieldColour")!
    }
  }
  
  public func textViewDidChange(_ textView: UITextView) {
    var size = textView.contentSize.height
    if size > 200 {
      size = 200
    }
    if size != self.textViewOldHeight {
      UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
        self.textViewHeight.constant = size
        self.view.layoutIfNeeded()
      }, completion: { (completion) in
        self.textViewOldHeight = size
      })
    }
  }
}

