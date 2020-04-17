//
//  PrivateMessageController.swift
//  HamMessenger
//
//  Created by Nicolas Bachschwell on 22.03.20.
//  Copyright © 2020 NBSgamesAT. All rights reserved.
//

import Foundation
import UIKit

public class PrivateMessageController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate{
  
  @IBOutlet weak var textFieldView: UIView!
  @IBOutlet weak var messageEnterView: UITextView!
  @IBOutlet weak var messageSendButton: UIButton!
  @IBOutlet weak var messageTableView: UITableView!
  @IBOutlet weak var navBar: UINavigationItem!
  @IBOutlet weak var bottomContraint: NSLayoutConstraint!
  @IBOutlet weak var textViewHeight: NSLayoutConstraint!
  
  var currentSelectedCall: String? = nil
  var messages: [PrivateMessage] = []
  var offset = 0
  var stopLoading = false
  var isLoading = false
  var lastSize: CGFloat = 0
  
  public override func viewDidLoad() {
    super.viewDidLoad();
    messageEnterView.delegate = self
    messageTableView.delegate = self
    messageTableView.dataSource = self
    navBar.title = currentSelectedCall ?? "";
    offset = 0;
    lastSize = textViewHeight.constant
    if currentSelectedCall != nil {
      messages = AppDelegate.getAppDelegate().idb?.privateMessage.loadMessages(callsign: currentSelectedCall!, offsetMultiplier: 0, reversed: false) ?? []
      messages.reverse()
    }
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    
    AppDelegate.privateMessageView = self
    
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
  }
  
  @objc func keyboardWillShow(notification: Notification){
    guard let keyboardEnd = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else{
      return
    }
    var actaulKeyboard: CGFloat
    if notification.name == UIResponder.keyboardWillHideNotification {
      actaulKeyboard = 0;
    }
    else {
      actaulKeyboard = keyboardEnd.height
    }
    
    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
      self.bottomContraint.constant = actaulKeyboard
      self.view.layoutIfNeeded()
    }, completion: {(completed) in
      
    });
    self.view.layoutIfNeeded()
    
  }
  
  
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }
  public func numberOfSections(in tableView: UITableView) -> Int {
    //AppDelegate.messageView = tableView;
    return 1
  }
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let privMessage = messages[indexPath.row]
    if privMessage.isReceived {
      let cell = tableView.dequeueReusableCell(withIdentifier: "privMessageIdOther")! as! PrivateMessageTableViewCellOther
      cell.textOtherLabel.text = privMessage.message
      cell.textOtherView.layer.cornerRadius = 10
      cell.textOtherView.clipsToBounds = true
      return cell
    }
    else{
      let cell = tableView.dequeueReusableCell(withIdentifier: "privMessageIdOwn")! as! PrivateMessageTableViewCellOwn
      cell.textOwnLabel.text = privMessage.message
      cell.textOwnView.layer.cornerRadius = 10
      cell.textOwnView.clipsToBounds = true
      return cell
    }
  }
  
  @IBAction func onMessageSendPressed(_ sender: Any) {
    if messageEnterView.text != "" {
      let message = HamMessage(call: ProtocolSettings.getCall(), contactType: 0x01, contact: "'" + currentSelectedCall!, payloadType: PayloadTypes.PC_PRIVATE_CALL.rawValue, payload: messageEnterView.text!);
      AppDelegate.con?.sendMessage(message);
      messageEnterView.text = ""
      self.textViewDidChange(messageEnterView)
    }
  }
  
  @IBAction func removeKeyboard(_ sender: UITapGestureRecognizer) {
    messageEnterView.resignFirstResponder()
  }
  
  /*public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
    if self.messageTableView.contentOffset.y < -125 {
      if stopLoading {
        return
      }
      let moreMessages = AppDelegate.getAppDelegate().idb?.privateMessage.loadMessages(callsign: currentSelectedCall ?? "", offsetMultiplier: offset + 1, reversed: false) ?? []
      if moreMessages.count > 0 {
        offset += 1
        self.messages.insert(contentsOf: moreMessages, at: 0)
        self.isLoading = true
        self.messageTableView.beginUpdates()
        for count in 0 ... moreMessages.count - 1 {
          
          self.messageTableView.insertRows(at: [IndexPath.init(row: count, section: 0)], with: .none)
          //self.messageTableView.contentOffset.
          
        }
        self.messageTableView.endUpdates()
        self.isLoading = false
      }
      else{
        stopLoading = true
      }
    }
  }*/
  
  public func textViewDidChange(_ textView: UITextView) {
    var textViewSize = textView.contentSize.height
    if textViewSize > 250 {
      textViewSize = 250
    }
    if textViewSize != lastSize {
      UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
        self.textViewHeight.constant = textViewSize
        self.view.layoutIfNeeded()
      }, completion: { (completion) in
        self.lastSize = textViewSize
      })
    }
  }
}
