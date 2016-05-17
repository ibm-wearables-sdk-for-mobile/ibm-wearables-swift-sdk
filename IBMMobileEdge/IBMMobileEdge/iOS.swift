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
import CoreMotion


public class iOS: DeviceConnector{
    
    let manager = CMMotionManager()
    
    public override init(){
        super.init()
        self.deviceName = "iOS"
        
        //manager.gyroUpdateInterval = 0.016
        //manager.accelerometerUpdateInterval = 0.016
        
        //print(manager.gyroUpdateInterval)
        //print(manager.accelerometerUpdateInterval)
    }
    
    override public func getSupportedSensors() -> [SensorType]{
        return [.Accelerometer,.Gyroscope]
    }
    
    
    override public func connect(connectionStatusDelegate:ConnectionStatusDelegate!){
        super.connect(connectionStatusDelegate)
        updateConnectionStatus(.Connected)
    }
    
    override public func disconnect(){
        self.manager.stopAccelerometerUpdates()
        self.manager.stopGyroUpdates()
        updateConnectionStatus(.Disconnected)
    }
    
    override public func registerForEvents(systemEvents: SystemEvents){
        registerAccelerometerEvents(systemEvents.getSensorEvents(.Accelerometer))
        registerGyroscopeEvents(systemEvents.getSensorEvents(.Gyroscope))
    }
    
    private func registerAccelerometerEvents(accelerometerEvents:SensorEvents){
        
        //register turn on operation
        accelerometerEvents.turnOnCommand.addHandler { () -> () in
            
            if (self.manager.accelerometerAvailable){
                self.manager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (data, error) -> Void in
                    
                    let accelerometerData = AccelerometerData()
                    
                    accelerometerData.x = (data?.acceleration.x)!
                    accelerometerData.y = (data?.acceleration.y)!
                    accelerometerData.z = (data?.acceleration.z)!
                    
                    accelerometerEvents.dataEvent.trigger(accelerometerData)
                })
            }
        }
        
        //register turn off operation
        accelerometerEvents.turnOffCommand.addHandler { () -> () in
            self.manager.stopAccelerometerUpdates()
        }
    }
    
    private func registerGyroscopeEvents(gyroscopeEvents:SensorEvents){
        
        //register turn on operation
        gyroscopeEvents.turnOnCommand.addHandler { () -> () in
            if self.manager.gyroAvailable {
                
                self.manager.startGyroUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (data, error) -> Void in
                    let gyroscopeData = GyroscopeData()
                    
                    //convert from rad to deg
                    gyroscopeData.x = (data?.rotationRate.x)! * 57.2958
                    gyroscopeData.y = (data?.rotationRate.y)! * 57.2958
                    gyroscopeData.z = (data?.rotationRate.z)! * 57.2958
                    
                    gyroscopeEvents.dataEvent.trigger(gyroscopeData)
                })
            }
        }
        
        //register turn off operation
        gyroscopeEvents.turnOffCommand.addHandler { () -> () in
            self.manager.stopGyroUpdates()
        }
    }
}