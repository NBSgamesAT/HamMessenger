//
//  TCPStuff.swift
//  HamMessanger
//
//  Created by Nicolas Bachschwell on 10.08.19.
//  Copyright © 2019 NBSgamesAT. All rights reserved.
//

import Foundation
import SwiftSocket

class TCPStuff {
  
  //RESEIVING PART ----------------------------------------------------------------------------
  
  init(){
    
  }
  
  var bytesGot: [UInt8] = []
  var gotCompleteMessage: Bool = false
  var readingStep = 0
  
  /**
   NBS: clearBytes --------------------------------------------------------------------------------------------------------------------------------------------------------
   Clears Bytes in the array
  */
  public func clearBytes(){
    gotCompleteMessage = false
    bytesGot = []
  }
  /**
   NBS: addPart --------------------------------------------------------------------------------------------------------------------------------------------------------
   Sends a false if the Message isn't complete, otherwise, send true
  */
  public func addPart(bytes: [UInt8]) -> Bool {
    var escaping = false
    if(gotCompleteMessage){
      return true;
    }
    
    for b in bytes {
      if(gotCompleteMessage){
        return true;
      }
      bytesGot.append(b)
      if(escaping){
        escaping = false
        continue;
      }
      else if(b == 0xEB){
        escaping = true
      }
      else if(b == 0xAB){
        
        gotCompleteMessage = true
        return true
      }
    }
    return false;
  }
  
  /**
   NBS: deescape --------------------------------------------------------------------------------------------------------------------------------------------------------
   Deescapes the message
  */
  public func deescape(_ input: [UInt8]) -> [UInt8]{
    var output: [UInt8] = []
    var escaping = false
    var hasStarted = false
    for b in input {
      if(escaping && hasStarted){
        output.append(b)
        escaping = false
      }
      else if(!hasStarted && b == 0xAA){
        hasStarted = true
        print("started");
      }
      else if(hasStarted && b == 0xAB){
        return output
      }
      else if(hasStarted && b == 0xEB){
        escaping = true;
      }
      else if(hasStarted){
        output.append(b)
      }
    }
    return []
  }
  
  /**
   NBS: decodeMessage --------------------------------------------------------------------------------------------------------------------------------------------------------
   DECODES THE MESSAGE ?? UNTESTED
  */
  public func decodeMessage() -> HamMessage?{
    if(!gotCompleteMessage){
      return nil
    }
    let byteReceived = deescape(bytesGot)
    let message = HamMessage();
    var hamVersion: Int16 = 0;
    hamVersion = Int16(byteReceived[0]);
    hamVersion = hamVersion | Int16(byteReceived[1]) << 8
    if(hamVersion != 2){
      print("Version Number NOT matching!");
    }
    var seqCounter: UInt64 = 0;
    seqCounter = seqCounter | UInt64(byteReceived[2])
    seqCounter = seqCounter | UInt64(byteReceived[3]) << 8
    seqCounter = seqCounter | UInt64(byteReceived[4]) << 16
    seqCounter = seqCounter | UInt64(byteReceived[5]) << 24
    seqCounter = seqCounter | UInt64(byteReceived[6]) << 32
    seqCounter = seqCounter | UInt64(byteReceived[7]) << 40
    seqCounter = seqCounter | UInt64(byteReceived[8]) << 48
    seqCounter = seqCounter | UInt64(byteReceived[9]) << 56
    message.seqCounter = seqCounter;
    
    message.ttl = byteReceived[10]
    message.flags = byteReceived[11];
    
    message.sourceLength = Int16(byteReceived[12]) << 8
    message.sourceLength = message.sourceLength | Int16(byteReceived[13])
    var byteOffset = Int(message.sourceLength);
    if(message.sourceLength != 0){
      var source: [UInt8] = []
      for count in 14 ... Int(message.sourceLength) + 14{
        source.append(byteReceived[count])
      }
      message.source = String(bytes: source, encoding: .utf8)!
    }
    
    message.contactType = byteReceived[14 + byteOffset];
    
    message.contactLength = Int16(byteReceived[15 + byteOffset]) << 8;
    message.contactLength = message.contactLength | Int16(byteReceived[16 + byteOffset])
    print("Heeey " + String(message.contactLength))
    
    if(message.contactLength != 0){
      var source: [UInt8] = []
      for count in 17 + byteOffset ... Int(message.contactLength) + 17 + byteOffset{
        source.append(byteReceived[Int(count)])
      }
      byteOffset = byteOffset + Int(message.contactLength);
      message.contact = String(bytes: source, encoding: .utf8)!
    }
    
    message.pathLength = UInt16(byteReceived[17 + byteOffset]);
    message.pathLength = UInt16(byteReceived[18 + byteOffset]) << 8;
    
    if(message.pathLength != 0){
      var source: [UInt8] = []
      for count in 19 + byteOffset ... Int(message.pathLength) + 19 + byteOffset{
        source.append(byteReceived[Int(count)])
      }
      byteOffset = byteOffset + Int(message.pathLength);
      message.path = source;
    }
    
    message.payloadLength = Int32(byteReceived[19 + byteOffset])
    message.payloadLength = Int32(byteReceived[20 + byteOffset]) << 8;
    message.payloadLength = Int32(byteReceived[21 + byteOffset]) << 16;
    message.payloadLength = Int32(byteReceived[22 + byteOffset]) << 32;
    
    if(message.payloadLength != 0){
      var source: [UInt8] = []
      for count in 23 + byteOffset ... Int(message.payloadLength) + 23 + byteOffset{
        source.append(byteReceived[Int(count)])
      }
      byteOffset = byteOffset + Int(message.payloadLength);
      message.payload = source;
      message.payloadString = String(bytes: source, encoding: .utf8)!
    }
    
    return message
  }
  
  //SENDING PART ------------------------------------------------------------------------------
  
  /**
   NBS: sendMessage --------------------------------------------------------------------------------------------------------------------------------------------------------
   Generate and Send Message
  */
  public static func sendMessage(message m: HamMessage){
    
    if(!m.canBeSent()) {
      print("Invalid Call")
      return
    }
    
    var array: [UInt8] = []
    array.append(UInt8(hamGoVersion & 0xff))
    array.append(UInt8((hamGoVersion >> 8 ) & 0xff)) // I know it's the wrong way around but that stuff were developed by an idiot. Halfway at least.
    
    array.append(UInt8(m.seqCounter & 0xff));
    array.append(UInt8((m.seqCounter >> 8) & 0xff)); //It's just a number isn't it. Oh wait.
    array.append(UInt8((m.seqCounter >> 16) & 0xff));
    array.append(UInt8((m.seqCounter >> 24) & 0xff));
    array.append(UInt8((m.seqCounter >> 32) & 0xff));
    array.append(UInt8((m.seqCounter >> 40) & 0xff));
    array.append(UInt8((m.seqCounter >> 48) & 0xff));
    array.append(UInt8((m.seqCounter >> 56) & 0xff)); //I have to make sure this is working but it seems strange.
    
    array.append(m.ttl)
    array.append(m.flags)
    
    array.append(UInt8((m.sourceLength >> 8) & 0xff))
    array.append(UInt8(m.sourceLength & 0xff))
    
    if(m.sourceLength > 0){
      addStringByteArray(bytes: Array(m.source.utf8), array: &array)
    }
    
    array.append(m.contactType)
    
    array.append(UInt8((m.contactLength >> 8) & 0xff))
    array.append(UInt8(m.contactLength & 0xff))
    
    if(m.contactLength > 0){
      addStringByteArray(bytes: Array(m.contact.utf8), array: &array)
    }
    
    array.append(UInt8(m.pathLength & 0xff))
    array.append(UInt8((m.pathLength >> 8) & 0xff))
    
    if(m.pathLength > 0) {
      addStringByteArray(bytes: m.path, array: &array)
    }
    
    array.append(m.payloadType)
    
    array.append(UInt8(m.payloadLength & 0xff));
    array.append(UInt8((m.payloadLength >> 8) & 0xff));
    array.append(UInt8((m.payloadLength >> 16) & 0xff));
    array.append(UInt8((m.payloadLength >> 24) & 0xff));
    
    if(m.payloadLength > 0){
      addStringByteArray(bytes: m.payload, array: &array)
    }
    
    let arrayToSend = escape(input: array)
    
    print("Done")
    
    var data: Data = Data();
    data.append(contentsOf: arrayToSend)
    
    let client = TCPClient(address: "44.143.0.1", port: 9124)
    switch client.connect(timeout: 1) {
    case .success:
      switch client.send(data: data) {
      case .success:
        print("Success")
        /*let tcpManager = TCPStuff();
        guard var data2 = client.read(1024*10, timeout: 2) else { print("Whoops"); client.close(); return }
        while(!tcpManager.addPart(bytes: data2)){
          guard let data3 = client.read(1024*10, timeout: 2) else { print("Whoops"); client.close(); return }
          data2 = data3;
        }
        let message = tcpManager.decodeMessage();
        
        if(message != nil){
          print("Seq: " + String(message!.seqCounter))
          print("Source Length: " + String(message!.sourceLength))
          print("Source: " + message!.source)
          print("Contact Length: " + String(message!.contactLength))
          print("Contact: " + message!.contact)
          print("Message Length: " + String(message!.payloadLength))
          print("Message: " + message!.payloadString)
        }
        client.close()*/
      case .failure(let error):
        print(error)
        print("Failure")
      }
    case .failure(let error):
      print(error)
      print("Failure")
    }
  }
  
  /**
   NBS: addStringByteArray --------------------------------------------------------------------------------------------------------------------------------------------------------
   Adds String to Bytes
  */
  private static func addStringByteArray(bytes string: [UInt8], array: inout [UInt8]){
    for byte in string{
      array.append(byte)
    }
  }
  
  /**
   NBS: escape --------------------------------------------------------------------------------------------------------------------------------------------------------
   Escapes the message
  */
  private static func escape (input: [UInt8]) -> [UInt8]{
    var finalBytes: [UInt8] = []
    finalBytes.append(0xAA)
    for byte in input {
      if(byte == 0xAA || byte == 0xAB || byte == 0xEB){
        finalBytes.append(0xEB);
      }
      finalBytes.append(byte)
    }
    finalBytes.append(0xAB)
    return finalBytes
  }
  
}


