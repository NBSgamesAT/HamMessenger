//
//  OnlineHandler.swift
//  HamMessanger
//
//  Created by Nicolas Bachschwell on 11.11.19.
//  Copyright © 2019 NBSgamesAT. All rights reserved.
//

import Foundation
import UIKit

class OnlineHandler: TCPEventHandler{
  
  var tableController: OnlineTableViewController;
  
  init(tableController: UITableViewController){
    self.tableController = tableController as! OnlineTableViewController;
  }
  
  func onReceive(_ message: HamMessage){
    //print("HA")
    if(message.contact == "CQ" && message.payloadString.split(separator: "\t").count == 5){
      //print("HA")
      let info = message.payloadString.split(separator: "\t");
      if(info[4] == "CLOSE"){
        AppDelegate.peopleOnline.removeAll { (callInformation) -> Bool in
          return message.source == callInformation.callSign
        }
        DispatchQueue.main.async {
          (self.tableController.view as! UITableView).reloadData()
        }
      }
      else{
        if(!OnlineHandler.arrayContainInfo(array: &AppDelegate.peopleOnline, call: message.source)){
          DispatchQueue.main.async {
            (self.tableController.view as! UITableView).beginUpdates()
            AppDelegate.peopleOnline.append(OnlineCall(callSign: message.source, name: String(info[0]), ip: String(info[2]), locator: String(info[3]), location: String(info[1])))
            (self.tableController.view as! UITableView).insertRows(at: [IndexPath(row: AppDelegate.peopleOnline.count - 1, section: 0)], with: UITableView.RowAnimation.none)
            (self.tableController.view as! UITableView).endUpdates()
          }
        }
      }
    }
    else if(message.payloadType != PayloadTypes.PC_PRIVATE_CALL.rawValue){
      
      var payload = message.payloadString;
      if(message.contact == "CQ"){
        let info = message.payloadString.split(separator: "\t");
        payload = String(info[5]);
      }
      MessageTableView.messages.append(ReceivedMessage(callSign: message.source, time: Date(), label: payload, payloadType: PayloadTypes.getTypeById(id: message.payloadType)
      ))
      DispatchQueue.main.async {
        AppDelegate.messageView?.beginUpdates()
        AppDelegate.messageView?.insertRows(at: [IndexPath(row: MessageTableView.messages.count - 1, section: 0)], with: UITableView.RowAnimation.none)
        AppDelegate.messageView?.endUpdates()
      }
    }
    else if message.payloadType == PayloadTypes.PC_PRIVATE_CALL.rawValue && (message.contact == "'" + ProtocolSettings.getCall() || message.source == ProtocolSettings.getCall()) {
      addMessageLogic(message: message, callsign: ProtocolSettings.getCall())
    }
  }
  
  func addMessageLogic(message: HamMessage, callsign: String){
    if message.contact == "'" + callsign {
      let priv = PrivateMessage(callsign: message.source, message: message.payloadString, timestamp: Int64(NSDate().timeIntervalSince1970), isReceived: true)
      AppDelegate.getAppDelegate().idb?.privateMessage.saveMessage(message: priv)
      if(AppDelegate.privateMessageView != nil && AppDelegate.privateMessageView!.currentSelectedCall == message.source){
        addPrivateMessageToView(privateMessage: priv)
      }
    }
    else if message.source == callsign {
      var actualContact = message.contact
      actualContact.remove(at: actualContact.startIndex)
      let priv = PrivateMessage(callsign: actualContact, message: message.payloadString, timestamp: Int64(NSDate().timeIntervalSince1970), isReceived: false)
      AppDelegate.getAppDelegate().idb?.privateMessage.saveMessage(message: priv)
      if(AppDelegate.privateMessageView != nil && AppDelegate.privateMessageView!.currentSelectedCall == actualContact){
        addPrivateMessageToView(privateMessage: priv)
      }
    }
  }
  
  private func addPrivateMessageToView(privateMessage priv: PrivateMessage){
    AppDelegate.privateMessageView!.messages.append(priv)
    DispatchQueue.main.async {
      AppDelegate.privateMessageView!.messageTableView.beginUpdates()
      AppDelegate.privateMessageView!.messageTableView.insertRows(at: [IndexPath(row: AppDelegate.privateMessageView!.messages.count - 1, section: 0)], with: UITableView.RowAnimation.none)
      AppDelegate.privateMessageView!.messageTableView.endUpdates()
    }
  }
  
  func onConnect() {
    DispatchQueue.main.async {
      self.tableController.tableNavItem.title = "Online"
    }
  }
  
  func onConnecting() {
    DispatchQueue.main.async {
      self.tableController.tableNavItem.title = "Connecting..."
    }
  }
  
  func onConnectionLost() {
    DispatchQueue.main.async {
      self.tableController.tableNavItem.title = "Connection Lost"
    }
  }
  
  func messageDeliveryProblem(_ message: HamMessage) {
    print("Message with the ID " + String(message.seqCounter) + " couldn't be delivered")
  }
  
  static func arrayContainInfo(array: inout [OnlineCall], call: String) -> Bool {
    for checkfor in array {
      if checkfor.callSign == call {
        return true;
      }
    }
    return false;
  }
  
}
