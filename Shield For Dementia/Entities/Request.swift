//
//  Request.swift
//  Shield For Dementia Patient
//
//  Created by 彭孝诚 on 2019/4/25.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import Foundation
class Request{
    var requestId: Int
    var carerId: String
    
    init(requestId: Int, carerId: String) {
        self.requestId = requestId
        self.carerId = carerId
    }
    
    
}
