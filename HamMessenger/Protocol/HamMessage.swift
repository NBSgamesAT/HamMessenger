//
//  HamMessageV2.swift
//  HamMessenger
//
//  Created by Nicolas Bachschwell on 16.02.21.
//  Copyright © 2021 NBSgamesAT. All rights reserved.
//

import Foundation

public class HamMessage {
  
  public var hamGoVersionNumber: UInt16 = 0
  public var seqCounter: UInt64 = 0
  public var ttl: UInt8 = 0
  public var flags: UInt8 = 0
  public var sourceLength: UInt16 = 0
  public var source: String = ""
  public var contactType: UInt8 = 0
  public var contactLength: UInt16 = 0
  public var contact: String = ""
  public var pathLength: UInt16 = 0
  public var path: [UInt8] = [0x00]
  public var payloadType: UInt8 = 0
  public var payloadLength: UInt32 = 0
  public var payloadBytes: [UInt8] = []
  public var payload: String{
    get{
      if(payloadType == PayloadTypes.FIL_FILE.rawValue){
        return ""
      }
      else {
        return String(bytes: payloadBytes, encoding: .utf8) ?? ""
      }
    }
  }
  private var isSendable = true;
  
  init(){ // Dummy Object used by the ProtocolReader
    
    self.hamGoVersionNumber = 0
    self.seqCounter = 0
    self.ttl = 0
    self.flags = 0
    self.sourceLength = 0
    self.source = ""
    self.contactType = 0
    self.contactLength = 0
    self.contact = ""
    self.pathLength = 0
    self.path = []
    self.payloadType = 0
    self.payloadLength = 0
    self.payloadBytes = []
    
    isSendable = false
    
  }
   
  init(source: String, contact: String, path: [UInt8]?, payload: String, payloadType: PayloadTypes) throws{
    self.seqCounter = UInt64.random(in: UInt64.min ... UInt64.max)
    
    try setStandardValues(source: source, contact: contact, path: path, payload: payload, payloadType: payloadType)
    
    isSendable = true
  }
  
  func setStandardValues(source: String, contact: String, path: [UInt8]?, payload: String, payloadType: PayloadTypes) throws{
    
    self.hamGoVersionNumber = 2
    self.ttl = 0xfe
    self.flags = 0x00
    
    if(source.utf8.count > UInt16.max){
      print("Source is too long");
      throw NBSErrors.hamMessageParameterTooLong
    }
    self.source = source;
    self.sourceLength = UInt16(source.utf8.count)
    
    
    if(contact.utf8.count > UInt16.max){
      print("Contact is too long")
      throw NBSErrors.hamMessageParameterTooLong
    }
    self.contact = contact
    self.contactLength = UInt16(contact.utf8.count)
    self.contactType = 0x01
    
    if((path?.count ?? 0) > UInt16.max){
      print("Path is too long")
      throw NBSErrors.hamMessageParameterTooLong
    }
    
    self.path = path ?? [0x00]
    self.pathLength = UInt16((path?.count ?? 0))
    
    if(payload.utf8.count > UInt32.max){
      print("Payload is tsoo long")
      throw NBSErrors.hamMessageParameterTooLong
    }
    if(payloadType == PayloadTypes.FIL_FILE){
      self.payloadLength = 7
    }
    else{
      self.payloadBytes = Array(payload.utf8)
      self.payloadLength = UInt32(payload.utf8.count)
      self.payloadType = payloadType.rawValue
    }
    
  }
  
  public static let payloadOnType05: [UInt8] = [0x00, 0x04, 0x00, 0x00, 0x00, 0x00]
  
}
