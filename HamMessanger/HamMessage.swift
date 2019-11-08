//
//  HamMessage.swift
//  HamMessanger
//
//  Created by Nicolas Bachschwell on 06.08.19.
//  Copyright © 2019 NBSgamesAT. All rights reserved.
//

import Foundation
import SwiftSocket

//print("Hello, World")

let hamGoVersion: Int16 = 2;

class HamMessage {
  
  public var seqCounter: UInt64
  public var ttl: UInt8 //Done
  public var flags: UInt8 //Done
  public var sourceLength: Int16 //Done
  public var source: String //Done
  public var contactType: UInt8 //Done
  public var contactLength: Int16 //Done
  public var contact: String //Done
  public var pathLength: UInt16 //Done
  public var path: [UInt8] //Done
  public var payloadType: UInt8 //Done
  //public var payloadTypeString: String //Done
  public var payloadLength: Int32 //Done
  public var payload: [UInt8] //Done
  public var payloadString: String //Done
  public var payloadText: String //Done
  private var isSendable = true;
  
  init(){
    seqCounter = 0;
    ttl = 0;
    flags = 0;
    sourceLength = 0;
    source = "";
    contactType = 0;
    contactLength = 0;
    contact = "";
    pathLength = 0;
    path = [];
    payloadType = 0;
    payloadLength = 0;
    payload = [];
    payloadString = "";
    payloadText = "";
    isSendable = false;
  }
  
  
  init(call source: String, contactType: UInt8, contact: String, payloadType: UInt8, payload: String){
    self.isSendable = true;
    
    self.seqCounter = UInt64.random(in: UInt64.min ... UInt64.max)
    self.ttl = 0xfe;
    self.flags = 0x00
    
    self.source = source;
    self.sourceLength = Int16(self.source.count)
    
    self.contactType = contactType
    self.contactLength = Int16(contact.count)
    self.contact = contact;
    
    self.pathLength = 0;
    self.path = [0x00]
    
    self.payloadType = payloadType
    if(payloadType == 0x05){
      self.payloadLength = 7
      self.payload = [0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00]
      self.payloadString = ""
    }
    else{
      self.payload = Array(payload.utf8)
      self.payloadString = payload;
      self.payloadLength = Int32(payload.count)
      self.payloadType = payloadType
    }
    self.payloadText = ""
  }
  
  init(seqCounter: UInt64, call source: String, contactType: UInt8, contact: String, payloadType: UInt8, payload: String){
    self.isSendable = false;
    
    self.seqCounter = seqCounter
    self.ttl = 0xfe;
    self.flags = 0x00
    
    self.source = source;
    self.sourceLength = Int16(self.source.count)
    
    self.contactType = contactType
    self.contactLength = Int16(contact.count)
    self.contact = contact;
    
    self.pathLength = 0;
    self.path = [0x00]
    
    self.payloadType = payloadType
    if(payloadType == 0x05){
      self.payloadLength = 7
      self.payload = [0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00]
      self.payloadString = ""
    }
    else{
      self.payload = Array(payload.utf8)
      self.payloadString = payload;
      self.payloadLength = Int32(payload.count)
      self.payloadType = payloadType
    }
    self.payloadText = ""
  }
  
  /*private func printShit (input: [UInt8]){
    for byte in input {
      //print(String(byte, radix: 16))
    }
  }*/
  
  
  
  let message: String = "Hallo, Wolfgang... Wie geht es dir"
  let call: String = "OE1NBS"
  public static func login() -> HamMessage{
    //var msg: Message = Message(source: "OE1NBS", contactType: UInt8(8), contact: "OE1KBC", payloadType: UInt8(2), payload: "Hallo OE1KBC, wie geht es dir zur Zeit?")
    let payload = "OE1NBS/iOS" + "\t" + "Wien" + "\t" + "44.0.0.0" + "\t" + "JN88EG" + "\t" + "iOS1.0";
    let message = HamMessage(call: "OE1NBS/iOS", contactType: 0x01, contact: "CQ", payloadType: 0x00, payload: payload)
    return message;
  }
  
  public static func logout() -> HamMessage{
    //var msg: Message = Message(source: "OE1NBS", contactType: UInt8(8), contact: "OE1KBC", payloadType: UInt8(2), payload: "Hallo OE1KBC, wie geht es dir zur Zeit?")
    let payload = "OE1NBS/iOS" + "\t" + "Wien" + "\t" + "44.0.0.0" + "\t" + "JN88EG" + "\t" + "CLOSE";
    let message = HamMessage(call: "OE1NBS/iOS", contactType: 0x01, contact: "CQ", payloadType: 0x00, payload: payload)
    return message;
  }
  
  public func canBeSent() -> Bool {
    return self.isSendable
  }
}
