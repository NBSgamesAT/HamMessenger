//
//  OnlineTableViewCell.swift
//  HamMessanger
//
//  Created by Nicolas Bachschwell on 30.10.19.
//  Copyright © 2019 NBSgamesAT. All rights reserved.
//

import UIKit

class OnlineTableViewCell: UITableViewCell {
  
  // Mark: Properties
  @IBOutlet weak var callLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var ipLabel: UILabel!
  #if targetEnvironment(macCatalyst)
  @IBOutlet weak var location: UILabel!
  @IBOutlet weak var locator: UILabel!
  #endif
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

}
