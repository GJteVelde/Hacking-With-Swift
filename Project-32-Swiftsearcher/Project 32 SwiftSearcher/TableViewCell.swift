//
//  TableViewCell.swift
//  Project 32 SwiftSearcher
//
//  Created by Gerjan te Velde on 27/03/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var tekstLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
