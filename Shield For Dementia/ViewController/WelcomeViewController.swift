//
//  WelcomeViewController.swift
//  Shield For Dementia
//
//  Created by 彭孝诚 on 2019/4/3.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController!.setNavigationBarHidden(true, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        continueButton.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
