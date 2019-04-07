//
//  ViewController.swift
//  KenBurns
//
//  Created by Basberg, Johan on 17/05/2016.
//  Copyright © 2016 IGT. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

class ViewController: UIViewController {

    @IBOutlet weak var kenBurnsView: JBKenBurnsView!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var startRandomButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!

    var databaseRef = Database.database().reference()
    var storageRef = Storage.storage()
    var imageList = [UIImage]()
    var imagePathList = [String]()
    var imageNameList = [String]()
    
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "Log Out", style: .default, handler: { (action) -> Void in
            // Present dialog message to user
            UserDefaults.standard.removeObject(forKey: "username")
            UserDefaults.standard.removeObject(forKey: "password")
            UserDefaults.standard.removeObject(forKey: "patientId")
            UserDefaults.standard.removeObject(forKey: "lastName")
            self.performSegue(withIdentifier: "logoutUnwindSegue", sender: self)
        })
        
        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("Cancel button tapped")
        }
        
        //Add OK and Cancel button to dialog message
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    // Johan Basberg, Computer Program, (github, 2019)
    // MARK: - User Interaction
    @IBAction func toggleAnimationTouchUpFrom(_ sender: Any) {
    }
    
    // Johan Basberg, Computer Program, (github, 2019)
    @IBAction func valueChangeOfSwitch(_ sender: UISwitch) {
        UIView.setAnimationsEnabled(sender.isOn)
        if !sender.isOn && kenBurnsView.isAnimating {
            kenBurnsView.pauseAnimation()
        } else if kenBurnsView.currentImage != nil && kenBurnsView.isPaused {
            kenBurnsView.resumeAnimation()
        }
    }
    
    // Johan Basberg, Computer Program, (github, 2019)
    @IBAction func startTouchUpFrom(_ sender: UIButton) {
//        let images = [
//            UIImage(named: "ImageOne")!,
//            UIImage(named: "ImageTwo")!,
//            UIImage(named: "Johan")!,
//            ]
        
        kenBurnsView.animateWithImages(imageList, imageAnimationDuration: 10, initialDelay: 0, shouldLoop: true)
    }
    
    // Johan Basberg, Computer Program, (github, 2019)
    @IBAction func randomStartTouchUpFrom(_ sender: UIButton) {
//        let images = [
//            UIImage(named: "ImageOne")!,
//            UIImage(named: "ImageTwo")!,
//            UIImage(named: "Johan")!,
//            ]
        
        kenBurnsView.animateWithImages(imageList, imageAnimationDuration: 10, initialDelay: 0, shouldLoop: true, randomFirstImage: true)
    }

    // Johan Basberg, Computer Program, (github, 2019)
    @IBAction func pauseTouchUpFrom(_ sender: UIButton) {
        if kenBurnsView.isPaused {
            kenBurnsView.resumeAnimation()
            pauseButton.setTitle("Pause", for: .normal)
        } else {
            kenBurnsView.pauseAnimation()
            pauseButton.setTitle("Resume", for: .normal)
        }
    }

    //Johan Basberg, Computer Program, (github, 2019)
    @IBAction func stopTouchUpFrom(_ sender: UIButton) {
        kenBurnsView.stopAnimation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true;
        
        //The swift guy, Notification tutorial, (youtube, 2016)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound], completionHandler: {didAllow, error in
            
            if didAllow{
                
            }
            else{
                
            }
        })
        
        let userID = UserDefaults.standard.value(forKey: "username") as! String
        let userRef = databaseRef.child("users").child("\(userID)").child("images")
        
        userRef.observe(.value, with:{(snapshot) in
            guard let value = snapshot.value as? NSDictionary else{
                return
            }
                
            for(name, link) in value{
                let url = link as! String
                let fileName = name as! String
                
                if(!self.imagePathList.contains(url)){
                    
                    self.imagePathList.append(url)
                    if self.localFileExists(fileName: fileName){
                        if let image = self.loadImageData(fileName: fileName){
                            
                            self.imageList.append(image)
                            self.imageNameList.append(fileName)
                            //self.collectionView?.reloadSections([0])
                        }
                    }
                    else{
                        self.storageRef.reference(forURL: url).getData(maxSize: 5 * 1024 * 1024, completion: {(data, error) in
                            if let error = error{
                                print(error.localizedDescription)
                            }
                            else{
                                let image = UIImage(data: data!)!
                                self.saveLocalData(fileName: fileName, imageData: data!)
                                self.imageList.append(image)
                                self.imageNameList.append(fileName)
                                self.kenBurnsView.animateWithImages(self.imageList, imageAnimationDuration: 10, initialDelay: 0, shouldLoop: true, randomFirstImage: true)
                                //self.collectionView?.reloadSections([0])
                            }
                        })
                    }
                }
            }
            if (self.imageList.count != 0){
                 self.kenBurnsView.animateWithImages(self.imageList, imageAnimationDuration: 10, initialDelay: 0, shouldLoop: true, randomFirstImage: true)
            }
           
  
        })
        
        databaseRef.child("users").child("\(userID)").child("notifications").observe(.value, with:{(snapshot) in
            guard let value = snapshot.value as? NSDictionary else{
                return
            }
            
            for(name, link) in value{
                let status = link as! Int
                if status == 1{
                    
                    self.displayMessage("You have a new photo in your memory, please check~", "HeHe")
                    //The swift guy, Notification tutorial, (youtube, 2016)
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                    let content = UNMutableNotificationContent()
                    content.title = "Notifications"
                    //content.subtitle = "this is a subtitle"
                    content.body = "You have a new photo in your memory"
                    content.badge = 1
                    let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                    
                    
                self.databaseRef.child("users").child("\(userID)").child("notifications").updateChildValues(["notification":0])
                    
                }
            
                
            }

        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        kenBurnsView.resumeAnimation()
    }
    
    //Advance Mobile system, tutorial, (Moodle 2018)
    func localFileExists(fileName: String) -> Bool{
        
        var localFileExists = false
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent(fileName){
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            localFileExists = fileManager.fileExists(atPath: filePath)
        }
        return localFileExists
    }
    
    //Advance Mobile system, tutorial, (Moodle 2018)
    func saveLocalData(fileName: String, imageData: Data){
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) [0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponment = url.appendingPathComponent(fileName){
            let filePath = pathComponment.path
            let fileManager = FileManager.default
            fileManager.createFile(atPath: filePath, contents: imageData, attributes: nil)
        }
    }
    
    //Advance Mobile system, tutorial, (Moodle 2018)
    func loadImageData(fileName: String) -> UIImage?{
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        var image: UIImage?
        if let pathCompoment = url.appendingPathComponent(fileName){
            let filePath = pathCompoment.path
            let fileManager = FileManager.default
            let fileData = fileManager.contents(atPath: filePath)
            image = UIImage(data: fileData!)
        }
        return image
    }
    
    //Advance Mobile system, tutorial, (Moodle 2018)
    func displayMessage(_ message: String,_ title: String){
        let alertController = UIAlertController(title:title, message: message,
                                                preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    
}

