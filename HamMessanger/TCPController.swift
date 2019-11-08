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
  
  init(_ ip: String, port: Int32, eventHandler: TCPEventHandler){
    self.ip = ip;
    self.port = port;
    self.eventHandler = eventHandler;
    self.receiver = Thread();
    self.giveUp = false;
    self.tcpStuff = TCPStuff();
  }
  
  @objc private func receiverMainThread(){
    //var isComplete = false;
    self.tcpGetter = TCPClient(address: self.ip, port: self.port);
    switch self.tcpGetter!.connect(timeout: 2) {
    case .success:
      print("success");
      self.onlineTimer = Timer.scheduledTimer(timeInterval: 59.0, target: self, selector: #selector(self.run_timer), userInfo: nil, repeats: true);
      self.onlineTimer!.fire();
      print(self.onlineTimer!.fireDate);
      
      while(!giveUp){
        guard let data = self.tcpGetter!.read(1024*10, timeout: 2) else{
          //isComplete = false;
          tcpStuff.clearBytes();
          continue;
        };
        if(data[0] == 0xAA){
          print("Found");
          //print(data);
          
          if(tcpStuff.addPart(bytes: data)){
            let message: HamMessage? = tcpStuff.decodeMessage()
            if(message != nil){
              eventHandler.onReceive(message!);
              tcpStuff.clearBytes();
              //isComplete = false;
            }
          }
        }
        else if(data[0] == 0xaa){
          print(data);
        }
      }
    case .failure(let error):
      print("Given up");
      print(error.localizedDescription);
    }
  }
  
  @objc private func run_timer(){
    self.sendMessage(HamMessage.login());
    print("NEXT CALL AT: ");
    print(self.onlineTimer!.fireDate);
  }
  
  public func activateListener(){
    self.tcpGetter = TCPClient(address: ip, port: self.port);
    self.receiver = Thread(target: self, selector: #selector(self.receiverMainThread), object: nil);
    receiver.start();
    
  }
  public func stopListener(){
    self.onlineTimer?.invalidate()
    self.sendMessage(HamMessage.logout());
    self.tcpGetter?.close();
    self.giveUp = true;
    self.receiver.cancel();
    print("Stopped");
  }
  public func sendMessage(_ message: HamMessage){
    //tcpGetter?.send(data: message.getData())
    switch tcpGetter?.send(data: TCPStuff.getData(message: message)!) {
    case .success:
      print("Successfully sent message");
    case .failure(let error):
      print(error);
    case.none:
      print("Won't be here");
    }
  }
}

protocol TCPEventHandler{
  func onReceive(_ message: HamMessage);
}
