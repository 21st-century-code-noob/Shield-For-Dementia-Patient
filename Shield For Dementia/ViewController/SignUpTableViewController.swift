//
//  SignUpTableViewController.swift
//  Shield For Dementia Carer
//
//  Created by Xiaocheng Peng on 13/4/19.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit

class SignUpTableViewController: UITableViewController {
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var pswTF: UITextField!
    @IBOutlet weak var confirmTF: UITextField!
    @IBOutlet weak var fnameTF: UITextField!
    @IBOutlet weak var lnameTF: UITextField!
    
    @IBOutlet weak var usernameIndicator: UIImageView!
    @IBOutlet weak var pswIndicator: UIImageView!
    @IBOutlet weak var confirmIndicator: UIImageView!
    @IBOutlet weak var fnameIndicator: UIImageView!
    @IBOutlet weak var lnameIndicator: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0{
            return 1
        }
        else{
            return 2
        }
    }
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    
    @IBAction func usernameEditingChanged(_ sender: Any) {
        let username = usernameTF.text
        if ValidationUtils.validateUsername(username: username){
            usernameIndicator.image = UIImage(named: "Tick_Mark_Dark-512 copy")
        }
        else{
            usernameIndicator.image = UIImage(named: "Close_Icon_Dark-512")
        }
    }
    
    @IBAction func pswEditChanged(_ sender: Any) {
        let psw = pswTF.text
        if ValidationUtils.validatePsw(psw: psw){
            pswIndicator.image = UIImage(named: "Tick_Mark_Dark-512 copy")
        }
        else{
            pswIndicator.image = UIImage(named: "Close_Icon_Dark-512")
        }
    }
    
    
    @IBAction func confirmEditChanged(_ sender: Any) {
        let confirm = confirmTF.text
        if confirm == pswTF.text && !(confirm?.isEmpty)!{
            confirmIndicator.image = UIImage(named: "Tick_Mark_Dark-512 copy")
        }
        else{
            confirmIndicator.image = UIImage(named: "Close_Icon_Dark-512")
        }
    }
    
    @IBAction func fnameEditChanged(_ sender: Any) {
        let fname = fnameTF.text
        if ValidationUtils.nameValidate(name: fname!){
            fnameIndicator.image = UIImage(named: "Tick_Mark_Dark-512 copy")
        }
        else{
            fnameIndicator.image = UIImage(named: "Close_Icon_Dark-512")
        }
    }
    
    @IBAction func lnameEditChanged(_ sender: Any) {
        let lname = lnameTF.text
        if ValidationUtils.nameValidate(name: lname!){
            lnameIndicator.image = UIImage(named: "Tick_Mark_Dark-512 copy")
        }
        else{
            lnameIndicator.image = UIImage(named: "Close_Icon_Dark-512")
        }
    }
    
    
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        if ValidationUtils.validateUsername(username: usernameTF.text) &&
            ValidationUtils.validatePsw(psw: pswTF.text) &&
            pswTF.text == confirmTF.text &&
            ValidationUtils.nameValidate(name: fnameTF.text!) &&
            ValidationUtils.nameValidate(name: lnameTF.text!){
            signUp(username: usernameTF.text!)
        }
        else{
            CBToast.showToast(message: "Please check your input", aLocationStr: "center", aShowTime: 2.0)
        }
    }
    
    
    func checkUsernameAvailability(username: String!, finished: @escaping((Bool)->Void)){
        let requestURL = "https://sqbk9h1frd.execute-api.us-east-2.amazonaws.com/IEProject/ieproject/patient/checkpatientid?patientId=" + username
        let task = URLSession.shared.dataTask(with: URL(string: requestURL)!){ data, response, error in
            if error != nil{
                print("error occured")
                DispatchQueue.main.sync{
                    CBToast.showToast(message: "An error has occured", aLocationStr: "center", aShowTime: 2.0)
                    CBToast.hiddenToastAction()
                }
                finished(false)
            }
            else{
                let responseString = String(data: data!, encoding: String.Encoding.utf8) as String?
                if "[]" != responseString{
                    DispatchQueue.main.sync{
                        CBToast.showToast(message: "The username already exists", aLocationStr: "center", aShowTime: 2.0)
                    }
                    finished(false)
                }
                else{
                    DispatchQueue.main.sync{
                        CBToast.showToast(message: "This username is available", aLocationStr: "center", aShowTime: 2.0)
                    }
                    finished(true)
                }
            }
        }
        task.resume()
    }
    
    func signUp(username: String){
        submitButton.isEnabled = false
        CBToast.showToastAction()
        let passwordHash = SHA1.hexString(from: self.pswTF.text!)
        let firstName = self.fnameTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = self.lnameTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        checkUsernameAvailability(username: username) {finished in
            if finished{
                var requestURL3 = "https://sqbk9h1frd.execute-api.us-east-2.amazonaws.com/IEProject/ieproject/patient/addnewpatient?patientId="
                requestURL3 = requestURL3 + username
                requestURL3 = requestURL3 + "&password="
                requestURL3 = requestURL3 + passwordHash! + "&firstName=" + firstName + "&lastName=" + lastName
                
                let url = URL(string: requestURL3)!
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                
                let task = URLSession.shared.dataTask(with: request){ data, response, error in
                    let dataString = String(data: data!, encoding: String.Encoding.utf8)! + ""
                    if error != nil{
                        print("error occured")
                        DispatchQueue.main.sync{
                            CBToast.hiddenToastAction()
                            self.submitButton.isEnabled = true
                        }
                    }
                    else if "\"success!\"" != dataString{
                        DispatchQueue.main.sync{
                            print(dataString)
                            CBToast.hiddenToastAction()
                            self.submitButton.isEnabled = true
                        }
                    }
                    else{
                        DispatchQueue.main.sync{
                            CBToast.hiddenToastAction()
                            CBToast.showToast(message: "Account successfully created.", aLocationStr: "center", aShowTime: 5.0)
                            self.submitButton.isEnabled = true
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
                task.resume()
            }
            else{
                DispatchQueue.main.sync{
                    self.submitButton.isEnabled = true
                    CBToast.hiddenToastAction()
                }
            }
        }
    }
    
}
