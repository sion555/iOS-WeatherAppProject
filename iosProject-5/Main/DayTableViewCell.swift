//
//  DayTableViewCell.swift
//  iosProject-5
//
//  Created by 조다은 on 4/12/24.
//

import UIKit

class DayTableViewCell: UITableViewCell {

    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imgWeather: UIImageView!
    
    @IBOutlet weak var lblMinTemp: UILabel!
    @IBOutlet weak var lblMaxTemp: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
