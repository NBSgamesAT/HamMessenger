//
//  OnlineTableViewCellOffline.swift
//  HamMessenger
//
//  Created by Nicolas Bachschwell on 30.03.20.
//  Copyright © 2020 NBSgamesAT. All rights reserved.
//

import UIKit

class OnlineTableViewCellOffline: UITableViewCell {
  
  // Mark: Properties
  @IBOutlet weak var callLabel: UILabel!
  @IBOutlet weak var unread: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

}
