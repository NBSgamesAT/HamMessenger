//
//  ViewController.swift
//  te
//
//  Created by Nicolas Bachschwell on 06.08.19.
//  Copyright © 2019 NBSgamesAT. All rights reserved.
//

import UIKit
class ViewController: UIViewController {
  
  @IBOutlet weak var Label: UILabel!
  @IBOutlet weak var messages: UITextField!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(named: "mainBackground")
    Label.textColor = UIColor(named: "textColour")
    messages.textColor = UIColor(named: "textColour")
    // Do any additional setup after loading the view.
  }
  
  @IBAction func LogInOut(_ sender: Any) {
    HamMessage.login()
  }
  @IBAction func send(_ sender: Any) {
    let message = HamMessage(call: "OE1NBS/iOS", contactType: 0x01, contact: "ALL", payloadType: 6, payload: messages.text!);
    TCPStuff.sendMessage(message: message)
  }
  @IBAction func logout(_ sender: Any) {
    HamMessage.logout()
  }
  
}

