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
import GemSDK
import IBMMobileEdge


public class Gemsense : DeviceConnector, GemScanDelegate, GemDelegate {
    
    var gemManager:GemManager!
    var gem:Gem!
    
    var accelerometerDataEvents:SensorEvents!
    var gyroscopeDataEvents:SensorEvents!
    var pedometerDataEvents:SensorEvents!
    
    var isAccelerometrEnabled = false
    var isGyroscopeEnabled = false
    
    var isTryingToConnect = false
    var isReady = false
    
    override init(){
        super.init()
        gemManager = GemManager.sharedInstace()
        gemManager.delegate = self
    }
    
    override public func connect(connectionStatusDelegate:ConnectionStatusDelegate!){
        self.connectionStatusDelegate = connectionStatusDelegate
    
        isTryingToConnect = true
        
        //connect only if ready, if not it will be connected at the isReady callback
        if isReady{
           handleConnection()
        }
    }
    
    override public func disconnect(){
        gemManager.disconnectGem(self.gem)
    }
    
    override public func registerForEvents(systemEvents: SystemEvents){
        accelerometerDataEvents = systemEvents.getSensorEvents(.Accelerometer)
        gyroscopeDataEvents = systemEvents.getSensorEvents(.Gyroscope)
        pedometerDataEvents = systemEvents.getSensorEvents(.Pedometer)
        
        
        //accelerometer
        accelerometerDataEvents.turnOnCommand.addHandler { () -> () in
            self.isAccelerometrEnabled = true
        }
        
        accelerometerDataEvents.turnOffCommand.addHandler { () -> () in
            self.isAccelerometrEnabled = false
        }
        
        //gyroscope
        gyroscopeDataEvents.turnOnCommand.addHandler { () -> () in
            self.isGyroscopeEnabled = true
        }
        
        gyroscopeDataEvents.turnOffCommand.addHandler { () -> () in
            self.isGyroscopeEnabled = false
        }
        
        //pedometer
        pedometerDataEvents.turnOnCommand.addHandler { () -> () in
            if let connectedGem = self.gem {
                self.gemManager.enablePedometer(connectedGem)
            }
        }
        
        pedometerDataEvents.turnOffCommand.addHandler { () -> () in
            if let connectedGem = self.gem {
                self.gemManager.disablePedometer(connectedGem)
            }
        }
    }
    
    override public func getSupportedSensors() -> [SensorType]{
        return [.Accelerometer,.Gyroscope,.Pedometer]
    }
    
    public func onDeviceDiscovered(gem: Gem!, rssi: NSNumber!) {
        
        NSLog("Gemsense discovered: " + gem.getName())
        
        self.gem = gem
        self.gem.delegate = self
        
        gemManager.connectGem(self.gem)
    }
    
    
    public func onErrorOccurred(error: NSError!) {
        print("Gemsense Error: " + error.localizedDescription)
    }
    
    public func onInitializationError(error: InitializationError){
        print("Gemsense Error: \(error)")
    }
    
    public func onReady() {
        print("Gemsense onReady called")
        isReady = true
        
        if isTryingToConnect{
            handleConnection()
        }
    }
    
    func handleConnection(){
        if let current = gem{
            gemManager.connectGem(current)
        }
        else{
            //start scanning
            gemManager.startScan()
        }
    }
    
    public func onStateChanged(state: GemState) {
        
        switch(state)
        {
            
        case.Connected:
            updateConnectionStatus(.Connected)
            gemManager.enableRawData(self.gem)
            print("Gemsense Connected")
            
        case.Connecting:
            print("Gemsense Connecting")
            
        case.Disconnected:
            isTryingToConnect = false
            updateConnectionStatus(.Disconnected)
            print("Gemsense Disconnected")
            
        case.Disconnecting:
            print("Gemsense Disconnecting")
        }
    }
    
    public func onRawData(data: GemRawData!) {
        
        if (isAccelerometrEnabled){
            triggerAccelerometerDataUpdate(data)
        }
        
        if (isGyroscopeEnabled){
            triggerGyroscopeDataUpdate(data)
        }
    }
    
    public func onPedometerData(steps: UInt32, walkTime: Float){
        
        let pedometerData = PedometerData()
        pedometerData.steps = UInt(steps)
        
        pedometerDataEvents.dataEvent.trigger(pedometerData)
    }
    
    func triggerAccelerometerDataUpdate(data: GemRawData!){
        
        let accelerometerData = AccelerometerData()
        
        accelerometerData.x = data.acceleration[0].doubleValue
        accelerometerData.y = data.acceleration[1].doubleValue
        accelerometerData.z = data.acceleration[2].doubleValue
        
        accelerometerDataEvents.dataEvent.trigger(accelerometerData)
    }
    
    func triggerGyroscopeDataUpdate(data: GemRawData!){
        
        let gyroscopeData = GyroscopeData()
        
        gyroscopeData.x = data.gyroscope[0].doubleValue
        gyroscopeData.y = data.gyroscope[1].doubleValue
        gyroscopeData.z = data.gyroscope[2].doubleValue
        
        gyroscopeDataEvents.dataEvent.trigger(gyroscopeData)
    }

}