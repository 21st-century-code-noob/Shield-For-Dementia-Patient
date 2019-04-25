//
//  PairedViewController.swift
//  Shield For Dementia Patient
//
//  Created by Xiaocheng Peng on 24/4/19.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit

class PairedViewController: UIViewController {

    var username:String = ""
    @IBOutlet weak var statusLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        statusLabel.text = "You have been paired with " + username + ". To unpair, please use carer app."
        // Do any additional setup after loading the view.
    }
    
    //ToDo refresh pairing status

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
