//
//  SwitchTableViewCell.swift
//  intervalApp
//
//  Created by Reid Reininger on 5/3/21.
//

import UIKit

// Alerts delegate when switch has been toggled.
protocol SwitchTableViewCellDelegate {
    func switchTableViewCell(switchValueChanged: SwitchTableViewCell)
}

class SwitchTableViewCell: UITableViewCell {
    @IBOutlet weak var `switch`: UISwitch!
    @IBOutlet weak var label: UILabel!
    var delegate: SwitchTableViewCellDelegate?
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        delegate?.switchTableViewCell(switchValueChanged: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        `switch`.isUserInteractionEnabled = false
        `switch`.isOn = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
