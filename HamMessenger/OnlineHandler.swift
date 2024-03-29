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
    if(message.contact == "CQ" && message.payload.split(separator: "\t").count == 5){
      //print("HA")
      let info = message.payload.split(separator: "\t");
      if(info[4] == "CLOSE"){
        let call = OnlineTableViewController.peopleFound.filter({ (call) -> Bool in
          return call.callSign == message.source
        }).first
        if call != nil {
          call!.isOnline = false
          call!.name = ""
          call!.locator = ""
          call!.location = ""
          call!.ip = ""
          call!.version = ""
        }
        else {
          OnlineTableViewController.peopleFound.append(OnlineCall(callSign: message.source));
        }
        DispatchQueue.main.async {
          (self.tableController.view as! UITableView).reloadData()
        }
      }
      else{
        if(!OnlineHandler.arrayContainInfo(array: &OnlineTableViewController.peopleFound, call: message.source)){
          OnlineTableViewController.peopleFound.append(OnlineCall(callSign: message.source, name: String(info[0]), ip: String(info[2]), locator: String(info[3]), location: String(info[1]), version: String(info[4])))
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
          call.version = String(info[4])
          if !call.isOnline {
            call.isOnline = true
            (self.tableController.view as! UITableView).reloadData()
          }
        }
      }
    }
    else if(message.payloadType != PayloadTypes.PC_PRIVATE_CALL.rawValue){
      
      var payload = message.payload;
      if(message.contact == "CQ"){
        let info = payload.split(separator: "\t");
        if info.count != 6{
          print(payload)
          return
        }
        payload = String(info[5]);
      }
      MessageTableViewController.messages.append(ReceivedMessage(callSign: message.source, time: Date(), label: payload, payloadType: PayloadTypes.getTypeById(id: message.payloadType), contact: message.contact
      ))
      SceneDelegate.messageView?.beginUpdates()
      SceneDelegate.messageView?.insertRows(at: [IndexPath(row: MessageTableViewController.messages.count - 1, section: 0)], with: UITableView.RowAnimation.none)
      SceneDelegate.messageView?.endUpdates()
      AppDelegate.sceneDelegate!.tabBarController!.increaseSendBadge()
    }
    else if message.payloadType == PayloadTypes.PC_PRIVATE_CALL.rawValue && (message.contact == "'" + ProtocolSettings.getCall() || message.source == ProtocolSettings.getCall()) {
      addMessageLogic(message: message, callsign: ProtocolSettings.getCall())
    }
  }
  
  func addMessageLogic(message: HamMessage, callsign: String){
    if message.contact == "'" + callsign {
      let priv = PrivateMessage(callsign: message.source, message: message.payload, timestamp: Int64(NSDate().timeIntervalSince1970), isReceived: true)
      priv.databaseId = AppDelegate.getAppDelegate().idb?.privateMessage.saveMessage(message: priv)
      
      if (SceneDelegate.privateMessageView != nil && SceneDelegate.privateMessageView!.currentSelectedCall == message.source) && isPrivateMessageControllerVisible() {
        addPrivateMessageToView(privateMessage: priv)
      }
      else {
        _ = AppDelegate.getAppDelegate().idb?.privateMessageData
          .increaseUnreadCount(forCallSign: message.source)
        tableController.tableView.reloadData()
      }
    }
    else if message.source == callsign {
      var actualContact = message.contact
      actualContact.remove(at: actualContact.startIndex)
      let priv = PrivateMessage(callsign: actualContact, message: message.payload, timestamp: Int64(NSDate().timeIntervalSince1970), isReceived: false)
      priv.databaseId = AppDelegate.getAppDelegate().idb?.privateMessage.saveMessage(message: priv)
      if(SceneDelegate.privateMessageView != nil && SceneDelegate.privateMessageView!.currentSelectedCall == actualContact){
        addPrivateMessageToView(privateMessage: priv)
      }
    }
  }
  
  private func isPrivateMessageControllerVisible () -> Bool {
    if AppDelegate.sceneDelegate!.privateSplit!.viewControllers.count == 1 && AppDelegate.sceneDelegate!.privateSplit!.isCollapsed{
      let preNav = AppDelegate.sceneDelegate?.privateSplit!.viewControllers.first! as! UINavigationController
      return preNav.visibleViewController! is PrivateMessageController
    }
    return true
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
    }
  }
  
  func onConnecting() {
    DispatchQueue.main.async {
      self.tableController.tableNavItem.title = "Connecting..."
    }
  }
  
  func onConnectionRefused(address: String, port: Int32) {
    DispatchQueue.main.async {
      self.tableController.tableNavItem.title = "Connection Refused"
    }
  }
  
  func onConnectionClosed() {
    DispatchQueue.main.async {
      self.tableController.tableNavItem.title = "No Connection"
    }
  }
  var firstConnect = true
  func onConnectionLost() {
    DispatchQueue.main.async {
      self.tableController.tableNavItem.title = "Connection Lost "
    }
    if firstConnect {
      firstConnect = false
      Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (time) in
        SceneDelegate.con = nil
        SceneDelegate.con = AppDelegate.sceneDelegate?.createTCPController()
        SceneDelegate.con?.tcpStartMain()
      })
    }
  }
  
  func messageDeliveryProblem(_ message: HamMessage) {
    print("Message with ID: " + String(message.seqCounter) + " could not be sent")
  }
  
  func removeInactivePeople() {
    for call in OnlineTableViewController.peopleFound {
      if call.isOnline {
        if call.lastOnlineMessage + 117 < Date().timeIntervalSince1970 {
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
  
  func generateOnlineMessage() -> HamMessage {
    
    let payload = HamMessageUtility.createCqLoginString(name: ProtocolSettings.getName(), location: ProtocolSettings.getLocation(), ip: ProtocolSettings.getIP(), qthLocator: ProtocolSettings.getLocator())
    
    let message = try? HamMessage(source: ProtocolSettings.getCall(), contact: "CQ", path: nil, payload: payload, payloadType: PayloadTypes.CQ)
    
    self.removeInactivePeople()
    
    return message!
  }
  
  func generateOfflineMessage() -> HamMessage {
    
    let payload = HamMessageUtility.createCqLogoutString(name: ProtocolSettings.getName(), location: ProtocolSettings.getLocation(), ip: ProtocolSettings.getIP(), qthLocator: ProtocolSettings.getLocator())
    
    let message = try? HamMessage(source: ProtocolSettings.getCall(), contact: "CQ", path: nil, payload: payload, payloadType: PayloadTypes.CQ)
    
    return message!
  }
  
  
}
