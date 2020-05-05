//
//  PrivateMessageData.swift
//  HamMessenger
//
//  Created by Nicolas Bachschwell on 29.04.20.
//  Copyright © 2020 NBSgamesAT. All rights reserved.
//

import Foundation
import SQLite

public class PrivateMessageDataDB {
  
  private var dataTable = Table("messageData")
  private var callsign = Expression<String>("callsign");
  private var savedMessage = Expression<String>("message");
  private var unreadCount = Expression<Int64>("unread_count");
  
  private var db: Connection
  
  init(db: inout Connection) throws{
    self.db = db
    try self.db.run(dataTable.create(ifNotExists: true){ t in
      t.column(callsign, primaryKey: true)
      t.column(savedMessage)
      t.column(unreadCount)
    })
  }
  
  func getUnreadCount(forCallSign callsign: String) -> Int64? {
    do{
      let count = Array(try self.db.prepare(dataTable.select(self.unreadCount)
        .filter(self.callsign == callsign)))
      if count.count == 0{
        return nil
      }
      else{
        let unreadMessages = try count[0].get(unreadCount)
        return unreadMessages == 0 ? nil : unreadMessages
      }
    }
    catch{
      return nil
    }
  }
  func getSavedMessage(forCallSign callsign: String) -> String?{
    do{
      let count = Array(try self.db.prepare(dataTable.select(self.savedMessage)
        .filter(self.callsign == callsign)))
      if count.count == 0{
        return nil
      }
      else{
        let unreadMessages = try count[0].get(savedMessage)
        return unreadMessages == "" ? nil : unreadMessages
      }
    }
    catch{
      return nil
    }
  }
  
  /**
   Increases the counter for unread by one or sets 1 if there is no record.
   Returns: true if successfull, false if not
   */
  func increaseUnreadCount(forCallSign callsign: String) -> Bool{
    do{
      let count = try self.db.pluck(self.dataTable.select(self.unreadCount)
        .filter(self.callsign == callsign))
      if count == nil {
        try self.db.run(self.dataTable.insert(
          self.callsign <- callsign,
          self.savedMessage <- "",
          self.unreadCount <- 1))
        return true
      }
      else{
        try self.db.run(self.dataTable.filter(self.callsign == callsign)
          .update(self.unreadCount <- (count!.get(self.unreadCount) + 1)))
        return true
      }
    }
    catch{
      return false
    }
  }
  
  func setUnreadCount(_ newCount: Int64, forCallSign callsign: String) -> Bool{
    do{
      let count = try self.db.pluck(dataTable.select(self.unreadCount)
        .filter(self.callsign == callsign))
      if count == nil{
        try self.db.run(self.dataTable.insert(
          self.callsign <- callsign,
          self.savedMessage <- "",
          self.unreadCount <- newCount))
        return true
      }
      else{
        try self.db.run(self.dataTable.filter(self.callsign == callsign)
          .update(self.unreadCount <- newCount))
        return true
      }
    }
    catch{
      return false
    }
  }
  
  func resetUnreadCount(forCallSign callsign: String) -> Bool{
    do{
      let count = try self.db.pluck(dataTable.select(self.savedMessage)
        .filter(self.callsign == callsign))
      if count != nil {
        let existingMessage = try count!.get(self.savedMessage)
        if existingMessage == "" {
          try self.db.run(self.dataTable.filter(self.callsign == callsign)
            .delete())
          return true
        }
        else{
          try self.db.run(self.dataTable.filter(self.callsign == callsign)
            .update(self.unreadCount <- 0))
          return true
        }
      }
      else{
        return true
      }
    }
    catch{
      return false
    }
  }
  
  
  /**
   Same as UnreadCount counter parts, just with savesMessage now
   */
  func setSavedMessage(_ newMessage: String, forCallSign callsign: String) -> Bool{
    do{
      let count = try self.db.pluck(dataTable.select(self.savedMessage)
        .filter(self.callsign == callsign))
      if count == nil {
        try self.db.run(self.dataTable.insert(
          self.callsign <- callsign,
          self.savedMessage <- newMessage,
          self.unreadCount <- 0))
        return true
      }
      else{
        try self.db.run(self.dataTable.filter(self.callsign == callsign)
          .update(self.savedMessage <- newMessage))
        return true
      }
    }
    catch{
      return false
    }
  }
  func reseSavedMessage(forCallSign callsign: String) -> Bool{
    do{
      let count = try self.db.pluck(dataTable.select(self.savedMessage)
        .filter(self.callsign == callsign))
      if count != nil {
        let existingMessage = try count!.get(self.savedMessage)
        if existingMessage == "" {
          try self.db.run(self.dataTable.filter(self.callsign == callsign)
            .delete())
          return true
        }
        else{
          try self.db.run(self.dataTable.filter(self.callsign == callsign)
            .update(self.savedMessage <- ""))
          return true
        }
      }
      else{
        return true
      }
    }
    catch{
      return false
    }
  }
}
