//
//  PrivateMessages.swift
//  HamMessenger
//
//  Created by Nicolas Bachschwell on 22.03.20.
//  Copyright © 2020 NBSgamesAT. All rights reserved.
//

import Foundation
import SQLite

public class PrivateMessagesDB{
  
  private let messageTable = Table("messages")
  private let id = Expression<Int64>("id")
  private let callSign = Expression<String>("callsign")
  private let message = Expression<String>("message")
  private let timestamp = Expression<Int64>("timestamp")
  private let isReceived = Expression<Bool>("received") // isReceived declares whenever a message was received or sent. Thus on which side it should be displayed
  
  private var db: Connection
  
  
  init(db: inout Connection) throws {
    self.db = db
    try db.run(messageTable.create(ifNotExists: true) { t in
      t.column(id, primaryKey: .autoincrement)
      t.column(callSign)
      t.column(message)
      t.column(timestamp)
      t.column(isReceived)
    })
  }
  
  public func loadMessages(callsign: String, offsetMultiplier: Int, reversed: Bool) -> [PrivateMessage]{
    do{
      print("called at offset " + String(offsetMultiplier))
      let messages = try self.db.prepare(messageTable.select(id, callSign, message, timestamp, isReceived)
           .filter(callSign == callsign)
           .order(reversed ? timestamp.asc : timestamp.desc)
           .limit(30, offset: (30 * offsetMultiplier)))
      var messageList: [PrivateMessage] = []
      for message in messages {
        let privateMessage = PrivateMessage(databaseId: message[self.id], callsign: message[self.callSign], message: message[self.message], timestamp: message[self.timestamp], isReceived: message[self.isReceived])
        messageList.append(privateMessage)
      }
      return messageList
    }
    catch {
      return []
    }
  }
  public func saveMessage(message: PrivateMessage) -> Int64?{
    do{
      let message = messageTable.insert(
        self.callSign <- message.callsign,
        self.message <- message.message,
        self.timestamp <- message.timestamp,
        self.isReceived <- message.isReceived)
      return try db.run(message)
    }
    catch {
      print("Failed to add item")
      return nil
    }
  }
  public func loadCallsWithChatlogs() -> [OnlineCall] {
    do{
      let callsList = try self.db.prepare(messageTable.select(distinct: callSign))
      var calls: [OnlineCall] = []
      for singleCall in callsList {
        let call = OnlineCall(callSign: singleCall[self.callSign])
        calls.append(call)
      }
      return calls
    }
    catch {
      return []
    }
  }
  public func deleteChatlogs(callSign: String) -> Bool{
    do{
      let deletion = messageTable.filter(self.callSign == callSign).delete();
      try db.run(deletion);
      return true;
    }
    catch {
      return false;
    }
  }
  
}
