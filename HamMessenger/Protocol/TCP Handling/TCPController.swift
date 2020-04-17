//
//  TCPController.swift
//  HamMessanger
//
//  Created by Nicolas Bachschwell on 06.11.19.
//  Copyright © 2019 NBSgamesAT. All rights reserved.
//

import Foundation
import SwiftSocket
class TCPController{
  
  public var ip: String = "";
  public var port: Int32 = -1;
  private var eventHandler: TCPEventHandler;
  public var onlineTimer: Timer?;
  public var receiver: Thread;
  public var tcpGetter: TCPClient?;
  public var giveUp: Bool = false;
  public var tcpStuff: TCPStuff;
  public var ownMessage: [UInt64]
  
  private let timeout: Int = 2
  
  init(_ ip: String, port: Int32, eventHandler: TCPEventHandler){
    self.ip = ip;
    self.port = port;
    self.eventHandler = eventHandler;
    self.receiver = Thread();
    self.giveUp = false;
    self.tcpStuff = TCPStuff();
    self.ownMessage = [];
  }
  
  @objc private func receiverMainThread(){
    //var isComplete = false;
    self.eventHandler.onConnecting()
    self.tcpGetter = TCPClient(address: self.ip, port: self.port);
    switch self.tcpGetter!.connect(timeout: timeout) {
    case .success:
      self.eventHandler.onConnect()
      DispatchQueue.main.async {
        self.onlineTimer = Timer.scheduledTimer(timeInterval: 59, target: self, selector: #selector(self.run_timer), userInfo: nil, repeats: true);
        self.run_timer()
      }
      var hasFull = true
      while(!giveUp){
        guard let data = self.tcpGetter!.read(1024*10, timeout: timeout) else{
          hasFull = true;
          tcpStuff.clearBytes();
          continue;
        };
        if(data[0] == 0xAA || !hasFull){
          hasFull = tcpStuff.addPart(bytes: data)
          if(hasFull){
            let message: HamMessage? = tcpStuff.decodeMessage()
            if(message != nil){
              if(!self.ownMessage.contains(message!.seqCounter)){
                eventHandler.onReceive(message!);
              } else {
                self.ownMessage.removeAll { (test) -> Bool in
                  print(test == message!.seqCounter ? "Message removed from run" : "")
                  return test == message!.seqCounter
                }
              }
              tcpStuff.clearBytes();
            }
          }
        }
      }
    case .failure(let error):
      print(error.localizedDescription);
      self.eventHandler.onConnectionClosed();
    }
  }
  
  @objc private func run_timer(){
    let message = HamMessage.login()
    self.sendLineStatus(message);
    self.eventHandler.onOnlineNoticeSent()
    print("NEXT CALL AT: ---------------------------------------------");
    print(self.onlineTimer!.fireDate);
    
    Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: {(timer) in
      if self.ownMessage.filter({ (seq) -> Bool in
        return message.seqCounter == seq
      }).count != 0 {
        self.giveUp = true
        self.stopListener()
        self.eventHandler.onConnectionLost()
      }
    })
  }
  
  public func activateListener(){
    self.tcpGetter = TCPClient(address: ip, port: self.port);
    self.receiver = Thread(target: self, selector: #selector(self.receiverMainThread), object: nil);
    receiver.start();
    
  }
  public func stopListener(){
    self.deactivateListener(withMessage: false)
  }
  
  private func deactivateListener(withMessage: Bool){
    self.onlineTimer?.invalidate()
    if withMessage {
      self.sendLineStatus(HamMessage.logout())
    }
    self.giveUp = true
    self.tcpGetter?.close()
    self.eventHandler.onConnectionClosed()
  }
  
  public func stopListenerWithOfflineMessage(){
    self.deactivateListener(withMessage: true)
  }
  public func sendLineStatus(_ message: HamMessage){
    switch tcpGetter?.send(data: TCPStuff.getData(message: message)!) {
    case .success:
      ownMessage.append(message.seqCounter)
      
    case .failure(let error):
      print(error);
    case.none:
      print("Won't be here");
    }
  }
  public func sendMessage(_ message: HamMessage){
    //tcpGetter?.send(data: message.getData())
    switch tcpGetter?.send(data: TCPStuff.getData(message: message)!) {
    case .success:
      //print("Successfully sent message");
      ownMessage.append(message.seqCounter)
      self.eventHandler.onReceive(message)
      
    case .failure:
      self.eventHandler.messageDeliveryProblem(message);
      giveUp = true
      self.receiver.cancel()
      print("Won't be here");
      self.eventHandler.onConnectionLost()
    case .none:
      print("")
    }
  }
}

protocol TCPEventHandler{
  func onReceive(_ message: HamMessage);
  func onConnect();
  func onConnecting();
  func onConnectionLost();
  func onConnectionClosed();
  func messageDeliveryProblem(_ message: HamMessage);
  func onOnlineNoticeSent();
}
