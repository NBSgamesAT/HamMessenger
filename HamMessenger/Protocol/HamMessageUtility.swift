//
//  HamMessageUtility.swift
//  HamMessenger
//
//  Created by Nicolas Bachschwell on 10.03.21.
//  Copyright © 2021 NBSgamesAT. All rights reserved.
//

import Foundation

public class HamMessageUtility{
  
  public static let cqSeperator = "\t"
  public static let pcContactPrefix = "'"
  
  public static func createCqLoginString(name: String, location: String, ip: String, qthLocator: String) -> String {
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    #if targetEnvironment(macCatalyst)
    let prefix = "macOS"
    #endif
    #if !targetEnvironment(macCatalyst)
    let prefix = "iOS"
    #endif
    
    let payload = name + cqSeperator + location + cqSeperator + ip + cqSeperator + qthLocator + cqSeperator + prefix + "_" + appVersion;
    return payload
  }
  
  public static func createCqLogoutString(name: String, location: String, ip: String, qthLocator: String) -> String {
    let payload = name + cqSeperator + location + cqSeperator + ip + cqSeperator + qthLocator + cqSeperator + "CLOSE";
    return payload;
  }
  
}
