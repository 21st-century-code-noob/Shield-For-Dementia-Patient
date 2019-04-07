//
//  CameraViewController.swift
//  Shield For Dementia Carer
//
//  Created by apple on 6/4/19.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit
import Firebase

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var databaseRef = Database.database().reference()
    var storageRef = Storage.storage().reference()
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBAction func takePhoto(_ sender: Any) {
        let controller = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
            controller.sourceType = UIImagePickerController.SourceType.camera
        }
        else{
            controller.sourceType = UIImagePickerController.SourceType.photoLibrary
        }
        
        controller.allowsEditing = false
        controller.delegate = self
        self.present(controller,animated: true,completion: nil)
    }
    
    @IBAction func savePhoto(_ sender: Any) {
        guard let image = imageView.image else{
            displayMessage("Cannot save until a photo has been taken!", "Error")
            return
        }
//        guard let userID = Auth.auth().currentUser?.uid else{
//            displayMessage("Cannot upload image until logged in", "Error")
//            return
//        }
        
        let userID = "10wRyo7S8AcF0dhhyxWhEJsAuB12"
        let date = NSUUID().uuidString
        var data = Data()
        let username = UserDefaults.standard.object(forKey: "username") as! String
        //data = UIImageJPEGRepresentation(image, 0.8)!
        data = image.jpegData(compressionQuality: 0.8)!
        
        let imageRef = storageRef.child("users").child(username).child("images").child(date)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        imageRef.putData(data, metadata: metadata){(metaData,error) in
            if error != nil {
                self.displayMessage("Could not upload image", "Error")
            }
            else{
                
                imageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        return
                        
                    }
                    
                self.databaseRef.child("users").child(username).child("images").updateChildValues(["\(date)": downloadURL.absoluteString])
                self.displayMessage("Image saved to the cloud", "Success")
                }
                
            }
        }
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("\(date)"){
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
        }
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Auth.auth().signIn(withEmail: "123@123.com", password:"123456789"){(user,error) in
            if error != nil {
                self.displayMessage(error!.localizedDescription,"Error")
            }
        }
    }
    
    func displayMessage(_ message: String,_ title: String){
        let alertController = UIAlertController(title:title, message: message,
                                                preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        displayMessage("There was an error in getting the photo", "Error")
        self.dismiss(animated: true, completion: nil)
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
