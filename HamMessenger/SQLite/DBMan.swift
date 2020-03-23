//
//  DBMan.swift
//  HamMessenger
//
//  Created by Nicolas Bachschwell on 22.03.20.
//  Copyright © 2020 NBSgamesAT. All rights reserved.
//

import Foundation
import SQLite

public class DBMan {
  
  
  private var db: Connection;
  public let privateMessage: PrivateMessagesDB
  
  init() throws {
    let fileLocation = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    let file = fileLocation.appendingPathComponent("chats").appendingPathExtension("sqlite3")
    db = try Connection(file.path)
    privateMessage = try PrivateMessagesDB(db: &db);
  }
  
}
