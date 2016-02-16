/*
 *   © Copyright 2015 IBM Corp.
 *
 *   Licensed under the Mobile Edge iOS Framework License (the "License");
 *   you may not use this file except in compliance with the License. You may find
 *   a copy of the license in the license.txt file in this package.
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
*/


import Foundation

public typealias InterpretationListener = AnyObject! -> ()

public class BaseInterpretation : NSObject{

    var listener:InterpretationListener!
    var statusListener:InterpretationListener!
    var name:String
    
    public init(interpretationName:String){
        self.name = interpretationName
    }

    public func registerListener(listener:InterpretationListener){
        self.listener = listener
    }
    
    public func registerStatusListener(listener:InterpretationListener){
        self.statusListener = listener
    }
    
    public func registerForEvents(sensors:Sensors){
        
    }
    
    public func unregisterEvents(sensors: Sensors){
        
    }

    public func notifyResult(additionalInfo:AnyObject!){
        if let listener = listener {
            listener(additionalInfo)
        }
    }
    
    public func nofifyStatusUpdate(additionalInfo:AnyObject!){
        if let statusListener = statusListener {
            statusListener(additionalInfo)
        }
    }

    public func notifyResult(){
        notifyResult(nil)
    }
}

public class FallDetection : BaseInterpretation {
    
    let jsEngine = JSEngine.instance
    
    public init(){
        super.init(interpretationName: "Fall Pattern Detection")
        jsEngine.loadJS("falldetection")
    }
    
    override public func registerForEvents(sensors: Sensors) {
        sensors.accelerometer.registerListener(accelerometerDataChanged)
    }
    
    func accelerometerDataChanged(data:AccelerometerData) {

        if (data.x == 0 && data.y == 0 && data.z == 0){
            return
        }

        let result = jsEngine.executeMethod("detect", payload: data.asJSON()).toDictionary()

        if result["detected"] as! Bool == true{
            notifyResult(result)
        }
    }
}


public class ExtreamTemperatureDetection : BaseInterpretation {
    
    var threshold:Double = 0
    
    public init(threshold:Double){
        super.init(interpretationName: "Extream Temperature Detection")
        self.threshold = threshold
    }
    
    override public func registerForEvents(sensors: Sensors) {
        sensors.temperature.registerListener(temperatureDataChanged)
    }
    
    public func setThreshold2(threshold:Double){
        self.threshold = threshold
    }
    
    func temperatureDataChanged(data:TemperatureData){

        if (data.temperature > threshold){
            notifyResult()
        }
    }
    
}



