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
  public var ownMessage: [UInt64];
  
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
      
      while(!giveUp){
        guard let data = self.tcpGetter!.read(1024*10, timeout: timeout) else{
          //isComplete = false;
          tcpStuff.clearBytes();
          continue;
        };
        if(data[0] == 0xAA){
          //print(data);
          
          if(tcpStuff.addPart(bytes: data)){
            let message: HamMessage? = tcpStuff.decodeMessage()
            if(message != nil){
              if(!self.ownMessage.contains(message!.seqCounter)){
                self.ownMessage.removeAll { (testNumber: UInt64) -> Bool in
                  return testNumber == message!.seqCounter;
                }
                eventHandler.onReceive(message!);
              }
              tcpStuff.clearBytes();
            }
          }
        }
      }
    case .failure(let error):
      print(error.localizedDescription);
      self.eventHandler.onConnectionLost();
    }
  }
  
  @objc private func run_timer(){
    self.sendLineStatus(HamMessage.login());
    self.eventHandler.onOnlineNoticeSent()
    print("NEXT CALL AT: ---------------------------------------------");
    print(self.onlineTimer!.fireDate);
  }
  
  public func activateListener(){
    self.tcpGetter = TCPClient(address: ip, port: self.port);
    self.receiver = Thread(target: self, selector: #selector(self.receiverMainThread), object: nil);
    receiver.start();
    
  }
  public func stopListener(){
    self.onlineTimer?.invalidate()
    self.sendLineStatus(HamMessage.logout());
    self.tcpGetter?.close();
    self.giveUp = true;
    self.receiver.cancel();
    print("Stopped");
  }
  public func sendLineStatus(_ message: HamMessage){
    //tcpGetter?.send(data: message.getData())
    switch tcpGetter?.send(data: TCPStuff.getData(message: message)!) {
    case .success:
      //print("Successfully sent message");
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
      
    case .failure(let error):
      self.eventHandler.messageDeliveryProblem(message);
      print(error);
    case .none:
      print("Won't be here");
    }
  }
}

protocol TCPEventHandler{
  func onReceive(_ message: HamMessage);
  func onConnect();
  func onConnecting();
  func onConnectionLost();
  func messageDeliveryProblem(_ message: HamMessage);
  func onOnlineNoticeSent();
}
