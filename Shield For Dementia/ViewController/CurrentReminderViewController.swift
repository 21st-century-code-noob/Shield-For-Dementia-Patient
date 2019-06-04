//
//  CurrentReminderViewController.swift
//  Shield For Dementia Patient
//
//  Created by 彭孝诚 on 2019/5/7.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit
import CoreData

class CurrentReminderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
   
    @IBOutlet weak var indicationLabel: UILabel!
    @IBOutlet weak var reminderTableView: UITableView!
    var currentReminders:[NSManagedObject] = [NSManagedObject]()
    var reminderTime: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCurrentRemindersFromCoreData()
        if (currentReminders.count == 1){
            indicationLabel.text = "This is the medicine you need to take at " + (UserDefaults.standard.object(forKey: "reminderTime") as! String)
        }
        else{
            indicationLabel.text = "These are the medicines you need to take at " + (UserDefaults.standard.object(forKey: "reminderTime") as! String)
        }
        reminderTableView.delegate = self
        reminderTableView.dataSource = self
        reminderTableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentReminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reminderCell", for: indexPath) as! ReminderTableViewCell
        cell.medicineNameLabel.text = currentReminders[indexPath.row].value(forKey: "drugName") as? String
        return cell
    }

    //When user taps notification, fetch current reminders from core data and display on the tableview, telling which medicine to take.
    func fetchCurrentRemindersFromCoreData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
        var tempReminders: [NSManagedObject] = [NSManagedObject]()
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Reminder")
        fetchRequest.predicate = NSPredicate(format: "reminderTime = %@", UserDefaults.standard.object(forKey: "reminderTime") as! String)
        do{
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject]{
                tempReminders.append(data)
            }
        }
        catch{
            print("error")
        }
        for reminder in tempReminders{
            let strDate = reminder.value(forKey: "startDate") as? String
            let lastDays = reminder.value(forKey: "lastTime") as? Int
        
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            let startDate = dateFormatter.date(from: strDate!)
            let endDate = Calendar.current.date(byAdding: .day, value: lastDays!, to: startDate!)
            let currentDate = Date()
        
            if(startDate! < currentDate && endDate! > currentDate){
                currentReminders.append(reminder)
            }
        }
    }
}
