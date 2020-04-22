//
//  ReceivedMessage.swift
//  HamMessanger
//
//  Created by Nicolas Bachschwell on 20.11.19.
//  Copyright © 2019 NBSgamesAT. All rights reserved.
//

import Foundation

class ReceivedMessage {
  var callSign: String
  var time: Date
  var label: String
  var payloadType: PayloadTypes
  var contact: String
  init(callSign: String, time: Date, label: String, payloadType: PayloadTypes, contact: String){
    self.callSign = callSign
    self.time = time;
    self.label = label;
    self.payloadType = payloadType;
    self.contact = contact
  }
  
}
