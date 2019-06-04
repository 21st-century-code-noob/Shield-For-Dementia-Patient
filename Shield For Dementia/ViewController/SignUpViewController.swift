//
//  SignInViewController.swift
//  Shield For Dementia
//
//  Created by 彭孝诚 on 2019/4/3.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var pswTF: UITextField!
    @IBOutlet weak var confirmTF: UITextField!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var usernameHintLabel: UILabel!
    @IBOutlet weak var passwordHintLabel: UILabel!
    @IBOutlet weak var confirmPswHintLabel: UILabel!
    @IBOutlet weak var nameHintLabel: UILabel!
    @IBOutlet weak var signupLoadingIndicator: UIActivityIndicatorView!
    
    var availabilityChecked: Bool = false
    
    override func viewDidAppear(_ animated: Bool) {
        usernameTF.becomeFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //dismiss keyboard by tapping blank area
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        signUpButton.layer.cornerRadius = 10

        // Do any additional setup after loading the view.
    }
    
    //all below listen for textfield change, and do the validation./
    @IBAction func pswEditChanged(_ sender: Any) {
        let inputPsw = pswTF.text! + ""
        let validated:Bool = ValidationUtils.validatePsw(psw: inputPsw)
        if  validated == false{
            passwordHintLabel.isHidden = false
            passwordHintLabel.text = "Password must be 8-24 characters, with at least one uppercase, lowercase and number, no symbol"
        }
        else{
            passwordHintLabel.isHidden = true
        }
        
        print("password validated, the result is: " + String(describing: validated))
    }
    
    @IBAction func confirmEditChanged(_ sender: Any) {
        let psw = pswTF.text
        if !passwordHintLabel.isHidden{
            confirmPswHintLabel.isHidden = false
            confirmPswHintLabel.text = "Enter validated password first"
        }
        else if confirmTF.text != psw{
            confirmPswHintLabel.isHidden = false
            confirmPswHintLabel.text = "Must be the same as the password you entered above"
        }
        else{
            confirmPswHintLabel.isHidden = true
        }
    }
    
    @IBAction func usernameEditChanged(_ sender: Any) {
        self.availabilityChecked = false
        let inputUsername = usernameTF.text!
        let validated:Bool = ValidationUtils.validateUsername(username: inputUsername)
        if  validated == false{
            usernameHintLabel.isHidden = false
            usernameHintLabel.text = "Username must be 6-20 characters, with no symbol."
        }
        else{
            usernameHintLabel.isHidden = true
        }
        print("username validated, the result is: " + String(describing: validated))
    }

    @IBAction func fnameEditChanged(_ sender: Any) {
        let fnInput = firstNameTF.text
        let lnInput = lastNameTF.text
        
        let validated:Bool = ValidationUtils.nameValidate(name: fnInput!) && ValidationUtils.nameValidate(name: lnInput!)
        if  validated == false{
            nameHintLabel.isHidden = false
            nameHintLabel.text = "Your name must be in validated format."
        }
        else{
            nameHintLabel.isHidden = true
        }
        print("name validated, the result is: " + String(describing: validated))
    }
    
    @IBAction func lnameEditChanged(_ sender: Any) {
        let lnInput = lastNameTF.text
        let fnInput = firstNameTF.text
        
        let validated:Bool = ValidationUtils.nameValidate(name: fnInput!) && ValidationUtils.nameValidate(name: lnInput!)
        if  validated == false{
            nameHintLabel.isHidden = false
            nameHintLabel.text = "Your name must be in validated format."
        }
        else{
            nameHintLabel.isHidden = true
        }
        print("name validated, the result is: " + String(describing: validated))
    }
    
    @IBAction func SignUpButtonPressed(_ sender: Any) {
        if !availabilityChecked{
            displayAlert(title: "Username Availability Not Checked", message: "Please check username availability before signing up.")
        }
        else if usernameHintLabel.isHidden && passwordHintLabel.isHidden && confirmPswHintLabel.isHidden &&
            nameHintLabel.isHidden{
            signUpButton.setTitle("", for: .normal)
            signupLoadingIndicator.startAnimating()
            signUpButton.isEnabled = false
            
            let username = usernameTF.text!
            var passwordHash = SHA1.hexString(from: pswTF.text!)
            let firstName = firstNameTF.text!
            let lastName = lastNameTF.text!
            
            var requestURL3 = "Replace it with your API which can add a new patient"
            requestURL3 = requestURL3 + username
            requestURL3 = requestURL3 + "&password="
            requestURL3 = requestURL3 + passwordHash! + "&firstName=" + firstName + "&lastName=" + lastName
            
            let url = URL(string: requestURL3)!
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let task = URLSession.shared.dataTask(with: request){ data, response, error in
                var dataString = String(data: data!, encoding: String.Encoding.utf8)! + ""
                if error != nil{
                    print("error occured")
                    DispatchQueue.main.sync{
                        self.displayAlert(title: "Error", message: "An error occured, please try later.")
                    }
                }
                else if "\"success!\"" != dataString{
                    DispatchQueue.main.sync{
                        print(dataString)
                        self.displayAlert(title: "Sign Up Failed", message: "Please check your input")
                    }
                }
                else{
                    DispatchQueue.main.sync{
                        self.navigationController?.popViewController(animated: true)
                        self.displayAlert(title: "Successful", message: "Your account has been created.")
                        
                    }
                }
            }
            task.resume()
        }
        else{
                displayAlert(title: "Information Not Correct", message: "Please provide all information in correct format to sign up.")
        }
        signUpButton.setTitle("Submit", for: .normal)
        signupLoadingIndicator.stopAnimating()
        signUpButton.isEnabled = true
        
    }


    
    @IBAction func checkAvailablityButtonPressed(_ sender: Any) {
        if usernameHintLabel.isHidden {
            checkUsernameAvailability(username: usernameTF.text)
        }
        else{
            self.displayAlert(title: "Username Not Validated", message: "Please enter a validated username before checking.")
        }
    }
    
    //check username availability via API
    func checkUsernameAvailability(username: String!){
        let requestURL = "Replace it with your API which can check whether the username is available" + username
        let task = URLSession.shared.dataTask(with: URL(string: requestURL)!){ data, response, error in
            if error != nil{
                print("error occured")
                DispatchQueue.main.sync{
                    self.displayAlert(title: "Error", message: "An error occured, please try later.")
                }
            }
            else{
                let responseString = String(data: data!, encoding: String.Encoding.utf8) as String?
                DispatchQueue.main.sync{
                    if "[]" != responseString{
                        self.displayAlert(title: "Username Already Exists", message: "Please try another username.")
                    }
                    else{
                        self.availabilityChecked = true
                        self.displayAlert(title: "Congratulations", message: "This username is available.")
                    }
                }
            }
        }
        task.resume()
    }
    
    func displayAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message:message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true)
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
