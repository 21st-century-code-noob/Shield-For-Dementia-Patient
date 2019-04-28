//
//  ViewController.swift
//  KenBurns
//
//  Created by Basberg, Johan on 17/05/2016.
//  Copyright © 2016 IGT. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import FirebaseCore
import UserNotifications
import MapKit

class ViewController: UIViewController{

    @IBOutlet weak var kenBurnsView: JBKenBurnsView!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    var canRetrieveData: Bool = true
    var reminders:[Reminder] = []
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
        
        mapView.delegate = self
        var timer = Timer.scheduledTimer(timeInterval: 10.0,
                                                           target: self,
                                                           selector: #selector(self.uploadUserLocation),
                                                           userInfo: nil,
                                                           repeats: true)

        var bgTask = UIBackgroundTaskIdentifier(rawValue: 1)
        bgTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            UIApplication.shared.endBackgroundTask(bgTask)
        })
        RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
        
        Auth.auth().signIn(withEmail: "123@123.com", password: "123456789"){(user,error) in
        if error != nil{
            print(123456789)
            }}
        super.viewDidLoad()
        self.greetingLabel.alpha = 0
        self.nameLabel.alpha = 0

        self.navigationItem.hidesBackButton = true;
        if UserDefaults.standard.value(forKey: "patientName") == nil{
            getPatientName()
        }
        else{
            setWelcomeLabel()
        }
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
                        if var image = self.loadImageData(fileName: fileName){
                            
                            image = self.fixOrientation(img : image)
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
                                var image = UIImage(data: data!)!
                                self.saveLocalData(fileName: fileName, imageData: data!)
                                image = self.fixOrientation(img : image)
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
                    
                    self.displayMessage("You have a new photo in your memory, please check~", "")
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
        super.viewWillAppear(true)
        kenBurnsView.resumeAnimation()
        
        self.mapView.removeOverlays(overlayList)
        overlayList = []
        self.mapView.removeAnnotations(locationList)
        locationList = []
        for geoLocation in geoLocationList{
            locationManager.stopMonitoring(for: geoLocation)
        }
        geoLocationList = []
        

        if canRetrieveData{
            retrieveReminderData()
            canRetrieveData = false
            //set delay to avoid to frequent data retrieving.
            Timer.scheduledTimer(timeInterval:3, target: self, selector: #selector(setCanRetrieveData), userInfo: nil, repeats: false)
        }
        if (self.imageList.count != 0){
            self.kenBurnsView.animateWithImages(self.imageList, imageAnimationDuration: 10, initialDelay: 0, shouldLoop: true, randomFirstImage: true)
        }
        
        let username = UserDefaults.standard.object(forKey: "username") as? String
        if username != nil{
            let requestURL = "https://sqbk9h1frd.execute-api.us-east-2.amazonaws.com/IEProject/ieproject/carer/checkwhetherpatienthascarer?patientId=" + username!
            let task = URLSession.shared.dataTask(with: URL(string: requestURL)!){ data, response, error in
                if error != nil{
                    print("error occured")
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
                                            self.requestId = pair["request_id"] as! Int
                                            
                                            let requestURL = "https://sqbk9h1frd.execute-api.us-east-2.amazonaws.com/IEProject/ieproject/safezonelocation/getlocationbyrequestid?requestId=" + String(self.requestId!)
                                            
                                            let a = URL(string: requestURL)!
                                            
                                            let task = URLSession.shared.dataTask(with: URL(string: requestURL)!){ data, response, error in
                                                if error != nil{
                                                    print("error occured")
                                                    DispatchQueue.main.sync{
                                                        //self.displayAlert(title: "Error", message: "An error occured, please try later.")
                                                    }
                                                }
                                                else{
                                                    
                                                    let responseString = String(data: data!, encoding: String.Encoding.utf8)! as String
                                                    
                                                    DispatchQueue.main.sync{
                                                        
                                                        if responseString != "[]"{
                                                            
                                                            do {
                                                                
                                                                let json = try JSONSerialization.jsonObject(with: data!) as? [Any]
                                                                
                                                                for a in json!{
                                                                    
                                                                    var b = a as! NSDictionary
                                                                    var newAnnotation = FencedAnnotation(newTitle: b.value(forKey: "locationName") as! String,newSubtitle: b.value(forKey: "familiarity") as! String,lat: b.value(forKey: "latitude") as! Double, long: b.value(forKey: "longitude") as! Double)
                                                                    newAnnotation.subtitle = "Familiarity: " + newAnnotation.subtitle!
                                                                    self.addAnnotation(annotation: newAnnotation)
                                                                    self.locationList.append(newAnnotation)
                                                                    let geoLocation: CLCircularRegion? = CLCircularRegion(center: newAnnotation.coordinate, radius: 30, identifier: newAnnotation.title!)
                                                                    //geoLocation!.notifyOnExit = true
                                                                    geoLocation!.notifyOnEntry = true
                                                                    
                                                                    let circle: MKCircle = MKCircle.init(center: newAnnotation.coordinate, radius: 75)
                                                                    
                                                                    if(newAnnotation.subtitle == "Familiarity: Low"){
                                                                        
                                                                        circle.setValue(50, forKey: "radius")
                                                                    }
                                                                    else if(newAnnotation.subtitle == "Familiarity: High"){
                                                                        
                                                                        circle.setValue(100, forKey: "radius")
                                                                    }
                                                                    
                                                                    self.overlayList.append(circle)
                                                                    self.mapView.addOverlay(circle)
                                                                    self.geoLocationList.append(geoLocation!)
                                                                    self.locationManager.startMonitoring(for: geoLocation!)
                                                                }
                                                                self.focusOn(annotation: self.locationList[0])
                                                            }
                                                            catch{
                                                                
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            task.resume()
                                            
                                        }
                                    }
                                }
                            }
                            catch{
                                print(error)
                            }
                        }
                        else {

                        }
                    }
                }
            }
            task.resume()
        }
        
    configureLocationServices()
    }
    
    
    @objc func setCanRetrieveData(){
        canRetrieveData = true
    }
    
    //adamn kanben, questions, (stackoverflow)
    func fixOrientation(img:UIImage) -> UIImage {
        
        if (img.imageOrientation == UIImage.Orientation.up) {
            return img;
        }
        
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale);
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        
        let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return normalizedImage;
        
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
    
    
    func getPatientName(){
        let requestURL = "https://sqbk9h1frd.execute-api.us-east-2.amazonaws.com/IEProject/ieproject/patient/checkpatientid?patientId=" + (UserDefaults.standard.value(forKey: "username") as! String)
        let task = URLSession.shared.dataTask(with: URL(string: requestURL)!){ data, response, error in
            if error != nil{
                print("error occured")
                DispatchQueue.main.sync{
                    print(error!)
                }
            }
            else{
                DispatchQueue.main.sync{
                    do{
                        let jsonArray = try JSONSerialization.jsonObject(with: data!) as! [Any]
                        let jsonItem = jsonArray[0] as! [String: Any]
                        let patientName = jsonItem["first_name"]
                        UserDefaults.standard.set(patientName,forKey: "patientName")
                        self.setWelcomeLabel()
                    }
                    catch{
                        print(error)
                    }
                }
            }
        }
        task.resume()
    }

    //Code learned from stackoverflow
    func getTimeOfTheDay() -> String{
        let dateComponents = Calendar.current.dateComponents([.hour], from: Date())
        var timeOfDay: String = ""
        if let hour = dateComponents.hour {
            switch hour {
            case 0..<12:
                timeOfDay = "Morning"
            case 12..<17:

                timeOfDay = "Afternoon"
            default:
                timeOfDay = "Night"
            }
        }
        return timeOfDay
    }
    
    //the function name is self explaining
    func setWelcomeLabel(){
        greetingLabel.text = "Good " + getTimeOfTheDay() + "!"
        UIView.animate(withDuration: 1, animations: {
            self.greetingLabel.alpha = 1
        })
        
        nameLabel.text = (UserDefaults.standard.value(forKey: "firstName") as! String)
        UIView.animate(withDuration: 1, delay:0.5, animations: {
            self.nameLabel.alpha = 1
        })
    }
    
    //handles data retrieving
    func retrieveReminderData(){
        CBToast.showToastAction()
        reminders.removeAll()
        let requestURL = "https://sqbk9h1frd.execute-api.us-east-2.amazonaws.com/IEProject/ieproject/reminder/selectreminderbypatientid?patientId=" + (UserDefaults.standard.object(forKey: "username") as! String)
        let task = URLSession.shared.dataTask(with: URL(string: requestURL)!){ data, response, error in
            if error != nil{
                CBToast.hiddenToastAction()
                print("error occured")
            }
            else{
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as? [Any]
                    for item in json!{
                        let reminderJson = item as? [String: Any]
                        let reminderId = reminderJson!["reminder_id"] as! Int
                        let reminderTime = reminderJson!["time"] as! String
                        let drugName = reminderJson!["drug_name"] as! String
                        let startDate = reminderJson!["dates"] as! String
                        let lastTime = reminderJson!["lasts"] as! Int
                        let reminder: Reminder = Reminder(reminderId: reminderId, reminderTime: reminderTime, drugName: drugName, startDate: startDate, lastTime: lastTime)
                        self.reminders.append(reminder)
                    }
                }
                catch{
                    print(error)
                }
                DispatchQueue.main.sync{
                    CBToast.hiddenToastAction()
                }
            }
        }
        task.resume()
    }
    
    //going to reminder
    @IBAction func remindersButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "reminderSegue", sender: reminders)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RemindersViewController, let reminderToSend = sender as? [Reminder] {
            vc.reminders = reminderToSend
        }
    }
    
    
    @objc func uploadUserLocation(){
        var patientId = UserDefaults.standard.value(forKey: "username") as! String
        self.databaseRef.child("users").child(patientId).child("realTimeLocation").updateChildValues(["latitude": currentLocation?.latitude, "longitude": currentLocation?.longitude])
    }
    
    
    @IBOutlet weak var mapView: MKMapView!
    var requestId: Int?
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocationCoordinate2D?

    var patientLocation : FencedAnnotation?
    var locationList  = [FencedAnnotation]()
    var overlayList: [MKOverlay] = []
    var geoLocationList: [CLCircularRegion] = []
    var geoLocation: CLCircularRegion?
    var locationManger: CLLocationManager = CLLocationManager()
    
    var timeLimit = 10 * 60
    var timerOnExit = Timer()
    var timeLimitForActual = 0
    var timerActual = Timer()
    var liveDestination : String?
    var liveTime : String?
    
    
    
    private func configureLocationServices(){
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        mapView.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func addAnnotation(annotation: MKAnnotation){
        self.mapView.addAnnotation(annotation)
    }
    
    func focusOn(annotation: MKAnnotation){
        self.mapView.centerCoordinate = annotation.coordinate
        self.mapView.selectAnnotation(annotation,animated: true)
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        self.mapView.setRegion(zoomRegion, animated: true)
    }
    
}

extension ViewController: CLLocationManagerDelegate{
    
    //Moodle
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let latestLocation = locations.first else {return}
        currentLocation = latestLocation.coordinate
    }
    
    @objc func counterFor10Minutes(){
        self.timeLimit -= 1
        if(self.timeLimit == 0){
            timerOnExit.invalidate()
            var patientId = UserDefaults.standard.value(forKey: "username") as! String
            self.databaseRef.child("users").child(patientId).child("notificationWhenTimerIsUp").updateChildValues(["destination": "Unknown",
                                                                                                                   "time limit": "10 mins",
                                                                                                                   "notification": 1])
        }
        
    }
    
    @objc func counterForReal(){
        self.timeLimitForActual -= 1
        if(self.timeLimitForActual == 0){
            timerActual.invalidate()
            var patientId = UserDefaults.standard.value(forKey: "username") as! String
            self.databaseRef.child("users").child(patientId).child("notificationWhenTimerIsUp").updateChildValues(["destination": liveDestination,
                                                                                                                   "time limit": liveTime,
                                                                                                                   "notification": 1])
        }
    }
    
    //Moodle
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion){
        self.timeLimit = 1 * 30
        self.timerOnExit = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.counterFor10Minutes), userInfo: nil, repeats: true)
        var bgTask = UIBackgroundTaskIdentifier(rawValue: 2)
        bgTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            UIApplication.shared.endBackgroundTask(bgTask)
        })
        RunLoop.current.add(self.timerOnExit, forMode: RunLoop.Mode.default)
        
        
        var patientId = UserDefaults.standard.value(forKey: "username") as! String
        self.databaseRef.child("users").child(patientId).child("notificationExitRegin").updateChildValues(["locationExited": region.identifier, "notification": 1])
        
        var locationListEdited  = [FencedAnnotation]()
        for location in locationList{
            if(region.identifier != location.title){
                locationListEdited.append(location)
            }
        }
        let alert = UIAlertController(title: "Hello! \(patientId)", message: "Where would you like to go?", preferredStyle: UIAlertController.Style.alert)
        
        for location in locationListEdited {
            alert.addAction(UIAlertAction(title: location.title, style: UIAlertAction.Style.default, handler: {(action) in
                
                
                
                let googleAPIRequest = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=\((self.currentLocation?.latitude)!),\((self.currentLocation?.longitude)!)&destinations=\(location.coordinate.latitude),\(location.coordinate.longitude)&mode=walking&language=en&key=AIzaSyBfPk7CiUqW7tkudPQg_RbAqgnLAcvAMiw"
                
                let task = URLSession.shared.dataTask(with: URL(string: googleAPIRequest)!){ data, response, error in
                    if error != nil{
                        print("error occured")
                    }
                    else{
                        var v = false
                        do {
                            let json = try JSONSerialization.jsonObject(with: data!) as? NSDictionary
                            for (key, value) in json!{
                                let keyString = key as! String
                                if(keyString == "rows"){
                                    let distanceInfo = value as! NSArray
                                    let distanceInfoDictionary = distanceInfo[0] as! NSDictionary
                                    for(key2, value2) in distanceInfoDictionary{
                                        let key2String = key2 as! String
                                        if(key2String == "elements"){
                                            let distanceInfo2 = value2 as! NSArray
                                            let distanceInfo2Dictionary = distanceInfo2[0] as! NSDictionary
                                            
                                            let duration = distanceInfo2Dictionary.value(forKey: "duration") as! NSDictionary
                                            let text = duration.value(forKey: "text") as! String
                                            
                                            let valueInSecond = 60
                                                //duration.value(forKey: "value") as! Int
                                            
                                            if(self.timeLimit != 0 && valueInSecond - (1 * 30 - self.timeLimit) > 0){
                                                self.timerOnExit.invalidate()
                                                self.liveDestination = location.title
                                                self.liveTime = text
                                                self.timeLimitForActual = valueInSecond - (1 * 30 - self.timeLimit)
                                                v = true
                                                
                                            }
                                           
                                        }
                                    }
                                }
                            }
                        }
                        catch{
                            print(error)
                        }
                        DispatchQueue.main.sync{
                            if(v){
                                self.timerActual = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.counterForReal), userInfo: nil, repeats: true)
                                
                                var bgTask = UIBackgroundTaskIdentifier(rawValue: 3)
                                bgTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
                                    UIApplication.shared.endBackgroundTask(bgTask)
                                })
                                RunLoop.current.add(self.timerActual, forMode: RunLoop.Mode.default)
                                
                                
                            }
                            let latitude : CLLocationDegrees = location.coordinate.latitude
                            let longitude : CLLocationDegrees = location.coordinate.longitude
                            let regionDistance : CLLocationDistance = 1000
                            let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
                            let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
                            let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
                            let placeMark = MKPlacemark(coordinate: coordinates)
                            let mapItem = MKMapItem(placemark: placeMark)
                            mapItem.name = location.title
                            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
                            
                        }
                    }
                }
                task.resume()
              
            }))
        }
        alert.addAction(UIAlertAction(title: "Other Places", style: UIAlertAction.Style.default, handler: {(action) in
            self.databaseRef.child("users").child("\(patientId)").child("notificationOnOtherPlaces").updateChildValues(["notification":1])
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion){
        
        timerOnExit.invalidate()
        timeLimit = 1 * 30
        timerActual.invalidate()
        timeLimitForActual = 0
        liveDestination = ""
        liveTime = ""
        displayMessage("Congratulation！You have made it to \(region.identifier)", "Welcome to your \(region.identifier)")
    }
}

extension ViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let circle = MKCircleRenderer(overlay: overlay)
        circle.strokeColor = UIColor(red: 50/255, green: 205/255, blue: 50/255, alpha: 1)
        circle.fillColor = UIColor(red: 50/255, green: 205/255, blue: 50/255, alpha: 0.2)
        circle.lineWidth = 1.5
        
        return circle
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView")
        if annotationView == nil{
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotationView")
        }
        
        if annotation.isKind(of: MKUserLocation.self){
            return nil
        }
        //annotationView?.leftCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        
        var sizeChange : CGSize?
        let origin = CGPoint(x: 0, y: 0)
        
        var imagea : UIImage?
        if annotation.title == "Patient"{
            
            sizeChange = CGSize(width: 50, height: 50)
            imagea = UIImage(named: "old_man")
        }
        else{
            sizeChange = CGSize(width: 30, height: 30)
            imagea = UIImage(named: "map_mark_safe_zone")
        }
        UIGraphicsBeginImageContextWithOptions(sizeChange!, false, 0.0)
        
        imagea?.draw(in: CGRect(origin: origin, size: sizeChange!))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        annotationView?.image = newImage
        annotationView?.image?.draw(in: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        annotationView?.canShowCallout = true
        return annotationView
    }
}
