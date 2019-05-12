//
//  RemindersViewController.swift
//  Shield For Dementia Patient
//
//  Created by Xiaocheng Peng on 8/4/19.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit
import UserNotifications
import CoreData
class RemindersViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UNUserNotificationCenterDelegate {
    var reminders = [NSManagedObject]()
    
    @IBOutlet weak var reminderTableView: UITableView!
    @IBOutlet weak var refreshReminderButton: UIButton!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var setUpNotiButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
 
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        reminderTableView.delegate = self
        reminderTableView.dataSource = self
        loadLocalReminderFromCoreData()
        reminderTableView.reloadData()
        
    }
    
    func loadLocalReminderFromCoreData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Reminder")
        
        do{
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject]{
                reminders.append(data)
            }
        }
        catch{
            print("error")
        }
    }
    
    func removeAllCoreData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Reminder")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()
        } catch {
            print ("There was an error")
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reminderCell", for: indexPath) as! ReminderTableViewCell
        cell.medicineNameLabel.text = reminders[indexPath.row].value(forKey: "drugName") as? String
        cell.timeLabel.text = reminders[indexPath.row].value(forKey: "reminderTime") as? String
        
        let strDate = reminders[indexPath.row].value(forKey: "startDate") as? String
        let lastDays = reminders[indexPath.row].value(forKey: "lastTime") as? Int
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let startDate = dateFormatter.date(from: strDate!)
        let endDate = Calendar.current.date(byAdding: .day, value: lastDays!, to: startDate!)
        let currentDate = Date()
        
        if startDate! > currentDate{
            cell.statusLabel.text = "Not Started"
            cell.statusLabel.textColor = UIColor.blue
        }
        else if(startDate! < currentDate && endDate! > currentDate){
            cell.statusLabel.text = "In Process"
            cell.statusLabel.textColor = UIColor.green
        }
        else{
            cell.statusLabel.text = "Finished"
            cell.statusLabel.textColor = UIColor.orange
        }
        
        return cell
    }
    @IBAction func refreshButtonPressed(_ sender: Any) {
        retrieveReminderData()
    }
    
    @IBAction func setUpNotiButtonPressed(_ sender: Any) {
        removeAllNotifications()
        addNotifications()
    }
    
    func retrieveReminderData(){
        disableButtons()
        CBToast.showToastAction()
        reminders.removeAll()
        removeAllCoreData()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let reminderEntity = NSEntityDescription.entity(forEntityName: "Reminder", in: managedContext)!
        
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
                        
                        let reminder = NSManagedObject(entity: reminderEntity, insertInto: managedContext)
                        reminder.setValue(reminderId, forKey: "reminderId")
                        reminder.setValue(reminderTime, forKey: "reminderTime")
                        reminder.setValue(drugName, forKey: "drugName")
                        reminder.setValue(startDate, forKey: "startDate")
                        reminder.setValue(lastTime, forKey: "lastTime")
                        
                        self.reminders.append(reminder)
                    }
                }
                catch{
                    print(error)
                }
                do{
                    try managedContext.save()
                }
                catch{
                    print(error)
                }
                DispatchQueue.main.sync{
                    CBToast.hiddenToastAction()
                    self.enableButtons()
                    self.reminderTableView.reloadData()
                }
            }
        }
        task.resume()
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func removeAllNotifications(){
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllDeliveredNotifications()
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    func addNotifications(){
        disableButtons()
        let notificationCenter = UNUserNotificationCenter.current()
        let currentDate = Date()
        
        var timeList:[String] = [String]()
        
        for reminder in reminders{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            let startDate = dateFormatter.date(from: reminder.value(forKey: "startDate") as! String)
            let endDate = Calendar.current.date(byAdding: .day, value: reminder.value(forKey: "lastTime") as! Int, to: startDate!)
            
            if !timeList.contains(reminder.value(forKey: "reminderTime") as! String) && (startDate! < currentDate && endDate! > currentDate){
                timeList.append(reminder.value(forKey: "reminderTime") as! String)
            }
        }
        
        for time in timeList{
            let content = UNMutableNotificationContent()
            content.title = "Remember to take medicine at " + time
            content.body = "Please check medicine reminder list in the app."
            content.categoryIdentifier = "reminder"
            content.userInfo = ["reminderTime": time]
            content.sound = UNNotificationSound.default
            
            
            let timeArray = time.components(separatedBy:":")
            var dateComponents = DateComponents()
            dateComponents.hour = Int(timeArray[0])
            dateComponents.minute = Int(timeArray[1])
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: time, content: content, trigger: trigger)
            notificationCenter.add(request, withCompletionHandler: {error in
                if error != nil{
                    CBToast.showToast(message: "There is an error", aLocationStr: "center", aShowTime: 3.0)
                }
                else{
                    CBToast.showToast(message: "Successfully set up notifications", aLocationStr: "center", aShowTime: 5.0)
                }
            })
        }
        enableButtons()
    }
    
    
    @IBAction func notificationSwitchValueChanged(_ sender: Any) {
        if notificationSwitch.isOn{
            removeAllNotifications()
            addNotifications()
        }
        else{
            removeAllNotifications()
            setUpNotiButton.isEnabled = false
        }
    }
    
    func disableButtons(){
        setUpNotiButton.isEnabled = false
        refreshReminderButton.isEnabled = false
        notificationSwitch.isEnabled = false
    }
    
    func enableButtons(){
        setUpNotiButton.isEnabled = true
        refreshReminderButton.isEnabled = true
        notificationSwitch.isEnabled = true
    }
    
    
    
}
