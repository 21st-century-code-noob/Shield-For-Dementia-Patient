//
//  ValidationUtils.swift
//  Shield For Dementia Carer
//
//  Created by 彭孝诚 on 2019/4/3.
//  Copyright © 2019 彭孝诚. All rights reserved.
//
import CommonCrypto
import Foundation

class ValidationUtils{
    static func validateUsername(username: String!) -> Bool{
        var validated: Bool! = true
        
        let RegEx = "\\w{6,20}"
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        
        if username.isEmpty{
            validated = false
        }

        
        else if Test.evaluate(with: username) == false{
            validated = false
        }
        
        return validated
    }
    
    static func validatePsw(psw: String!) -> Bool{
        var validated: Bool! = true
        let RegEx = "^[a-zA-Z\\d]{8,24}$"
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        if psw.isEmpty{
            validated = false
        }
        else if Test.evaluate(with: psw) == false{
            validated = false
        }
        return validated
    }
    
    static func nameValidate(name: String) -> Bool{
        var validated: Bool! = true
        let RegEx = "^[A-Z][0-9a-zA-Z’'-]*$"
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        if name.isEmpty{
            validated = false
        }
        else if Test.evaluate(with: name) == false{
            validated = false
        }
        return validated
    }
    

}

