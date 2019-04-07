//
//  Reminder.swift
//  Shield For Dementia Carer
//
//  Created by Xiaocheng Peng on 6/4/19.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import Foundation
class Reminder{
    var reminderId: Int
    var reminderTime: String
    var drugName: String
    var startDate: String
    var lastTime: Int
    
    init(reminderId: Int, reminderTime: String, drugName: String, startDate: String, lastTime: Int) {
        self.reminderId = reminderId
        self.reminderTime = reminderTime
        self.drugName = drugName
        self.startDate = startDate
        self.lastTime = lastTime
    }
    
    
}
