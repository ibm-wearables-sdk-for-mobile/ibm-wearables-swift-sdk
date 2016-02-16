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



/*
public class ComposedServiceConfigData{
    var types = [SensorType]()
    var id:CBUUID
    
    public init(id:String, withTypes types:[SensorType]){
        self.id = CBUUID(string: id)
        self.types = types
    }
    
    public func defineCharacteristicOperation(type:SensorType, operationTag:String, operation:BLEOperationType){
        
    }
    
    
}
*/


public class BLEDeviceConnector: DeviceConnector, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    //common operations
    public let turnOnOperation = "turnOn"
    public let turnOffOperation = "turnOff"
    public let notifyOnOperation = "notifyOn"
    public let notifyOffOperation = "notifyOff"
    
    var centralManager : CBCentralManager!
    var peripheral : CBPeripheral!
    var sensorsManager:SensorsManager = SensorsManager()
    //var connectionStatusDelegate:ConnectionStatusDelegate!
    var supportedSensors = [SensorType]()
    var systemEvents: SystemEvents!
    
    var discoveringServicesSet:Set<CBUUID> = Set<CBUUID>() //holds the runtime services that are beeing discoved now
    
    init(deviceName:String){
        super.init()
        self.deviceName = deviceName
    }
    
    override public func connect(connectionStatusDelegate:ConnectionStatusDelegate!){
        self.connectionStatusDelegate = connectionStatusDelegate
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    override public func disconnect() {
        centralManager.cancelPeripheralConnection(peripheral)
    }

    override public func registerForEvents(systemEvents: SystemEvents){
        self.systemEvents = systemEvents
        
        for sensorType in getSupportedSensors(){
            let sensorEvents = systemEvents.getSensorEvents(sensorType)
            registerEventsForSensor(sensorType, withSensorEvents: sensorEvents)
        }
    }
    
    func registerEventsForSensor(sensorType:SensorType, withSensorEvents: SensorEvents){
        preconditionFailure("This method must be overridden")
    }

    override public func getSupportedSensors() -> [SensorType]{
        return supportedSensors
    }
    
    func declareNewSensorData(type:SensorType, withID id:String) -> ServiceConfigData{
        let configData = ServiceConfigData(id: id, withType: type)
        sensorsManager.addData(configData)
        supportedSensors.append(type)
        
        return configData
    }

    /*
    func updateConnectionStatus(status:ConnectionStatus){
        if let delegate = connectionStatusDelegate{
            delegate.connectionStatusChanged(self.deviceName , withStatus: status)
        }
    }
    */
    
    public func centralManagerDidUpdateState(central: CBCentralManager) {
        
        if central.state == CBCentralManagerState.PoweredOn {
            debugPrint("Start Scanning...")
            // Scan for peripherals if BLE is turned on
            central.scanForPeripheralsWithServices(nil, options: nil)
        }
        else {
            updateConnectionStatus(.BluetoothUnavailable)
        }
    }
    
    public func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?){
        sensorsManager.clearDiscoveredTypes()
        updateConnectionStatus(.Disconnected)
    }
    
    // Check out the discovered peripherals
    public func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        debugPrint("Found Device \(peripheral)")
        
        if (peripheral.description.containsString(deviceName)){
            
            debugPrint("Found device \(deviceName)")
            
            central.stopScan()
            
            //save reference to the dicovered peripheral
            self.peripheral = peripheral
            
            //set the delegate to the connector
            peripheral.delegate = self
            central.connectPeripheral(peripheral, options: nil) //automatically connect
        }
    }

    public func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        //auto discover services of the connected peripheral
        debugPrint("Connected to \(peripheral.name)")
        
        updateConnectionStatus(ConnectionStatus.Connected)
        
        //discover all the services in pending list
        for senesorType in sensorsManager.getSensorTypesPendingForConnection(){
            dicoverServiceOfType(senesorType)
        }
    }
    

    func executeOperation(operationTag:String, forType type:SensorType){
        
        //log the types of operations
        logOperation(operationTag, forType: type)
        
        //add the operation to pending list
        sensorsManager.addPendingOperation(operationTag, forType: type)
        
        //if connected to peripheral
        if (peripheral != nil && peripheral.state == CBPeripheralState.Connected){
            if (sensorsManager.isTypeDiscovered(type)){
                executePendingOperationsForType(type)
            }
                
            else{
                dicoverServiceOfType(type)
            }
        }
            
        //if not connected to peripheral yet
        else {
            //add type to the pending list of discovery. the services of this type with all the characterstics will be dicovered after connection
            sensorsManager.addSensorTypeToConnectionPendingList(type)
        }
    }

    //eceture single operation for a spesific type
    func executeOperations(operations:[String], forType type:SensorType){
        for tag in operations{
            executeOperation(tag, forType: type)
        }
    }
    
    //log the sensor power status by the operations types
    func logOperation(operationTag:String, forType type:SensorType){
        
        if (operationTag == turnOnOperation){
            sensorsManager.logSensorPowerStatus(type, isOn: true)
        }
        
        else if (operationTag == turnOffOperation){
            sensorsManager.logSensorPowerStatus(type, isOn: false)
        }
    }


    public func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
        for service in peripheral.services! {
            let thisService = service as CBService
            
            discoveringServicesSet.remove(thisService.UUID)

            debugPrint("Found Service \(thisService)")

            peripheral.discoverCharacteristics(nil, forService: service) //discover all the characteristics
        }
    }

    
    // Enable notification and sensor for each characteristic of valid service
    public func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        debugPrint("Dicovered All Characteristic for Service \(service.description)")
        
        //get the type of the service
        let discoveredTypes = sensorsManager.getSensorType(service.UUID)
        
        for type in discoveredTypes{
            //set the sensor as discovered
            sensorsManager.setTypeAsDiscovered(type)
            
            //get the type and then execute all the pendindg opeartions
            executePendingOperationsForType(type)
        }
    }
    

    func dicoverServiceOfType(type:SensorType){

        //get the service ID from the type
        let serviceId = sensorsManager.getServiceId(type)

        //dicover service only if it is not beening discovered
        if (!discoveringServicesSet.contains(serviceId)){
            debugPrint("Dicovering services of Sensor of type \(type)")
            peripheral.discoverServices([serviceId])
            discoveringServicesSet.insert(serviceId)
        }
    }

    func executePendingOperationsForType(type:SensorType){

        if let pendingOperations = sensorsManager.getPendingOperations(type){
            for operation in pendingOperations{
                executeOperation(type,operation: operation)
            }
        }
    }
    
    func executeOperation(type:SensorType, operation:BLEOperationType){
        
        switch operation{
        case .NotifyOn(let characteristicId):
            let characteristic = getCharacteristicById(type, characteristicId: characteristicId)
            debugPrint("Set Notify to True for \(characteristic.description)")
            peripheral.setNotifyValue(true, forCharacteristic: characteristic)
            
        case .NotifyOff(let characteristicId):
            let characteristic = getCharacteristicById(type, characteristicId: characteristicId)
            debugPrint("Set Notify to False for \(characteristic.description)")
            peripheral.setNotifyValue(false, forCharacteristic: characteristic)
            
        case .SetValue(let characteristicId, let valueToSet):
            let characteristic = getCharacteristicById(type, characteristicId: characteristicId)
            debugPrint("Write value \(valueToSet) for \(characteristic.description)")
            peripheral.writeValue(NSData(bytes: valueToSet, length: valueToSet.count), forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithResponse)
            //TODO: handle the responce from the write value
            
        case .SetValueWithAND(let characteristicId, let value, let ANDmask):
            let characteristic = getCharacteristicById(type, characteristicId: characteristicId)
            var valueToSet:[UInt8] = []
            for (value, mask) in zip(value.data,ANDmask) {
                valueToSet.append(value & mask)
            }
            debugPrint("Write value \(valueToSet) (\(value.data) AND \(ANDmask)) for \(characteristic.description)")
            
            value.data = valueToSet
            peripheral.writeValue(NSData(bytes: valueToSet, length: valueToSet.count), forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithResponse)
            
        case .SetValueWithOR(let characteristicId, let value, let ORmask):
            let characteristic = getCharacteristicById(type, characteristicId: characteristicId)
            var valueToSet:[UInt8] = []
            for (value, mask) in zip(value.data,ORmask) {
                valueToSet.append(value | mask)
            }
            debugPrint("Write value \(valueToSet) (\(value.data) OR \(ORmask)) for \(characteristic.description)")
            
            value.data = valueToSet
            peripheral.writeValue(NSData(bytes: valueToSet, length: valueToSet.count), forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithResponse)
            
            
        case .SetDynamicValue(let characteristicId, let value):
            let characteristic = getCharacteristicById(type, characteristicId: characteristicId)
            debugPrint("Write value \(value.data) for \(characteristic.description)")
            peripheral.writeValue(NSData(bytes: value.data, length: value.data.count), forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithResponse)
        }
        
        sensorsManager.removeFirstPendingOperation(type)
    }
    
    func getCharacteristicById(type:SensorType, characteristicId:String) -> CBCharacteristic!{
        
        let serviceId = sensorsManager.getServiceId(type)
        let characteristicId = CBUUID(string: characteristicId)
        
        if let services = peripheral.services{
            for service in services{
                if let characteristics = service.characteristics where service.UUID == serviceId{
                    for characteristic in characteristics{
                        if (characteristic.UUID == characteristicId){
                            return characteristic
                        }
                    }
                }
            }
        }
        
        return nil
    }


    public func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        // find all the sensor types that are match the service id
        let types = sensorsManager.getSensorType(characteristic.service.UUID)
        
        //execute the convert function for each powered on sensor
        for type in types{
            if (sensorsManager.isSensorOn(type)){
                
                let convertFuncResult = sensorsManager.executeConvertFunctionForType(type, withData: characteristic.value!)
                
                //delegate the answer
                onDataChangedForType(type, data: convertFuncResult)
            }
        }
    }
    
    
    func onDataChangedForType(type:SensorType, data:BaseSensorData){
        preconditionFailure("This method must be overridden")
    }
}

