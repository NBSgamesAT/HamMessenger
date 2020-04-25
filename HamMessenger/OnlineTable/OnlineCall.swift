//
//  OnelineCall.swift
//  HamMessanger
//
//  Created by Nicolas Bachschwell on 30.10.19.
//  Copyright © 2019 NBSgamesAT. All rights reserved.
//

import Foundation
public class OnlineCall {
  
  var callSign: String;
  var name: String;
  var ip: String;
  var locator: String //The Locator of the online user
  var location: String //The Location of the online user (eg. Vienna, Berlin, even Fucking (in Austria))
  var isOnline: Bool
  var version: String
  var lastOnlineMessage: TimeInterval
  
  init(callSign: String, name: String, ip: String, locator: String, location: String, version: String){
    self.callSign = callSign;
    self.name = name;
    self.ip = ip;
    self.locator = locator;
    self.location = location;
    self.isOnline = true;
    self.lastOnlineMessage = Date().timeIntervalSince1970
    self.version = version
  }
  init(callSign: String){
    self.callSign = callSign;
    self.isOnline = false;
    self.name = "";
    self.ip = ""
    self.location = ""
    self.locator = ""
    self.lastOnlineMessage = 0
    self.version = ""
  }
  
}
