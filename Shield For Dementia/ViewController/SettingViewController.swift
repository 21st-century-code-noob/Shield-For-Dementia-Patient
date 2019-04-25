//
//  SettingViewController.swift
//  Shield For Dementia Patient
//
//  Created by Xiaocheng Peng on 24/4/19.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var pairingButotn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func pairingButtonPressed(_ sender: Any) {
        CBToast.showToastAction()
        pairingButotn.isEnabled = false
        let username = UserDefaults.standard.object(forKey: "username") as? String
        if username != nil{
            let requestURL = "https://sqbk9h1frd.execute-api.us-east-2.amazonaws.com/IEProject/ieproject/carer/checkwhetherpatienthascarer?patientId=" + username!
            let task = URLSession.shared.dataTask(with: URL(string: requestURL)!){ data, response, error in
                if error != nil{
                    print("error occured")
                    self.pairingButotn.isEnabled = true
                }
                else{
                    let dataString = String(data: data!, encoding: String.Encoding.utf8)
                    DispatchQueue.main.sync{
                        if dataString != "[]"{
                            do {
                                let json = try JSONSerialization.jsonObject(with: data!) as? [Any]
                                for item in json!{
                                    if let pair = item as? [String: Any]{
                                        if pair["status"] is NSNull{
                                        }
                                        else if pair["status"] as! Int == 1{
                                            var username:String = ""
                                            username = pair["carer_id"] as! String
                                            CBToast.hiddenToastAction()
                                            self.pairingButotn.isEnabled = true
                                            self.performSegue(withIdentifier: "pairedSegue", sender: username)
                                            return
                                        }
                                    }
                                }
                            }
                                
                            catch{
                                print(error)
                            }
                        }
                        else {
                            CBToast.hiddenToastAction()
                            self.pairingButotn.isEnabled = true
                            self.performSegue(withIdentifier: "pairingSegue", sender: self)
                        }
                    }
                }
            }
            task.resume()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pairedSegue"{
            if let vc = segue.destination as? PairedViewController, let username = sender as? String {
                vc.username = username
            }
        }
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
