//
//  TCPControllerV2.swift
//  HamMessenger
//
//  Created by Nicolas Bachschwell on 10.09.20.
//  Copyright © 2020 NBSgamesAT. All rights reserved.
//

import Foundation
import SwiftSocket

public class TCPController {
  
  let handler: TCPEventHandler
  let ip: String
  let port: Int
  var receivingThread: Thread?
  var receiver: TCPClient?
  var shouldBeRunning: Bool
  var protocolManager: ProtocolReader?
  var onlineTimer: Timer?
  
  var confirmOnline: [HamMessage] = []
  
  let timeout = 2;
  
  init(connectTo ip: String, onPort: Int, andUseEventHandler handler: TCPEventHandler){
    self.handler = handler;
    self.ip = ip;
    self.port = onPort;
    self.shouldBeRunning = true
  }
  
  public func tcpStartMain(){
    if receivingThread != nil || receiver != nil || onlineTimer != nil{
      return
    }
    receivingThread = Thread(target: self, selector: #selector(runningThread), object: nil)
    receivingThread!.start()
  }
  
  
  @objc private func runningThread(){
    receiver = TCPClient(address: ip, port: Int32(port))
    self.handler.onConnecting()
    switch self.receiver!.connect(timeout: timeout) {
      case .success:
        protocolManager = ProtocolReader()
        self.handler.onConnect()
        
        DispatchQueue.main.async{
          self.onlineTimer = Timer.scheduledTimer(timeInterval: 59, target: self, selector: #selector(self.sendOnlineMessage), userInfo: nil, repeats: true)
          //print(self.onlineTimer?.fireDate)
          self.onlineTimer?.fire()
        }
        
        while self.shouldBeRunning{
          
          let result = self.receiver?.read(1024*10, timeout: 1)
          if(result == nil && !self.shouldBeRunning){
            receivingThread?.cancel()
            break
          }
          else if result == nil {
            protocolManager!.clearBytes()
            continue;
          }
          if((protocolManager!.addPart(bytes: result!))){
            let message = protocolManager!.bytesToHamMessage()
            protocolManager!.clearBytes()
            if(message != nil){
              DispatchQueue.main.async{
                self.handler.onReceive(message!)
              }
              self.confirmOnline.removeAll{(testOn) -> Bool in
                return testOn.seqCounter == message!.seqCounter
              }
            }
          }
        }
      case .failure:
        handler.onConnectionRefused(address: ip, port: Int32(port))
        self.shouldBeRunning = false
    }
  }
  
  @objc private func sendOnlineMessage(){
    let message = self.handler.generateOnlineMessage()
    self.sendMessage(message, asOnlineCall: true)
  }
  
  public func sendMessage(_ message: HamMessage){
    self.sendMessage(message, asOnlineCall: false)
  }
  
  private func closeConnection(wanted: Bool, withOfflineMessage: Bool){
    if withOfflineMessage && wanted {
      self.sendMessage(handler.generateOfflineMessage())
    }
    
    self.receivingThread?.cancel()
    self.shouldBeRunning = false
    self.receiver?.close()
    self.onlineTimer?.invalidate()
    
    if wanted {
      self.handler.onConnectionClosed()
    }
    else{
      self.handler.onConnectionLost()
    }
  }
  
  private func sendMessage(_ message: HamMessage, asOnlineCall isOnlineCall: Bool){
    
    switch self.receiver!.send(data: protocolManager!.hamMessageToBytes(m: message)){
      case .success:
        if isOnlineCall {
          self.confirmOnline.append(message)
          Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (timer) in
            if self.confirmOnline.filter({ (seq) -> Bool in
              return message.seqCounter == seq.seqCounter
            }).count != 0 {
              self.closeConnection(wanted: false, withOfflineMessage: false)
            }
          })
        }
      case .failure:
        self.handler.messageDeliveryProblem(message)
        self.closeConnection(wanted: false, withOfflineMessage: false)
      
    }
  }
  
  public func stopTCPMain(withOfflineMessage: Bool){
    self.closeConnection(wanted: true, withOfflineMessage: withOfflineMessage)
  }
}

protocol TCPEventHandler{
  func onReceive(_ message: HamMessage)
  func onConnect()
  func onConnecting()
  func onConnectionLost()
  func onConnectionRefused(address: String, port: Int32)
  func onConnectionClosed()
  func messageDeliveryProblem(_ message: HamMessage)
  func generateOnlineMessage() -> HamMessage
  func generateOfflineMessage() -> HamMessage
}
