//
//  RequestTableViewCell.swift
//  Shield For Dementia Patient
//
//  Created by 彭孝诚 on 2019/4/25.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit

class RequestTableViewCell: UITableViewCell {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    var requestId: String!
    var acceptButtonAction : (() -> ())?
    var declineButtonAction : (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func acceptButtonPressed(_ sender: Any) {
        acceptButtonAction?()
    }
    
    @IBAction func declineButtonPressed(_ sender: Any) {
        declineButtonAction?()
    }

}
