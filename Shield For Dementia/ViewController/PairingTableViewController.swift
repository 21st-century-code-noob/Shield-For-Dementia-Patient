//
//  PairingTableViewController.swift
//  Shield For Dementia Patient
//
//  Created by 彭孝诚 on 2019/4/25.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit

class PairingTableViewController: UITableViewController {
    var requests:[Request] = [Request]()
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(false, animated: true)
        var items = [UIBarButtonItem]()
        items.append( UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(loadAllRequests)))
        self.toolbarItems = items
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAllRequests()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }

    //load all pairing requests
    @objc func loadAllRequests(){
        toolbarItems?[0].isEnabled = false
        CBToast.showToastAction()
        requests.removeAll()
        let username = UserDefaults.standard.value(forKey: "username") as! String
        let requestURL = "https://sqbk9h1frd.execute-api.us-east-2.amazonaws.com/IEProject/ieproject/friend-request/getrequestbypatientid?patientId=" + username
        let task = URLSession.shared.dataTask(with: URL(string: requestURL)!){ data, response, error in
            if error != nil{
                CBToast.hiddenToastAction()
                print("error occured")
            }
            else{
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as? [Any]
                    for item in json!{
                        let requestJson = item as? [String: Any]
                        let carerId = requestJson!["carer_id"] as! String
                        let requestId = requestJson!["request_id"] as! Int
                        let request = Request(requestId: requestId, carerId: carerId)
                        self.requests.append(request)
                    }
                }
                catch{
                    CBToast.hiddenToastAction()
                    print(error)
                }
                DispatchQueue.main.sync{
                    CBToast.hiddenToastAction()
                    self.toolbarItems?[0].isEnabled = true
                    self.tableView.reloadData()
                    if self.requests.count == 0{
                        CBToast.showToast(message: "There are no requests. Please send a pairing request on carer app and refersh.", aLocationStr: "center", aShowTime: 10.0)
                    }
                }
            }
        }
        task.resume()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pairingRequestCell", for: indexPath) as! RequestTableViewCell
        cell.requestId = String(requests[indexPath.row].requestId)
        cell.usernameLabel.text = requests[indexPath.row].carerId
        
        //when accept button is pressed, use api to update database
        cell.acceptButtonAction = {[unowned self] in
            if let indexPath = self.tableView.indexPath(for: cell) {
                let alert = UIAlertController(title: "Accept Pairing Request", message: "Accept Request? After accept the request, you can only unpair on carer app.", preferredStyle: .alert)
                
                // Create OK button with action handler
                let ok = UIAlertAction(title: "Accept", style: .default, handler: { (action) -> Void in
                    self.acceptOrDeclineRequest(accepted: "1", requestId: String(self.requests[indexPath.row].requestId), indexPath: indexPath)
                })
                
                // Create Cancel button with action handlder
                let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                    
                }
                //Add OK and Cancel button to dialog message
                alert.addAction(ok)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            }
        }
        //if declined, update database using api
        cell.declineButtonAction = {[unowned self] in
            if let indexPath = self.tableView.indexPath(for: cell) {
                let alert = UIAlertController(title: "Decline Pairing Request", message: "Are you sure you want to decline this request?", preferredStyle: .alert)
                
                // Create OK button with action handler
                let ok = UIAlertAction(title: "Decline", style: .default, handler: { (action) -> Void in
                    self.acceptOrDeclineRequest(accepted: "0", requestId: String(self.requests[indexPath.row].requestId), indexPath: indexPath)
                })
                
                // Create Cancel button with action handlder
                let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                    
                }
                //Add OK and Cancel button to dialog message
                alert.addAction(ok)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        // Configure the cell...
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
    
    //api to accept or decline request. Parameter includes request id, index path, and accepte or not.
    func acceptOrDeclineRequest(accepted: String, requestId: String, indexPath: IndexPath){
        CBToast.showToastAction()
        let requestURL = "https://sqbk9h1frd.execute-api.us-east-2.amazonaws.com/IEProject/ieproject/friend-request/acceptorrejectrequest?requestId=" + requestId + "&status=" + accepted
        
        let url = URL(string: requestURL)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            let dataString = String(data: data!, encoding: String.Encoding.utf8)! + ""
            if error != nil{
                print("error occured")
                DispatchQueue.main.sync{
                    CBToast.showToast(message: "There is something wrong. Please try later", aLocationStr: "center", aShowTime: 5.0)
                    CBToast.hiddenToastAction()
                }
            }
            else if "\"success!\"" != dataString{
                DispatchQueue.main.sync{
                    print(dataString)
                    CBToast.showToast(message: "There is something wrong. Please try later", aLocationStr: "center", aShowTime: 5.0)
                    CBToast.hiddenToastAction()
                }
            }
            else{
                DispatchQueue.main.sync{
                    CBToast.hiddenToastAction()
                    if accepted == "1"{
                        CBToast.showToast(message: "Request accepted.", aLocationStr: "center", aShowTime: 5.0)
                        self.navigationController?.popViewController(animated: true)
                    }
                    else{
                        self.requests.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                        CBToast.showToast(message: "Request declined.", aLocationStr: "center", aShowTime: 5.0)
                    }
                }
            }
        }
        task.resume()
    }
}
