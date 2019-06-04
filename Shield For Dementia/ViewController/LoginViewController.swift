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
    @IBOutlet weak var loginHintLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginIndicator: UIActivityIndicatorView!
    
    override func viewDidAppear(_ animated: Bool) {
        userNameTF.becomeFirstResponder()
        self.navigationController!.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //handles UI
        self.blurView.layer.cornerRadius = 20
        self.blurView.clipsToBounds = true
        logInButton.layer.cornerRadius = 10
                self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        // Do any additional setup after loading the view.
    }
    
    //handles login button tapped behavior
    @IBAction func loginButtonPressed(_ sender: Any) {
        loginHintLabel.text = ""
        loginButton.setTitle("", for: .normal)
        loginButton.isEnabled = false
        loginIndicator.startAnimating()
        var username = userNameTF.text
        let password = pswTF.text
        if !ValidationUtils.validateUsername(username: username){
            loginHintLabel.text = "Please enter a valid username"
            self.loginButton.setTitle("Log In", for: .normal)
            self.loginButton.isEnabled = true
            self.loginIndicator.stopAnimating()
            return
        }
        else if !ValidationUtils.validatePsw(psw: password){
            loginHintLabel.text = "Please enter a valid password"
            self.loginButton.setTitle("Log In", for: .normal)
            self.loginButton.isEnabled = true
            self.loginIndicator.stopAnimating()
            return
        }
        else{
            var passwordHash = SHA1.hexString(from: password!)
            let requestURL:String! = "Replace it with your API which can check the username and password" + username! + "&password=" + passwordHash!
            let task = URLSession.shared.dataTask(with: URL(string: requestURL)!){ data, response, error in
                if error != nil{
                    print("error occured")
                    DispatchQueue.main.sync{
                        self.displayAlert(title: "Error", message: "An error occured, please try later.")
                        self.loginButton.setTitle("Log In", for: .normal)
                        self.loginButton.isEnabled = true
                        self.loginIndicator.stopAnimating()
                    }
                }
                else{
                    let resultString = String(data: data!, encoding: String.Encoding.utf8)
                    
                    var patientIDS : Int?
                    var firstName: String?
                    var lastName: String?
                    
                    if resultString != "[]"{
                        //Going to main page. Save password into userPreference
                        
                        do{
                            let json = try JSONSerialization.jsonObject(with: data!) as? [Any]
                            for item in json!{
                                if let pair = item as? [String: Any]{
                                    
                                    patientIDS = pair["ids"] as? Int
                                    username = pair["user_id"] as? String
                                    passwordHash = pair["password"] as? String
                                    firstName = pair["first_name"] as? String
                                    lastName = pair["last_name"] as? String
                                    
                                    
                                }
                            }
                        }catch{
                            
                        }
                        
                        DispatchQueue.main.sync{
                            self.loginButton.setTitle("Log In", for: .normal)
                            self.loginButton.isEnabled = true
                            self.loginIndicator.stopAnimating()
                            UserDefaults.standard.set(username, forKey: "username")
                            UserDefaults.standard.set(passwordHash, forKey: "carerPassword")
                            UserDefaults.standard.set(patientIDS, forKey: "patientIDS")
                            UserDefaults.standard.set(firstName, forKey: "firstName")
                            UserDefaults.standard.set(lastName, forKey: "lastName")
                            self.performSegue(withIdentifier: "loginSegue", sender: self)
                        }
                    }
                    else{
                        DispatchQueue.main.sync {
                            self.loginHintLabel.text = "Username or password is wrong"
                            self.loginButton.setTitle("Log In", for: .normal)
                            self.loginButton.isEnabled = true
                            self.loginIndicator.stopAnimating()
                        }
                    }
                }
            }
            task.resume()
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
    
    func displayAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message:message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true)
    }

}
