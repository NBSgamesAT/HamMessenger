//
//  PrivateMessageController.swift
//  HamMessenger
//
//  Created by Nicolas Bachschwell on 22.03.20.
//  Copyright © 2020 NBSgamesAT. All rights reserved.
//

import Foundation
import UIKit

public class PrivateMessageController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate{
  
  @IBOutlet weak var textFieldView: UIView!
  @IBOutlet weak var messageEnterField: UITextField!
  @IBOutlet weak var messageSendButton: UIButton!
  @IBOutlet weak var messageTableView: UITableView!
  @IBOutlet weak var navBar: UINavigationItem!
  
  var currentSelectedCall: String? = nil
  var messages: [PrivateMessage] = []
  
  public override func viewDidLoad() {
    super.viewDidLoad();
    messageEnterField.delegate = self
    messageTableView.delegate = self
    messageTableView.dataSource = self
    navBar.title = currentSelectedCall ?? "";
    
    if currentSelectedCall != nil {
      messages = AppDelegate.getAppDelegate().idb?.privateMessage.loadMessages(callsign: currentSelectedCall!, offsetMultiplier: 0) ?? []
      messages.reverse()
    }
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
    
    AppDelegate.privateMessageView = self
    
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
  }
  
  @objc func keyboardWillShow(notification: Notification){
    guard let keyboardEnd = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else{
      return
    }
    
    var newHeightTable = self.view.frame.height
    newHeightTable -= textFieldView.frame.height
    newHeightTable -= messageTableView.frame.height
    if notification.name != UIResponder.keyboardDidHideNotification {
      newHeightTable -= keyboardEnd.height
    }
    messageTableView.frame.origin.y = newHeightTable
    
    var newHeightField = self.view.frame.height
    newHeightField -= textFieldView.frame.height
    if notification.name != UIResponder.keyboardDidHideNotification {
      newHeightField -= keyboardEnd.height
    }
    textFieldView.frame.origin.y = newHeightField
  }
  
  
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }
  public func numberOfSections(in tableView: UITableView) -> Int {
    //AppDelegate.messageView = tableView;
    return 1
  }
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "privMessageId")! as! PrivateMessageTableViewCell
    let privMessage = messages[indexPath.row]
    //var size = CGSize()
    //size.width = maxSize
    
    if privMessage.isReceived {
      cell.textOtherLabel.text = privMessage.message
      cell.textOtherView.sizeToFit()
      cell.textOtherLabel.sizeToFit()
      cell.textOtherView.layer.cornerRadius = 10
      cell.textOtherView.clipsToBounds = true
      cell.textOwnView.isHidden = true
    }
    else{
      cell.textOwnLabel.text = privMessage.message
      cell.textOwnView.sizeToFit()
      cell.textOwnLabel.sizeToFit()
      cell.textOwnView.layer.cornerRadius = 10
      cell.textOwnView.clipsToBounds = true
      cell.textOtherView.isHidden = true
    }
    return cell;
  }
  
  @IBAction func onMessageSendPressed(_ sender: Any) {
    if messageEnterField.text != "" {
      let message = HamMessage(call: ProtocolSettings.getCall(), contactType: 0x01, contact: "'" + currentSelectedCall!, payloadType: PayloadTypes.PC_PRIVATE_CALL.rawValue, payload: messageEnterField.text!);
      AppDelegate.con?.sendMessage(message);
      messageEnterField.text = ""
    }
  }
  
  @IBAction func removeKeyboard(_ sender: UITapGestureRecognizer) {
    messageEnterField.resignFirstResponder()
  }
  
  
}
