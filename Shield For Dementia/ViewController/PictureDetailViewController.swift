//
//  PictureDetailViewController.swift
//  Shield For Dementia Carer
//
//  Created by apple on 6/4/19.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit
import Firebase

class PictureDetailViewController: UIViewController {
    
    var image: UIImage?
    var imageName: String?
    var imageUrl: String?
    
    let username = UserDefaults.standard.object(forKey: "username") as! String
    var databaseRef = Database.database().reference().child("users")
    var storageRef = Storage.storage()
    
    @IBOutlet weak var imageDetail: UIImageView!
    
    @IBAction func deleteMemory(_ sender: Any) {
        databaseRef.child(username).child("images").child(imageName!).removeValue()
        let storageRef1 = storageRef.reference(forURL: imageUrl!)
        
        //Removes image from storage
        storageRef1.delete { error in
            if let error = error {
                print(error)
            } else {
                // File deleted successfully
                self.displayMessage("Image has been deleted", "Success")
            }
        }
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        imageDetail.image = image
    }
    
    func displayMessage(_ message: String,_ title: String){
        let alertController = UIAlertController(title:title, message: message,
                                                preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
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
