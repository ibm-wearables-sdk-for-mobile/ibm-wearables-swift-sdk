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

public enum SensorType {
    case Accelerometer, Temperature, Humidity, Magnetometer, Gyroscope, Barometer, Optical, AmbientLight, Calories, Gsr, Pedometer, HeartRate, SkinTemperature, UV
}

public class BaseSensorData {
    public var timeStamp:NSDate
    public var tag:String!
    
    public init(){
        timeStamp = NSDate()
    }
    
    public func asJSON() -> Dictionary<String,AnyObject>{
        var data = Dictionary<String,AnyObject>()
        data["timeStamp"] = timeStamp
        if let tag = tag{
            data["tag"] = tag
        }
        return data
    }
}

public class AccelerometerData : BaseSensorData{
    public var x:Double = 0.0
    public var y:Double = 0.0
    public var z:Double = 0.0
    
    override public init() {
        super.init()
    }
    
    override public func asJSON() -> Dictionary<String,AnyObject> {
        var data = super.asJSON()
        data["accelerometer"] = ["x":x,"y":y,"z":z]
        return data
    }
}


public class TemperatureData : BaseSensorData{
    public var temperature:Double = 0.0
    
    override public init() {
        super.init()
    }
    
    override public func asJSON() -> Dictionary<String,AnyObject> {
        var data = super.asJSON()
        data["temperature"] = temperature
        return data
    }
}

public class HumidityData : BaseSensorData{
    public var humidity:Double = 0.0
    
    override public init() {
        super.init()
    }
    
    override public func asJSON() -> Dictionary<String,AnyObject> {
        var data = super.asJSON()
        data["humidity"] = humidity
        return data
    }
}

public class GyroscopeData : BaseSensorData{
    public var x:Double = 0.0
    public var y:Double = 0.0
    public var z:Double = 0.0
    
    override public init() {
        super.init()
    }
    
    override public func asJSON() -> Dictionary<String,AnyObject> {
        var data = super.asJSON()
        data["gyroscope"] = ["x":x,"y":y,"z":z]
        return data
    }
}

public class MagnetometerData : BaseSensorData{
    public var x:Double = 0.0
    public var y:Double = 0.0
    public var z:Double = 0.0
    
    override public init() {
        super.init()
    }
    
    override public func asJSON() -> Dictionary<String, AnyObject> {
        var data = super.asJSON()
        data["magnetometer"] = ["x":x,"y":y,"z":z]
        return data
    }
}

public class BarometerData : BaseSensorData{
    
    public var temperature:Double = 0.0
    public var airPressure:Double = 0.0
    
    override public init() {
        super.init()
    }
    
    override public func asJSON() -> Dictionary<String, AnyObject> {
        var data = super.asJSON()
        data["barometer"] = ["temperature":temperature,"airPressure":airPressure]
        return data
    }
}

public class OpticalData : BaseSensorData{
    
}


public class AmbientLightData : BaseSensorData{
    
    public var brightness:Int = 0
    
    override public init() {
        super.init()
    }
    
    override public func asJSON() -> Dictionary<String, AnyObject> {
        var data = super.asJSON()
        data["brightness"] = [brightness]
        return data
    }
}


public class CaloriesData : BaseSensorData{
    
    //data here
    public var calories:UInt = 0
    
    override public init() {
        super.init()
    }
    
    override public func asJSON() -> Dictionary<String, AnyObject> {
        var data = super.asJSON()
        data["calories"] = [calories]
        return data
    }
}

public class GsrData : BaseSensorData{
    
    public var resistance:UInt = 0
    
    override public init() {
        super.init()
    }
    
    override public func asJSON() -> Dictionary<String, AnyObject> {
        var data = super.asJSON()
        data["resistance"] = [resistance]
        return data
    }
}


public class PedometerData : BaseSensorData{
    
    public var steps:UInt = 0
    
    override public init() {
        super.init()
    }
    
    override public func asJSON() -> Dictionary<String, AnyObject> {
        var data = super.asJSON()
        data["steps"] = [steps]
        return data
    }
}


public class HeartRateData : BaseSensorData{
    
    public var heartRate:UInt = 0
    
    override public init() {
        super.init()
    }
    
    override public func asJSON() -> Dictionary<String, AnyObject> {
        var data = super.asJSON()
        data["heartRate"] = [heartRate]
        return data
    }
}

public class SkinTemperatureData : BaseSensorData{
    
    public var temperature:Double = 0
    
    override public init() {
        super.init()
    }
    
    override public func asJSON() -> Dictionary<String, AnyObject> {
        var data = super.asJSON()
        data["temperature"] = [temperature]
        return data
    }
}

public class UVData : BaseSensorData{
    
    public var indexLevel:UInt = 0
    
    override public init() {
        super.init()
    }
    
    override public func asJSON() -> Dictionary<String, AnyObject> {
        var data = super.asJSON()
        data["indexLevel"] = [indexLevel]
        return data
    }
}





