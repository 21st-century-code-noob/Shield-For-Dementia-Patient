//
//  LoginViewController.swift
//  Shield For Dementia
//
//  Created by 彭孝诚 on 2019/4/3.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var pswTF: UITextField!
    @IBOutlet weak var blurView: UIView!
    
    override func viewDidAppear(_ animated: Bool) {
        userNameTF.becomeFirstResponder()
        self.navigationController!.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.blurView.layer.cornerRadius = 20
        self.blurView.clipsToBounds = true
        logInButton.layer.cornerRadius = 10
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
