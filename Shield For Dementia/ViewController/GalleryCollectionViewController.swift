//
//  GalleryCollectionViewController.swift
//  Shield For Dementia Carer
//
//  Created by apple on 6/4/19.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit
import Firebase


class GalleryCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    private let reuseIdentifier = "imageCell"
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    private let itemsPerRow: CGFloat = 3
    
    var imageList = [UIImage]()
    var imagePathList = [String]()
    var imageNameList = [String]()
    let username = UserDefaults.standard.object(forKey: "username") as! String
    var databaseRef = Database.database().reference().child("users")
    var storageRef = Storage.storage()
    
    var passingImage : UIImage?
    var passingImageName: String?
    var passingImagePathName : String?
     
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //UserDefaults
        let userID = "10wRyo7S8AcF0dhhyxWhEJsAuB12"
        let userRef = databaseRef.child(username).child("images")
        imageList = []
        imagePathList = []
        imageNameList = []
        
        userRef.observeSingleEvent(of: .value){(snapshot) in
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
                            self.collectionView?.reloadSections([0])
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
                                self.collectionView?.reloadSections([0])
                            }
                        })
                    }
                }
                
                
            }

        }
        
      self.collectionView?.reloadSections([0])
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
    
        // Do any additional setup after loading the view.
//        userRef.observe(.value, with:{(snapshot) in
//            self.parcelList = [Parcel]()
//            let value2 = snapshot.value as? NSDictionary
//            if value2 != nil{
//
//                for (key,valuedata) in value2!{
//                    var parcel = Parcel()
//                    parcel.uniqueId = key as? String
//                    let dataset = valuedata as! NSDictionary
//                    var dataList = [String]()
//
//                    for (_, value) in dataset{
//                        dataList.append(value as! String)
//                    }
//
//                    parcel.parcelNumber = dataList[0]
//                    parcel.sender = dataList[1]
//                    parcel.senderLocation = dataList[3]
//                    parcel.senderPostcode = dataList[7]
//                    parcel.senderState = dataList[5]
//                    parcel.receiver = dataList[9]
//                    parcel.receiverLocation = dataList[8]
//                    parcel.receiverPostcode = dataList[2]
//                    parcel.receiverState = dataList[6]
//                    parcel.status = dataList[4]
//                    self.parcelList.append(parcel)
//
//                }
//            }
//            self.tableView.reloadData()
//        })
    }
    
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
    
    func saveLocalData(fileName: String, imageData: Data){
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) [0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponment = url.appendingPathComponent(fileName){
            let filePath = pathComponment.path
            let fileManager = FileManager.default
            fileManager.createFile(atPath: filePath, contents: imageData, attributes: nil)
        }
    }
    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imageList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
    
        // Configure the cell
        cell.backgroundColor = UIColor.lightGray
        cell.imageView.image = imageList[indexPath.row]
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        passingImage = imageList[indexPath.row]
        passingImageName = imageNameList[indexPath.row]
        passingImagePathName = imagePathList[indexPath.row]
        performSegue(withIdentifier: "pictureDetails", sender: nil)
        return true
    }
    
 

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pictureDetails"{
            let controller = segue.destination as! PictureDetailViewController
            controller.image = passingImage
            controller.imageName = passingImageName
            controller.imageUrl = passingImagePathName
        }
    }

}
