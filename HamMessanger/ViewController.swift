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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(named: "mainBackground")
    Label.textColor = UIColor(named: "textColour")
    // Do any additional setup after loading the view.
  }
  
  @IBAction func LogInOut(_ sender: Any) {
    HamMessage.login()
    DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { // Change `2.0` to the desired number of seconds.
      HamMessage.logout()
    }
  }
  
}

