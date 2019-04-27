//
//  RemindersViewController.swift
//  Shield For Dementia Patient
//
//  Created by Xiaocheng Peng on 8/4/19.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit
import UserNotifications

class RemindersViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    var reminders: [Reminder] = []
    @IBOutlet weak var reminderTableView: UITableView!
    @IBOutlet weak var refreshReminderButton: UIButton!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var setUpNotiButton: UIButton!
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        reminderTableView.delegate = self
        reminderTableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reminderCell", for: indexPath) as! ReminderTableViewCell
        cell.medicineNameLabel.text = reminders[indexPath.row].drugName
        cell.timeLabel.text = reminders[indexPath.row].reminderTime
        
        let strDate = reminders[indexPath.row].startDate
        let lastDays = reminders[indexPath.row].lastTime
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let startDate = dateFormatter.date(from: strDate)
        let endDate = Calendar.current.date(byAdding: .day, value: lastDays, to: startDate!)
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
            let startDate = dateFormatter.date(from: reminder.startDate)
            let endDate = Calendar.current.date(byAdding: .day, value: reminder.lastTime, to: startDate!)
            
            if !timeList.contains(reminder.reminderTime) && (startDate! < currentDate && endDate! > currentDate){
                timeList.append(reminder.reminderTime)
            }
        }
        
        for time in timeList{
            let content = UNMutableNotificationContent()
            content.title = "Medicine Reminder"
            content.body = "Tap to check what medicine you need to take at this moment."
            content.categoryIdentifier = "reminder"
            content.userInfo = ["username": UserDefaults.standard.value(forKey: "username") as! String]
            content.sound = UNNotificationSound.default
            
            let timeArray = time.components(separatedBy:":")
            var dateComponents = DateComponents()
            dateComponents.hour = Int(timeArray[0])
            dateComponents.minute = Int(timeArray[1])
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            notificationCenter.add(request, withCompletionHandler: {error in
                if error != nil{
                    CBToast.showToast(message: "There is an error", aLocationStr: "center", aShowTime: 3.0)
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
