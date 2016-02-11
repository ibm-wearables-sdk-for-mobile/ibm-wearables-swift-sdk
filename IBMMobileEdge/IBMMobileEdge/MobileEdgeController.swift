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


public enum ConnectionStatus {
    case Connected
    case Disconnected
    case BluetoothUnavailable
    case DeviceUnavailable
}

public class MobileEdgeController{
    
    public let sensors:Sensors
    public var delegate:ConnectionStatusDelegate?
    private let events: SystemEvents
    
    public init(){
        self.events = SystemEvents()
        self.sensors = Sensors(events: events)
    }
    
    public func connect(deviceDriver: DeviceConnector){
        deviceDriver.registerForEvents(events)
        deviceDriver.connect(delegate)
    }
    
    public func dissconect(deviceDriver: DeviceConnector){
        deviceDriver.disconnect()
    }
    
    public func registerInterpretation(interpretation:BaseInterpretation){
        interpretation.registerForEvents(sensors)
    }
    
    public func registerInterpretation(interpretation:BaseInterpretation, withListener listener:InterpretationListener){
        interpretation.registerListener(listener)
        interpretation.registerForEvents(sensors)
    }
    
    public func unregisterInterpretation(interpretation:BaseInterpretation){
        interpretation.unregisterEvents(sensors)
    }
}


public protocol ConnectionStatusDelegate{
    func connectionStatusChanged(deviceName:String, withStatus status:ConnectionStatus)
}
