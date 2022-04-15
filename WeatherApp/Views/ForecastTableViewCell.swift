//
//  ForecastTableViewCell.swift
//  WeatherApp
//
//  Created by Segnonna Hounsou on 13/04/2022.
//

import UIKit

class ForecastTableViewCell: UITableViewCell {
    
    @IBOutlet var icon: UIImageView!
    @IBOutlet var day: UILabel!
    @IBOutlet var temp: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
