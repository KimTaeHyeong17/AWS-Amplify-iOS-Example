//
//  TodoCell.swift
//  Todo
//
//  Created by TaeHyeong Kim on 2020/09/03.
//  Copyright © 2020 TaeHyeong Kim. All rights reserved.
//

import UIKit

class TodoCell: UITableViewCell {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbPriority: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
