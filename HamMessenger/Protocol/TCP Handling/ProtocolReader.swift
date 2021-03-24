//
//  This class sends the byte-data and converts the bytes into HamMessage(s)
//  ProtocolReader.swift
//  HamMessenger
//
//  Created by Nicolas Bachschwell on 16.02.2021.
//
//  Utilized by TCPControllerV2

import Foundation

class ProtocolReader{
  
  init(){
  }
  
  private var bytesGot: [UInt8] = []
  private var gotCompleteMessage: Bool = false
  
  /**
   NBS: clearBytes --------------------------------------------------------------------------------------------------------------------------------------------------------
   Clears Bytes in the array
  */
  public func clearBytes(){
    gotCompleteMessage = false
    bytesGot = []
  }
  /**
   NBS: addPart
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
  private func deescape(_ input: [UInt8]) -> [UInt8]{
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
        //print("started");
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
  
  public func bytesToHamMessage() -> HamMessage? {
    let data = deescape(bytesGot)
    let hamMessage = HamMessage()
    var i: Int = 0 // Basically an iterator variable
    
    
    do {
      hamMessage.hamGoVersionNumber = try readUInt16(data: data, position: &i, reversed: true)
      if(hamMessage.hamGoVersionNumber == 0){
        return nil;
      }
      
      hamMessage.seqCounter = try readUInt64(data: data, position: &i, reversed: true)
      hamMessage.ttl = try readUInt8(data: data, position: &i)
      hamMessage.flags = try readUInt8(data: data, position: &i)
      hamMessage.sourceLength = try readUInt16(data: data, position: &i, reversed: false)
      hamMessage.source = try readString(data: data, position: &i, length: Int(hamMessage.sourceLength)) ?? ""
      hamMessage.contactType = try readUInt8(data: data, position: &i)
      hamMessage.contactLength = try readUInt16(data: data, position: &i, reversed: false)
      hamMessage.contact = try readString(data: data, position: &i, length: Int(hamMessage.contactLength)) ?? ""
      hamMessage.pathLength = try readUInt16(data: data, position: &i, reversed: true)
      hamMessage.path = try readBytes(data: data, position: &i, length: Int(hamMessage.pathLength))
      hamMessage.payloadType = try readUInt8(data: data, position: &i)
      hamMessage.payloadLength = try readUInt32(data: data, position: &i, reversed: true)
      hamMessage.payloadBytes = try readBytes(data: data, position: &i, length: Int(hamMessage.payloadLength))
    }
    catch {
      print(hamMessage.hamGoVersionNumber)
      print(hamMessage.seqCounter)
      print(hamMessage.ttl)
      print(hamMessage.flags)
      print(hamMessage.sourceLength)
      print(hamMessage.contactLength)
      print(hamMessage.pathLength)
      print(hamMessage.payloadType)
      print(hamMessage.payloadLength)
    }
    
    return hamMessage
  }
  
  
  public func hamMessageToBytes(m: HamMessage) -> [UInt8] {
    var outputData: [UInt8] = []
    
    outputData.append(contentsOf: byteArray(from: m.hamGoVersionNumber).reversed())
    outputData.append(contentsOf: byteArray(from: m.seqCounter).reversed())
    
    outputData.append(m.ttl)
    outputData.append(m.flags)
    
    outputData.append(contentsOf: byteArray(from: m.sourceLength))
    if m.sourceLength != 0{
      outputData.append(contentsOf: m.source.utf8)
    }
    
    outputData.append(m.contactType)
    outputData.append(contentsOf: byteArray(from: m.contactLength))
    if m.contactLength != 0 {
      outputData.append(contentsOf: m.contact.utf8)
    }
    
    outputData.append(contentsOf: byteArray(from: m.pathLength).reversed())
    if m.pathLength != 0 {
      outputData.append(contentsOf: m.path)
    }
    
    outputData.append(m.payloadType)
    outputData.append(contentsOf: byteArray(from: m.payloadLength).reversed())
    if(m.payloadType == PayloadTypes.FIL_FILE.rawValue) {outputData.append(contentsOf: HamMessage.payloadOnType05)
    }
    else{
      if m.payloadLength != 0 {
        outputData.append(contentsOf: m.payload.utf8)
      }
    }
    let finalOutput = ProtocolReader.escape(input: outputData)
    return finalOutput;
  }
  
  private func readBytes(data: [UInt8], position: inout Int, length: Int) throws -> [UInt8] {
    if position + length - 1 >= data.count{
      throw NBSErrors.indexOutOfBounds
    }
    
    if length == 0 {
      return []
    }
    let pos = position
    position += length
    return Array(data[pos...(position - 1)])
  }
  
  private func readString(data: [UInt8], position: inout Int, length: Int) throws -> String? {
    if position + length - 1 >= data.count {
      throw NBSErrors.indexOutOfBounds
    }
    
    if length == 0{
      return ""
    }
    let pos = position
    position += length
    return String(bytes: data[pos...(position - 1)], encoding: .utf8)
  }
  
  private func readUInt8(data: [UInt8], position: inout Int) throws -> UInt8{
    if position >= data.count {
      throw NBSErrors.indexOutOfBounds
    }
    
    let pos = position
    position += 1
    return data[pos]
  }
  private func readUInt16(data: [UInt8], position: inout Int, reversed: Bool) throws -> UInt16{
    if position + 1 >= data.count {
      throw NBSErrors.indexOutOfBounds
    }
    
    var subData = data[position...(position + 1)]
    position += 2
    if !reversed { subData.reverse() }
    return fromByteArray(subData, UInt16.self)
  }
  private func readUInt32(data: [UInt8], position: inout Int, reversed: Bool) throws -> UInt32{
    if position + 3 >= data.count {
      throw NBSErrors.indexOutOfBounds
    }
    
    var subData = data[position...(position + 3)]
    position += 4
    if !reversed { subData.reverse() }
    return fromByteArray(subData, UInt32.self)
  }
  private func readUInt64(data: [UInt8], position: inout Int, reversed: Bool) throws -> UInt64{
    if position + 7 >= data.count {
      throw NBSErrors.indexOutOfBounds
    }
    
    var subData = data[position...(position + 7)]
    position += 8
    if !reversed { subData.reverse() }
    return fromByteArray(subData, UInt64.self)
  }
  
  func fromByteArray<T>(_ value: ArraySlice<UInt8>, _: T.Type) -> T {
      return value.withUnsafeBufferPointer {
          $0.baseAddress!.withMemoryRebound(to: T.self, capacity: 1) {
              $0.pointee
          }
      }
  }
  
  private func byteArray<T>(from value: T) -> [UInt8] where T: FixedWidthInteger {
      withUnsafeBytes(of: value.bigEndian, Array.init)
  }
  
  private static func escape (input: [UInt8]) -> [UInt8]{ // Copied from TCPStuff
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
