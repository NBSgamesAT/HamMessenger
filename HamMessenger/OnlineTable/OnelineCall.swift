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
  #if targetEnvironment(macCatalyst)
  var locator: String //The Locator of the online user
  var location: String //The Location of the online user (eg. Vienna, Berlin, even Fucking (in Austria))
  
  init(callSign: String, name: String, ip: String, locator: String, location: String){
    self.callSign = callSign;
    self.name = name;
    self.ip = ip;
    self.locator = locator;
    self.location = location;
  }
  #endif
  
  #if !targetEnvironment(macCatalyst)
  init(callSign: String, name: String, ip: String){
    self.callSign = callSign;
    self.name = name;
    self.ip = ip;
  }
  #endif
  
}
