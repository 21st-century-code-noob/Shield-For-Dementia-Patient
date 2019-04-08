//
//  RemindersViewController.swift
//  Shield For Dementia Patient
//
//  Created by Xiaocheng Peng on 8/4/19.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit


class RemindersViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    var reminders: [Reminder] = []
    @IBOutlet weak var reminderTableView: UITableView!

    @IBOutlet weak var kenBurnsView: JBKenBurnsView!
    
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
    



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
