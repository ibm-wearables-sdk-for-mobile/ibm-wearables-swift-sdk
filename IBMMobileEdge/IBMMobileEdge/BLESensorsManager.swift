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
import CoreBluetooth

public class ServiceConfigData{
    
    var type:SensorType
    var id:CBUUID
    var operationsMap = [String:BLEOperationType]()
    var isOn:Bool
    
    var convertFunction:((NSData) -> BaseSensorData)!
    
    public init(id:String, withType type:SensorType){
        self.id = CBUUID(string: id)
        self.type = type
        isOn = false
    }
    
    public func defineCharacteristicOperation(operationTag:String, operation:BLEOperationType){
        if let _ = operationsMap[operationTag]{
            debugPrint("Warning! operation \(operationTag) already defined!")
        }
        operationsMap[operationTag] = operation
    }
    
    public func getOperationByTag(tag:String) -> BLEOperationType{
        return operationsMap[tag]!
    }
    
    public func setConvertFunction(convertFunction:(NSData) -> BaseSensorData){
        self.convertFunction = convertFunction
    }
}


class SensorsManager{
    
    var allSensorsMap = [SensorType:ServiceConfigData]()
    var discoveredTypes = Set<SensorType>()
    var pendingOperations = [SensorType:[BLEOperationType]]()  //list of the operation to execute per type
    var pendingServicesForConnect = [SensorType]()
    
    func addData(data:ServiceConfigData){
        allSensorsMap[data.type] = data
    }
    
    func getSensorType(serviceId:CBUUID) -> [SensorType]{
        var matchTypes = [SensorType]()
        
        for key in allSensorsMap.keys{
            if allSensorsMap[key]?.id == serviceId {
                matchTypes.append(key)
            }
        }
        return matchTypes
    }
    
    func getServiceId(type:SensorType) -> CBUUID! {
        return allSensorsMap[type]?.id
    }
    
    func setTypeAsDiscovered(type:SensorType){
        discoveredTypes.insert(type)
    }
    
    func isTypeDiscovered(type:SensorType) -> Bool{
        return discoveredTypes.contains(type)
    }
    
    func clearDiscoveredTypes(){
        discoveredTypes = Set<SensorType>()
    }
    
    func getPendingOperations(type:SensorType) -> [BLEOperationType]!{
        return pendingOperations[type]
    }
    
    func addPendingOperation(operationTag:String, forType type:SensorType){
        
        //find the operation type and add it to the list
        let operation = allSensorsMap[type]?.getOperationByTag(operationTag)
        
        if (pendingOperations[type] == nil){
            pendingOperations[type] = []
        }
        
        pendingOperations[type]?.append(operation!)
    }
    
    func removeFirstPendingOperation(type:SensorType){
        pendingOperations[type]!.removeFirst()
    }
    
    func addSensorTypeToConnectionPendingList(type:SensorType){
        if (!pendingServicesForConnect.contains(type)){
            pendingServicesForConnect.append(type)
        }
    }
    
    func removeSensorTypeFromConnectionPendingList(type:SensorType){
        if (pendingServicesForConnect.contains(type)){
            let index = pendingServicesForConnect.indexOf(type)
            pendingServicesForConnect.removeAtIndex(index!)
        }
    }
    
    func getSensorTypesPendingForConnection() -> [SensorType]{
        return pendingServicesForConnect //change to sensor types pending for connection
    }
    
    func executeConvertFunctionForType(type:SensorType, withData data:NSData) -> BaseSensorData {
        return (allSensorsMap[type]?.convertFunction(data))!
    }
    
    func logSensorPowerStatus(type:SensorType, isOn:Bool){
        allSensorsMap[type]?.isOn = isOn
    }
    
    func isSensorOn(type:SensorType) -> Bool{
        return (allSensorsMap[type]?.isOn)!
    }
    
    
}
