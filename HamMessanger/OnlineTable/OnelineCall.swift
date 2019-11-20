//
//  OnelineCall.swift
//  HamMessanger
//
//  Created by Nicolas Bachschwell on 30.10.19.
//  Copyright © 2019 NBSgamesAT. All rights reserved.
//

import Foundation
class OnlineCall {
  
  var callSign: String;
  var name: String;
  var ip: String;
  
  init(callSign: String, name: String, ip: String){
    self.callSign = callSign;
    self.name = name;
    self.ip = ip;
  }
  
}
