//
//  PopupViewController.swift
//  Shield For Dementia Patient
//
//  Created by apple on 9/5/19.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit

class PopupViewController: UIViewController, SBCardPopupContent {
    
    @IBOutlet weak var messageLabel: UILabel!
    var popupViewController: SBCardPopupViewController?
    var allowsTapToDismissPopupCard: Bool = true
    var allowsSwipeToDismissPopupCard: Bool = true
    
    static func create() -> UIViewController{
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
        return storyboard
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismissButton(_ sender: Any) {
        self.popupViewController?.close()
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
