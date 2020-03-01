//
//  ProtocolSettings.swift
//  HamMessenger
//
//  Created by Nicolas Bachschwell on 01.03.20.
//  Copyright © 2020 NBSgamesAT. All rights reserved.
//

import Foundation
class ProtocolSettings {
  
  static func getCall() -> String{
    return UserDefaults.standard.string(forKey: "callsign")!
  }
  static func getName() -> String{
    return UserDefaults.standard.string(forKey: "name")!
  }
  static func getLocator() -> String{
    return UserDefaults.standard.string(forKey: "locator")!
  }
  static func getLocation() -> String{
    return UserDefaults.standard.string(forKey: "location")!
  }
  static func getIP() -> String{
    return UserDefaults.standard.string(forKey: "ip")!
  }
  
}
