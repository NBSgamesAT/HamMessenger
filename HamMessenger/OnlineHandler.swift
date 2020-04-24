//
//  OnlineHandler.swift
//  HamMessanger
//
//  Created by Nicolas Bachschwell on 11.11.19.
//  Copyright © 2019 NBSgamesAT. All rights reserved.
//

import Foundation
import UIKit

class OnlineHandler: TCPEventHandler {
  
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
        let call = OnlineTableViewController.peopleFound.filter({ (call) -> Bool in
          return call.callSign == message.source
        })[0]
        call.isOnline = false
        call.name = ""
        call.locator = ""
        call.location = ""
        call.ip = ""
        DispatchQueue.main.async {
          (self.tableController.view as! UITableView).reloadData()
        }
      }
      else{
        if(!OnlineHandler.arrayContainInfo(array: &OnlineTableViewController.peopleFound, call: message.source)){
          OnlineTableViewController.peopleFound.append(OnlineCall(callSign: message.source, name: String(info[0]), ip: String(info[2]), locator: String(info[3]), location: String(info[1])))
          (self.tableController.view as! UITableView).reloadData()
        }
        else{
          let call = OnlineTableViewController.peopleFound.filter({ (searchCall) -> Bool in
            return searchCall.callSign == message.source
          })[0]
          call.lastOnlineMessage = Date().timeIntervalSince1970
          call.name = String(info[0])
          call.location = String(info[1])
          call.ip = String(info[2])
          call.locator = String(info[3])
          if !call.isOnline {
            call.isOnline = true
            (self.tableController.view as! UITableView).reloadData()
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
      MessageTableViewController.messages.append(ReceivedMessage(callSign: message.source, time: Date(), label: payload, payloadType: PayloadTypes.getTypeById(id: message.payloadType), contact: message.contact
      ))
      SceneDelegate.messageView?.beginUpdates()
      SceneDelegate.messageView?.insertRows(at: [IndexPath(row: MessageTableViewController.messages.count - 1, section: 0)], with: UITableView.RowAnimation.none)
      SceneDelegate.messageView?.endUpdates()
    }
    else if message.payloadType == PayloadTypes.PC_PRIVATE_CALL.rawValue && (message.contact == "'" + ProtocolSettings.getCall() || message.source == ProtocolSettings.getCall()) {
      addMessageLogic(message: message, callsign: ProtocolSettings.getCall())
    }
  }
  
  func addMessageLogic(message: HamMessage, callsign: String){
    if message.contact == "'" + callsign {
      let priv = PrivateMessage(callsign: message.source, message: message.payloadString, timestamp: Int64(NSDate().timeIntervalSince1970), isReceived: true)
      priv.databaseId = AppDelegate.getAppDelegate().idb?.privateMessage.saveMessage(message: priv)
      
      if(SceneDelegate.privateMessageView != nil && SceneDelegate.privateMessageView!.currentSelectedCall == message.source){
        addPrivateMessageToView(privateMessage: priv)
      }
    }
    else if message.source == callsign {
      var actualContact = message.contact
      actualContact.remove(at: actualContact.startIndex)
      let priv = PrivateMessage(callsign: actualContact, message: message.payloadString, timestamp: Int64(NSDate().timeIntervalSince1970), isReceived: false)
      priv.databaseId = AppDelegate.getAppDelegate().idb?.privateMessage.saveMessage(message: priv)
      if(SceneDelegate.privateMessageView != nil && SceneDelegate.privateMessageView!.currentSelectedCall == actualContact){
        addPrivateMessageToView(privateMessage: priv)
      }
    }
  }
  
  private func addPrivateMessageToView(privateMessage priv: PrivateMessage){
    SceneDelegate.privateMessageView!.messages.append(priv)
    SceneDelegate.privateMessageView!.messageTableView.beginUpdates()
    SceneDelegate.privateMessageView!.messageTableView.insertRows(at: [IndexPath(row: SceneDelegate.privateMessageView!.messages.count - 1, section: 0)], with: UITableView.RowAnimation.none)
    SceneDelegate.privateMessageView!.messageTableView.endUpdates()
  }
  
  func onConnect() {
    DispatchQueue.main.async {
      self.tableController.tableNavItem.title = "Online"
      (self.tableController.tabBarController as! TabBarController).navBar?.title = "Online"
    }
  }
  
  func onConnecting() {
    DispatchQueue.main.async {
      self.tableController.tableNavItem.title = "Connecting..."
    }
  }
  
  func onConnectionClosed() {
    DispatchQueue.main.async {
      self.tableController.tableNavItem.title = "No Connection"
    }
  }
  
  func onConnectionLost() {
    DispatchQueue.main.async {
      self.tableController.tableNavItem.title = "Connection Lost"
    }
    Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (time) in
      SceneDelegate.con = nil
      let url = UserDefaults.standard.value(forKey: "server") as? String ?? "44.143.0.1"
      SceneDelegate.con = TCPController(url, port: 9124, eventHandler: self)
      SceneDelegate.con?.activateListener()
    })
  }
  
  func messageDeliveryProblem(_ message: HamMessage) {
    print("Message with the ID " + String(message.seqCounter) + " couldn't be delivered")
  }
  
  func onOnlineNoticeSent() {
    for call in OnlineTableViewController.peopleFound {
      if call.isOnline {
        if call.lastOnlineMessage + 118 < Date().timeIntervalSince1970 {
          call.name = ""
          call.isOnline = false
          call.location = ""
          call.locator = ""
          call.ip = ""
        }
      }
    }
    DispatchQueue.main.async {
      (self.tableController.view as! UITableView).reloadData()
    }
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
