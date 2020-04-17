//
//  PrivateMessage.swift
//  HamMessenger
//
//  Created by Nicolas Bachschwell on 22.03.20.
//  Copyright © 2020 NBSgamesAT. All rights reserved.
//

import Foundation

public class PrivateMessage {
  
  var databaseId: Int64?
  var callsign: String
  var message: String
  var timestamp: Int64
  var isReceived: Bool
  
  init(databaseId: Int64, callsign: String, message: String, timestamp: Int64, isReceived: Bool){
    self.databaseId = databaseId
    self.callsign = callsign
    self.message = message
    self.timestamp = timestamp
    self.isReceived = isReceived;
  }
  
  init(callsign: String, message: String, timestamp: Int64, isReceived: Bool){
    self.callsign = callsign
    self.message = message
    self.timestamp = timestamp
    self.isReceived = isReceived;
  }
}
