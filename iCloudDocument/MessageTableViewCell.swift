//
//  MessageTableViewCell.swift
//  iCloudDocument
//
//  Created by imac on 2023/3/28.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var personLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    static let identifier = "MessageTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
