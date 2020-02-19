//
//  ContactTypes.swift
//  HamMessenger
//
//  Created by Nicolas Bachschwell on 17.02.20.
//  Copyright © 2020 NBSgamesAT. All rights reserved.
//

import Foundation
public enum PayloadTypes: UInt8{
  
  case CQ = 0,
  DEBUG = 1,
  PC_PRIVATE_CALL = 2,
  ACK_ACKNOLEDGE = 3,
  GC_GROUP_CHAT = 4,
  FIL_FILE = 5,
  BC_BROADCAST = 6,
  EM_EMERGENCY = 7,
  UNIDENTIFIED
  
  public func getShort() -> String{
    switch self.rawValue{
    case 0:
      return "CQ"
    case 1:
      return "DEBUG"
    case 2:
      return "PC"
    case 3:
      return "ACK"
    case 4:
      return "GC"
    case 5:
      return "FIL"
    case 6:
      return "BC"
    case 7:
      return "EM"
    default:
      return "UNIDENTIFIED"
    }
  }
  public static func getTypeById(id: UInt8) -> PayloadTypes {
    switch id {
    case 0:
      return PayloadTypes.CQ
    case 1:
      return PayloadTypes.DEBUG
    case 2:
      return PayloadTypes.PC_PRIVATE_CALL
    case 3:
      return PayloadTypes.ACK_ACKNOLEDGE
    case 4:
      return PayloadTypes.GC_GROUP_CHAT
    case 5:
      return PayloadTypes.FIL_FILE
    case 6:
      return PayloadTypes.BC_BROADCAST
    case 7:
      return PayloadTypes.EM_EMERGENCY
    default:
      return PayloadTypes.UNIDENTIFIED
    }
  }
}
