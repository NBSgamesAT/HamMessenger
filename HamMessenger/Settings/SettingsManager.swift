
//
//  File.swift
//  HamMessenger
//
//  Created by Nicolas Bachschwell on 29.02.20.
//  Copyright © 2020 NBSgamesAT. All rights reserved.
//

import Foundation
class SettingsManager{
  
  static func registerSettingsBundle(){
    let defaults = [String:AnyObject] ();
    UserDefaults.standard.register(defaults: defaults)
  }
  
}
