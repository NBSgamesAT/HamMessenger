//
//  CreditsController.swift
//  HamMessenger
//
//  Created by Nicolas Bachschwell on 24.03.21.
//  Copyright © 2021 NBSgamesAT. All rights reserved.
//

import UIKit

class CreditsController: UIViewController {

  @IBOutlet weak var normalLabel: UILabel!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    var text = normalLabel.text!
    let shortVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    let bundleVersionString = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
    text.append("\nVersion: " + shortVersionString)
    text.append("\nBundle Version: " + bundleVersionString)
    normalLabel.text = text
  }

}
