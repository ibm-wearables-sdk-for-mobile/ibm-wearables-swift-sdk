//
//  LogUtils.swift
//  RecordApp
//
//  Created by Cirill Aizenberg on 2/7/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation


class LogUtils {
    
    
    static func createFileForNewGesture(gestureName:String) -> String{
        
        
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        
        let content = "\(gestureName),"
        let path = getDocumentsDirectory().stringByAppendingPathComponent("Log_\(gestureName)_\(formatter.stringFromDate(date))).csv")
        
        writeToFile(path, content: content)
        
        return path
    }
    
    static func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    static func saveLog(path:String, iterationNumber:Int, accelerometerDataArray:[[Double]], gyroscopeDataArray:[[Double]]){
     
        //let fileName = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("Log_\(gestureName).csv")
        
        var content = "\niteration\(iterationNumber),\n"
        
        for (index,element) in gyroscopeDataArray.enumerate() {
            
            content.appendContentsOf("\(element[0]),\(element[1]),\(element[2]),\(accelerometerDataArray[index][0]),\(accelerometerDataArray[index][1]),\(accelerometerDataArray[index][2])\n")
        }
        
        updateFile(path, content: content)
        
        //csvString.appendContentsOf()
        
    }
    
    static func readFromFile(path:String) -> String{
        do {
            let content = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
            return content
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
        return ""
    }
    
    static func writeToFile(path:String, content:String){
        do {
            try content.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    
    static func updateFile(path:String, content:String){
        var previousContent = readFromFile(path)
        previousContent.appendContentsOf(content)
        
        writeToFile(path, content: previousContent)
    }
}
