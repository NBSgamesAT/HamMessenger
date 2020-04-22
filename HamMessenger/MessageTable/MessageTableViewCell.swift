//
//  MessageTableViewCell.swift
//  HamMessanger
//
//  Created by Nicolas Bachschwell on 20.11.19.
//  Copyright © 2019 NBSgamesAT. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
  @IBOutlet weak var callSign: UILabel!
  @IBOutlet weak var date: UILabel!
  @IBOutlet weak var label: UILabel!
  @IBOutlet weak var contact: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

}
