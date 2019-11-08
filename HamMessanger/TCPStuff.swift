//
//  TCPStuff.swift
//  HamMessanger
//
//  Created by Nicolas Bachschwell on 10.08.19.
//  Copyright © 2019 NBSgamesAT. All rights reserved.
//

import Foundation
import SwiftSocket

extension Collection where Indices.Iterator.Element == Index {
  subscript (safe index: Index) -> Iterator.Element?  {
    return indices.contains(index) ? self[index] : nil;
  }
}

class TCPStuff {
  
  //RESEIVING PART ----------------------------------------------------------------------------
  
  init(){
    
  }
  
  var bytesGot: [UInt8] = []
  var gotCompleteMessage: Bool = false
  
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
    var byteReceived = deescape(bytesGot)
    do{
      let message = HamMessage();
      var hamVersion: Int16 = 0;
      hamVersion = try Int16(getUint8FromArray(&byteReceived, index: 0));
      hamVersion = try hamVersion | Int16(getUint8FromArray(&byteReceived, index: 1)) << 8
      if(hamVersion != 2){
        print("Version Number NOT matching!");
        return nil;
      }
      var seqCounter: UInt64 = 0;
      seqCounter = try seqCounter | UInt64(getUint8FromArray(&byteReceived, index: 2))
      seqCounter = try seqCounter | UInt64(getUint8FromArray(&byteReceived, index: 3)) << 8
      seqCounter = try seqCounter | UInt64(getUint8FromArray(&byteReceived, index: 4)) << 16
      seqCounter = try seqCounter | UInt64(getUint8FromArray(&byteReceived, index: 5)) << 24
      seqCounter = try seqCounter | UInt64(getUint8FromArray(&byteReceived, index: 6)) << 32
      seqCounter = try seqCounter | UInt64(getUint8FromArray(&byteReceived, index: 7)) << 40
      seqCounter = try seqCounter | UInt64(getUint8FromArray(&byteReceived, index: 8)) << 48
      seqCounter = try seqCounter | UInt64(getUint8FromArray(&byteReceived, index: 9)) << 56
      message.seqCounter = seqCounter;
      
      message.ttl = try getUint8FromArray(&byteReceived, index: 10)
      message.flags = try getUint8FromArray(&byteReceived, index: 11)
      
      message.sourceLength = try Int16(getUint8FromArray(&byteReceived, index: 12)) << 8
      message.sourceLength = try message.sourceLength | Int16(getUint8FromArray(&byteReceived, index: 13))
      var byteOffset = Int(message.sourceLength);
      if(message.sourceLength > 0){
        var source: [UInt8] = []
        for count in 14 ... Int(message.sourceLength) + 13{
          try source.append(getUint8FromArray(&byteReceived, index: count));
          print(source);
        }
        message.source = String(bytes: source, encoding: .utf8)!
      }
      
      message.contactType = try getUint8FromArray(&byteReceived, index: 14 + byteOffset);
      
      message.contactLength = try Int16(getUint8FromArray(&byteReceived, index: 15 + byteOffset)) << 8;
      message.contactLength = try message.contactLength | Int16(getUint8FromArray(&byteReceived, index: 16 + byteOffset))
      
      if(message.contactLength > 0){
        var source: [UInt8] = []
        for count in 17 + byteOffset ... Int(message.contactLength) + 16 + byteOffset{
          try source.append(getUint8FromArray(&byteReceived, index: count))
        }
        byteOffset = byteOffset + Int(message.contactLength);
        message.contact = String(bytes: source, encoding: .utf8)!
      }
      
      message.pathLength = try UInt16(getUint8FromArray(&byteReceived, index: 17 + byteOffset));
      message.pathLength = try message.pathLength | UInt16(getUint8FromArray(&byteReceived, index: 18 + byteOffset)) << 8;
      
      if(message.pathLength > 0){
        var source: [UInt8] = []
        for count in 19 + byteOffset ... Int(message.pathLength) + 18 + byteOffset{
          try source.append(getUint8FromArray(&byteReceived, index: count))
        }
        byteOffset = byteOffset + Int(message.pathLength);
        message.path = source;
      }
      
      message.payloadType = try getUint8FromArray(&byteReceived, index: 19 + byteOffset)
      
      message.payloadLength = try Int32(getUint8FromArray(&byteReceived, index: 20 + byteOffset))
      message.payloadLength = try message.payloadLength | Int32(getUint8FromArray(&byteReceived, index: 21 + byteOffset)) << 8;
      message.payloadLength = try message.payloadLength | Int32(getUint8FromArray(&byteReceived, index: 22 + byteOffset)) << 16;
      message.payloadLength = try message.payloadLength | Int32(getUint8FromArray(&byteReceived, index: 23 + byteOffset)) << 32;
      
      print(message.payloadLength);
      
      if(message.payloadLength > 0){
        var source: [UInt8] = []
        for count in 24 + byteOffset ... Int(message.payloadLength) + 23 + byteOffset{
          try source.append(getUint8FromArray(&byteReceived, index: count))
          try print( String(bytes: [getUint8FromArray(&byteReceived, index: count)], encoding: .utf8) ?? "s")
        }
        byteOffset = byteOffset + Int(message.payloadLength);
        message.payload = source;
        message.payloadString = String(bytes: source, encoding: .utf8)!
      }
      
      return message
    }
    catch NBSErrors.indexOutOfBonds{
      print("SHOT")
      print(bytesGot);
      return nil;
    }
    catch {
      print("I shouldn't be here");
      return nil;
    }
  }
  
  /**
   NBS: Safeget
   */
  func getUint8FromArray(_ array: inout [UInt8], index: Int) throws -> UInt8{
    if(array[safe: index] != nil){
      return array[index];
    }
    else{
      print("ELELELELE " + String(index));
      throw NBSErrors.indexOutOfBonds;
    }
  }
  
  //SENDING PART ------------------------------------------------------------------------------
  
  /**
   NBS: sendMessage --------------------------------------------------------------------------------------------------------------------------------------------------------
   Generate and Send Message
  */
  public static func getData(message m: HamMessage) -> [UInt8]?{
    
    if(!m.canBeSent()) {
      print("Invalid Call")
      return nil;
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
    
    return arrayToSend;
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


