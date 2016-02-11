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


public class SensorHolder<T> {
    
    private let sensorEvent: SensorEvents
    
    init(sensorEvent: SensorEvents){
        self.sensorEvent = sensorEvent
    }
    
    public func registerListener(compleation:(data:T)->Void){
        sensorEvent.dataEvent.addHandler { (innerData) -> () in
            compleation(data: innerData as! T)
        }
    }
    
    public func registerListener(compleation:(data:T)->Void, withName name:String){
        sensorEvent.dataEvent.addHandler({ (innerData) -> () in
            compleation(data: innerData as! T)
            }, withName: name)
    }
    
    public func unregisterListener(name:String){
        sensorEvent.dataEvent.removeHandler(name)
    }
    
    public func on(){
        sensorEvent.turnOnCommand.trigger()
    }
    
    public func off(){
        sensorEvent.turnOffCommand.trigger()
    }
}


public class Sensors{
    
    public let accelerometer:SensorHolder<AccelerometerData>
    public let temperature:SensorHolder<TemperatureData>
    public let humidity:SensorHolder<HumidityData>
    public let magnetometer:SensorHolder<MagnetometerData>
    public let gyroscope:SensorHolder<GyroscopeData>
    public let barometer:SensorHolder<BarometerData>
    public let ambientLight:SensorHolder<AmbientLightData>
    public let calories:SensorHolder<CaloriesData>
    public let gsr:SensorHolder<GsrData>
    public let pedometer:SensorHolder<PedometerData>
    public let heartRate:SensorHolder<HeartRateData>
    public let skinTemperature:SensorHolder<SkinTemperatureData>
    public let uv:SensorHolder<UVData>


    
    init(events: SystemEvents){
        accelerometer = SensorHolder<AccelerometerData>(sensorEvent: events.getSensorEvents(.Accelerometer))
        temperature = SensorHolder<TemperatureData>(sensorEvent: events.getSensorEvents(.Temperature))
        humidity = SensorHolder<HumidityData>(sensorEvent: events.getSensorEvents(.Humidity))
        magnetometer = SensorHolder<MagnetometerData>(sensorEvent: events.getSensorEvents(.Magnetometer))
        gyroscope = SensorHolder<GyroscopeData>(sensorEvent: events.getSensorEvents(.Gyroscope))
        ambientLight = SensorHolder<AmbientLightData>(sensorEvent: events.getSensorEvents(.AmbientLight))
        calories = SensorHolder<CaloriesData>(sensorEvent: events.getSensorEvents(.Calories))
        gsr = SensorHolder<GsrData>(sensorEvent: events.getSensorEvents(.Gsr))
        pedometer = SensorHolder<PedometerData>(sensorEvent: events.getSensorEvents(.Pedometer))
        heartRate = SensorHolder<HeartRateData>(sensorEvent: events.getSensorEvents(.HeartRate))
        skinTemperature = SensorHolder<SkinTemperatureData>(sensorEvent: events.getSensorEvents(.SkinTemperature))
        uv = SensorHolder<UVData>(sensorEvent: events.getSensorEvents(.UV))
        barometer = SensorHolder<BarometerData>(sensorEvent: events.getSensorEvents(.Barometer))
    }
    
    
}