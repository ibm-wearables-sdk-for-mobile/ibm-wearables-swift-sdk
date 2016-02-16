//
//  Classification.swift
//  IBMMobileEdge
//
//  Created by Cirill Aizenberg on 1/4/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation

public class Classification : BaseInterpretation{
    
    let jsEngine = JSEngine.instance
    
    var accelerometerDataArrays = [[Double]]()
    var gyroscopeDataArrays = [[Double]]()
    
    var timer: NSTimer!
    
    let accelerometerListenerName = "accelerometerListener"
    let gyroscopeListenerName = "gyroscopeListener"
    
    public init(){
        super.init(interpretationName: "Classification")
        jsEngine.loadJS("commonClassifier")
    }
    
    public func loadGesturesByNames(gesturesFileNames:[String]){
        for name in gesturesFileNames {
            jsEngine.loadJS(name)
        }
    }
    
    public func loadGesturesByFilePath(gesturesFilePaths:[String]){
        for filePath in gesturesFilePaths {
            jsEngine.loadJSFromPath(filePath)
        }
    }
    
    public func setSensitivity(payload:Dictionary<String,Double>){
        if payload.count > 0 {
            print("set sensitivity payload = \(payload)")
            jsEngine.executeMethod("setGesturesSensitivity", payload: payload)
        }
    }
    
    override public func registerForEvents(sensors: Sensors) {
        sensors.accelerometer.registerListener(accelerometerDataChanged,withName: accelerometerListenerName)
        sensors.gyroscope.registerListener(gyroscopeDataChanged, withName: gyroscopeListenerName)
    }
    
    override public func unregisterEvents(sensors: Sensors){
        sensors.accelerometer.unregisterListener(accelerometerListenerName)
        sensors.gyroscope.unregisterListener(gyroscopeListenerName)
    }
    
    func accelerometerDataChanged(data:AccelerometerData) {
        print("Accelerometer")
        accelerometerDataArrays.append([data.x,data.y,data.z])
        executeCalassification()
    }
    
    func gyroscopeDataChanged(data:GyroscopeData){
        print("Gyroscope")
        gyroscopeDataArrays.append([data.x,data.y,data.z])
        executeCalassification()
    }
    
    func executeCalassification(){
        
        if (accelerometerDataArrays.count > 3 && gyroscopeDataArrays.count > 3){
            
            
            //make correction to data syncronization
            makeDataSyncronizationFix()
            
            //build the payload using the first 4 values
            var payload = Dictionary<String,AnyObject>()
            
            payload["accelerometer"] = [accelerometerDataArrays[0],accelerometerDataArrays[1],accelerometerDataArrays[2],accelerometerDataArrays[3]]
            payload["gyroscope"] = [gyroscopeDataArrays[0],gyroscopeDataArrays[1],gyroscopeDataArrays[2],gyroscopeDataArrays[3]]
            
            //execute the js engine
            let result = jsEngine.executeMethod("detectGesture", payload: payload).toDictionary()
            
            //remove the first 4 value from the buffer
            accelerometerDataArrays.removeFirst(4)
            gyroscopeDataArrays.removeFirst(4)
            
            if result["detected"] as! Bool == true{
                notifyResult(result["additionalInfo"])
            }
            
            else if let scores = result["additionalInfo"]{
                nofifyStatusUpdate(scores)
            }
            
            if let resultFromJs = result{
                print("Result from Calassification \(NSDate())")
                print(resultFromJs)
            }
            
        }
    }
    
    func makeDataSyncronizationFix(){
        
        let accelerometerLength = accelerometerDataArrays.count
        let gyroscopeLenght = gyroscopeDataArrays.count
        
        if (accelerometerLength > gyroscopeLenght){
            accelerometerDataArrays.removeFirst(accelerometerLength - gyroscopeLenght)
            print("Info: Data correction fix, dropped first \(accelerometerLength - gyroscopeLenght) reads of accelerometer")
        }
        
        else if (gyroscopeLenght > accelerometerLength){
            gyroscopeDataArrays.removeFirst(gyroscopeLenght - accelerometerLength)
            print("Info: Data correction fix, dropped first \(gyroscopeLenght - accelerometerLength) reads of gyroscope")
        }
    }
}
