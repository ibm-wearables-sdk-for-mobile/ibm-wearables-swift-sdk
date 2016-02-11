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
import IBMMobileEdge


public class MicrosoftBand : DeviceConnector, MSBClientManagerDelegate{
    
    var client: MSBClient!
    
    public override init(){
        super.init()
        self.deviceName = "Microsoft Band"
        MSBClientManager.sharedManager().delegate = self
    }
    
    override public func getSupportedSensors() -> [SensorType]{
        return [.Accelerometer,.AmbientLight,.Calories,.Gyroscope,.Gsr,.Pedometer,.HeartRate,.SkinTemperature,.Barometer]
    }
    
    override public func connect(connectionStatusDelegate:ConnectionStatusDelegate!){
        super.connect(connectionStatusDelegate)
        
        if let client = MSBClientManager.sharedManager().attachedClients().first as? MSBClient {
            self.client = client
            
            MSBClientManager.sharedManager().connectClient(self.client)
        } else {
            updateConnectionStatus(.DeviceUnavailable)
        }
    }
    
    override public func disconnect(){
        if let currentClient = client {
            MSBClientManager.sharedManager().cancelClientConnection(currentClient)
        }
    }
    
    override public func registerForEvents(systemEvents: SystemEvents){
        registerAccelerometerEvents(systemEvents.getSensorEvents(.Accelerometer))
        registerAmbientLightEvents(systemEvents.getSensorEvents(.AmbientLight))
        registerCaloriesEvents(systemEvents.getSensorEvents(.Calories))
        registerGyroscopeEvents(systemEvents.getSensorEvents(.Gyroscope))
        registerGsrEvents(systemEvents.getSensorEvents(.Gsr))
        registerPedometerEvents(systemEvents.getSensorEvents(.Pedometer))
        registerHeartRateEvents(systemEvents.getSensorEvents(.HeartRate))
        registerSkinTemperatureEvents(systemEvents.getSensorEvents(.SkinTemperature))
        registerBarometerEvents(systemEvents.getSensorEvents(.Barometer))
    }
    
    public func clientManager(clientManager: MSBClientManager!, clientDidConnect client: MSBClient!) {
        updateConnectionStatus(.Connected)
    }
    
    public func clientManager(clientManager: MSBClientManager!, clientDidDisconnect client: MSBClient!) {
        updateConnectionStatus(.Disconnected)
    }
    
    public func clientManager(clientManager: MSBClientManager!, client: MSBClient!, didFailToConnectWithError error: NSError!) {
        updateConnectionStatus(.DeviceUnavailable)
    }
    
    private func registerAccelerometerEvents(accelerometerEvents:SensorEvents){
    
        accelerometerEvents.turnOnCommand.addHandler { (Void) -> () in
            _ = try? self.client.sensorManager.startAccelerometerUpdatesToQueue(nil, withHandler: { (data, error) in
                
                let accelerometedData = AccelerometerData()
                accelerometedData.x = data.x
                accelerometedData.y = data.y
                accelerometedData.z = data.z
                
                accelerometerEvents.dataEvent.trigger(accelerometedData)
            })
        }
        
        accelerometerEvents.turnOffCommand.addHandler { (Void) -> () in
            _ = try? self.client.sensorManager.stopAccelerometerUpdatesErrorRef()
        }
    }
    
    private func registerAmbientLightEvents(ambientLightEvents:SensorEvents){
        
        ambientLightEvents.turnOnCommand.addHandler { () -> () in
            _ = try? self.client.sensorManager.startAmbientLightUpdatesToQueue(nil, withHandler: { (data, error) in
                
                let ambientLightData = AmbientLightData()
                ambientLightData.brightness = Int(data.brightness);
                
                ambientLightEvents.dataEvent.trigger(ambientLightData)
            })
        }
        
        ambientLightEvents.turnOffCommand.addHandler { (Void) -> () in
            _ = try? self.client.sensorManager.stopAmbientLightUpdatesErrorRef()
        }
    }
    
    private func registerCaloriesEvents(caloriesEvents:SensorEvents){
        
        caloriesEvents.turnOnCommand.addHandler { () -> () in
            _ = try? self.client.sensorManager.startCaloriesUpdatesToQueue(nil, withHandler: { (data, error) -> Void in
                
                let caloriesData = CaloriesData()
                caloriesData.calories = data.calories
                
                caloriesEvents.dataEvent.trigger(caloriesData)
                
            })
        }
        
        caloriesEvents.turnOffCommand.addHandler { () -> () in
            _ = try? self.client.sensorManager.stopCaloriesUpdatesErrorRef()
        }
    }
    
    private func registerGyroscopeEvents(gyroscopeEvents:SensorEvents){
        
        gyroscopeEvents.turnOnCommand.addHandler { () -> () in
            _ = try? self.client.sensorManager.startGyroscopeUpdatesToQueue(nil, withHandler: { (data, error) -> Void in
                
                let gyroscopeData = GyroscopeData()
                gyroscopeData.x = data.x
                gyroscopeData.y = data.y
                gyroscopeData.z = data.z
                
                gyroscopeEvents.dataEvent.trigger(gyroscopeData)
                
            })
        }
        
        gyroscopeEvents.turnOffCommand.addHandler { () -> () in
            _ = try? self.client.sensorManager.stopGyroscopeUpdatesErrorRef()
        }
    }
    
    private func registerGsrEvents(gsrEvents:SensorEvents){
        
        gsrEvents.turnOnCommand.addHandler { () -> () in
            _ = try? self.client.sensorManager.startGSRUpdatesToQueue(nil, withHandler: { (data, error) -> Void in
                
                let gsrData = GsrData()
                gsrData.resistance = data.resistance
                
                gsrEvents.dataEvent.trigger(gsrData)
                
            })
        }
        
        gsrEvents.turnOffCommand.addHandler { () -> () in
            _ = try? self.client.sensorManager.stopCaloriesUpdatesErrorRef()
        }
    }
    
    private func registerPedometerEvents(pedometerEvents:SensorEvents){
        
        pedometerEvents.turnOnCommand.addHandler { () -> () in
            _ = try? self.client.sensorManager.startPedometerUpdatesToQueue(nil, withHandler: { (data, error) -> Void in
                
                let pedometerData = PedometerData()
                pedometerData.steps = UInt(data.totalSteps)
                
                pedometerEvents.dataEvent.trigger(pedometerData)
            })
        }
        
        pedometerEvents.turnOffCommand.addHandler { () -> () in
            _ = try? self.client.sensorManager.stopPedometerUpdatesErrorRef()
        }
    }
    
    private func registerSkinTemperatureEvents(skinTemperatureEvents:SensorEvents){
        
        skinTemperatureEvents.turnOnCommand.addHandler { () -> () in
            _ = try? self.client.sensorManager.startSkinTempUpdatesToQueue(nil, withHandler: { (data, error) -> Void in
                
                let skinTemperatureData = SkinTemperatureData()
                skinTemperatureData.temperature = data.temperature
                
                skinTemperatureEvents.dataEvent.trigger(skinTemperatureData)
                
            })
        }
        
        skinTemperatureEvents.turnOffCommand.addHandler { () -> () in
            _ = try? self.client.sensorManager.stopSkinTempUpdatesErrorRef()
        }
    }
    
    private func registerHeartRateEvents(heartRateEvents:SensorEvents){
        
        heartRateEvents.turnOnCommand.addHandler { () -> () in
            
            
            func updateHeartRate(){
                _ = try? self.client.sensorManager.startHeartRateUpdatesToQueue(nil, withHandler: { (data, error) -> Void in
                    
                    let heartRateData = HeartRateData()
                    
                    heartRateData.heartRate = data.heartRate
                    
                    heartRateEvents.dataEvent.trigger(heartRateData)
                    
                })
            }
            
            let consent = self.client.sensorManager.heartRateUserConsent()
            
            switch (consent){
            case .Granted:
                updateHeartRate()
                
            case .NotSpecified:
                
                //Ask for permition
                self.client.sensorManager.requestHRUserConsentWithCompletion({ (isGrunted, error) -> Void in
                    if (isGrunted){
                        updateHeartRate()
                    }
                })
                
            case .Declined:
                
                //Nothing to do
                break;
            };
        }
        
        heartRateEvents.turnOffCommand.addHandler { () -> () in
            _ = try? self.client.sensorManager.stopHeartRateUpdatesErrorRef()
        }
    }
    
    private func registerUVEvents(uvEvents:SensorEvents){
        
        uvEvents.turnOnCommand.addHandler { () -> () in
            _ = try? self.client.sensorManager.startUVUpdatesToQueue(nil, withHandler: { (data, error) -> Void in
                
                let uvData = UVData()
                uvData.indexLevel = data.uvIndexLevel.rawValue
                uvEvents.dataEvent.trigger(uvData)
                
            })
        }
        
        uvEvents.turnOffCommand.addHandler { () -> () in
            _ = try? self.client.sensorManager.stopCaloriesUpdatesErrorRef()
        }
    }
    
    private func registerBarometerEvents(barometerEvents:SensorEvents){
        
        barometerEvents.turnOnCommand.addHandler { () -> () in
            _ = try? self.client.sensorManager.startBarometerUpdatesToQueue(nil, withHandler: { (data, error) -> Void in
                
                let barometerData = BarometerData()
                barometerData.airPressure = data.airPressure
                barometerData.temperature = data.temperature
                
                barometerEvents.dataEvent.trigger(barometerData)
            })
        }
        
        barometerEvents.turnOffCommand.addHandler { () -> () in
            _ = try? self.client.sensorManager.stopBarometerUpdatesErrorRef()
        }
    }

    
}
