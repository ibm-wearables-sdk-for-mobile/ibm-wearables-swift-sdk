//
//  AppPreferences.swift
//  RecordApp
//
//  Created by Cirill Aizenberg on 1/24/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation


class AppPreferences {
    
    static let prefs = NSUserDefaults.standardUserDefaults()

    static let registrationId = "registration"
    
    static func setRegistrationCode(code:String) {
        prefs.setObject(code, forKey: registrationId)
    }
    
    static func getRegistrationCode() -> String? {
        return prefs.stringForKey(registrationId)
    }

}