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


public class SensorTag : BLEDeviceConnector {
    
    
    private let motionSensorPeriodOperation = "motionSensorPeriod"
    private let accelerometerRangeOperation = "accelerometerRange";
    
    //holds the global state of the motion sensor data characteristic
    private var motionSensorConfigData = OperationDataHolder(data:[0x00, 0x00])
    private var motionSensorPeriodData = OperationDataHolder(data:[0x0A]) //100 ms

    private var accelerometerRange:UInt8 = 2;
    
    public init(){
        super.init(deviceName: "SensorTag")
    
        //Accelerometer Data
        let accelerometerConfigData = declareNewSensorData(SensorType.Accelerometer, withID: "F000AA80-0451-4000-B000-000000000000")
        accelerometerConfigData.setConvertFunction(convertAccelerometerData)
        accelerometerConfigData.defineCharacteristicOperation(notifyOnOperation, operation: BLEOperationType.NotifyOn("F000AA81-0451-4000-B000-000000000000"))
        accelerometerConfigData.defineCharacteristicOperation(turnOnOperation, operation: BLEOperationType.SetValueWithOR("F000AA82-0451-4000-B000-000000000000",motionSensorConfigData,[0x38, 0x0])) //00111000
        accelerometerConfigData.defineCharacteristicOperation(turnOffOperation, operation: BLEOperationType.SetValueWithAND("F000AA82-0451-4000-B000-000000000000",motionSensorConfigData, [0xC7, 0xFF])) //11000111
        accelerometerConfigData.defineCharacteristicOperation(motionSensorPeriodOperation, operation: BLEOperationType.SetDynamicValue("F000AA83-0451-4000-B000-000000000000",motionSensorPeriodData))
        accelerometerConfigData.defineCharacteristicOperation(accelerometerRangeOperation, operation: BLEOperationType.SetDynamicValue("F000AA82-0451-4000-B000-000000000000", motionSensorConfigData))

        //Temperature Data
        let temperatureConfigData = declareNewSensorData(SensorType.Temperature, withID: "F000AA00-0451-4000-B000-000000000000")
        temperatureConfigData.setConvertFunction(convertTemperatureData)
        temperatureConfigData.defineCharacteristicOperation(notifyOnOperation, operation: BLEOperationType.NotifyOn("F000AA01-0451-4000-B000-000000000000"))
        temperatureConfigData.defineCharacteristicOperation(notifyOffOperation, operation: BLEOperationType.NotifyOff("F000AA01-0451-4000-B000-000000000000"))
        temperatureConfigData.defineCharacteristicOperation(turnOnOperation, operation: BLEOperationType.SetValue("F000AA02-0451-4000-B000-000000000000",[1]))
        temperatureConfigData.defineCharacteristicOperation(turnOffOperation, operation: BLEOperationType.SetValue("F000AA02-0451-4000-B000-000000000000",[0]))

        //Humidity Data
        let humidityConfigData = declareNewSensorData(SensorType.Humidity, withID: "F000AA20-0451-4000-B000-000000000000")
        humidityConfigData.setConvertFunction(convertHumidityData)
        humidityConfigData.defineCharacteristicOperation(notifyOnOperation, operation: BLEOperationType.NotifyOn("F000AA21-0451-4000-B000-000000000000"))
        humidityConfigData.defineCharacteristicOperation(notifyOffOperation, operation: BLEOperationType.NotifyOff("F000AA21-0451-4000-B000-000000000000"))
        humidityConfigData.defineCharacteristicOperation(turnOnOperation, operation: BLEOperationType.SetValue("F000AA22-0451-4000-B000-000000000000",[1]))
        humidityConfigData.defineCharacteristicOperation(turnOffOperation, operation: BLEOperationType.SetValue("F000AA22-0451-4000-B000-000000000000",[0]))
        
        
        //Magnetometer Data
        let magnetometerData = declareNewSensorData(SensorType.Magnetometer, withID: "F000AA80-0451-4000-B000-000000000000")
        magnetometerData.setConvertFunction(convertMagnetometerData)
        magnetometerData.defineCharacteristicOperation(notifyOnOperation, operation: BLEOperationType.NotifyOn("F000AA81-0451-4000-B000-000000000000"))
        magnetometerData.defineCharacteristicOperation(turnOnOperation, operation: BLEOperationType.SetValueWithOR("F000AA82-0451-4000-B000-000000000000",motionSensorConfigData,[0x40, 0x0])) //0100 0000
        magnetometerData.defineCharacteristicOperation(turnOffOperation, operation: BLEOperationType.SetValueWithAND("F000AA82-0451-4000-B000-000000000000",motionSensorConfigData,[0xBF, 0xFF])) //1011 1111
        
        
        //Gyroscope Data
        let gyroscopeData = declareNewSensorData(.Gyroscope, withID: "F000AA80-0451-4000-B000-000000000000")
        gyroscopeData.setConvertFunction(convertGyroscopeData)
        gyroscopeData.defineCharacteristicOperation(notifyOnOperation, operation: BLEOperationType.NotifyOn("F000AA81-0451-4000-B000-000000000000"))
        gyroscopeData.defineCharacteristicOperation(turnOnOperation, operation: BLEOperationType.SetValueWithOR("F000AA82-0451-4000-B000-000000000000",motionSensorConfigData,[0x07, 0x0])) //0000 0111
        gyroscopeData.defineCharacteristicOperation(turnOffOperation, operation: BLEOperationType.SetValueWithAND("F000AA82-0451-4000-B000-000000000000",motionSensorConfigData,[0xF8, 0xFF])) //1111 1000

    }
    
    
    //can be 2,4,8 or 16
    public func setAccelerometerRange(range:UInt8){
        accelerometerRange = range
        motionSensorConfigData.data[1] = range
        executeOperation(accelerometerRangeOperation, forType: .Accelerometer)
    }
    
    public func setMotionSensorPeriod(period:UInt8){
        motionSensorPeriodData.data[0] = period
        executeOperation(motionSensorPeriodOperation, forType: .Accelerometer)
    }
    
    override public func registerForEvents(systemEvents: SystemEvents){
        super.registerForEvents(systemEvents)
        
        //set the default values of sensor
        setAccelerometerRange(8)    //set the default to 8G
        setMotionSensorPeriod(0x0A) //set the default to 100ms
    }
    
    
    //called once for each supported sensor
    override func registerEventsForSensor(sensorType:SensorType, withSensorEvents sensorEvents:SensorEvents){
        sensorEvents.turnOnCommand.addHandler { () -> () in
            self.sensorNotificationOn(sensorType)
        }
        
        sensorEvents.turnOffCommand.addHandler { () -> () in
            self.sensorNotificationOff(sensorType)
        }
    }

    override func onDataChangedForType(type: SensorType, data: BaseSensorData) {
        systemEvents.getSensorEvents(type).dataEvent.trigger(data);
    }

    func sensorNotificationOn(type:SensorType){

        //set notify to true and turn the sensor on
        executeOperations([notifyOnOperation,turnOnOperation], forType: type)
    }

    func sensorNotificationOff(type:SensorType){

        //turn the sensor off
        executeOperations([turnOffOperation], forType: type)
    }
    
    private func convertMotionData(data:NSData) -> [Int16]{
        
        let count = data.length
        var array = [Int16](count: count, repeatedValue: 0)
        data.getBytes(&array, length:count * sizeof(Int16))
        
        return array
    }


    func convertAccelerometerData(data:NSData) -> BaseSensorData {
        
        let accelerometerData = AccelerometerData()
        let array = convertMotionData(data)
        
        let accelerometerScale = 32768.0 / Double(accelerometerRange)
        let xIndex:Int = 3
        let yIndex:Int = 4
        let zIndex:Int = 5
        
        accelerometerData.x = Double(array[xIndex]) / accelerometerScale
        accelerometerData.y = Double(array[yIndex]) / accelerometerScale
        accelerometerData.z = Double(array[zIndex]) / accelerometerScale
        
        return accelerometerData;
    }
    
    func convertGyroscopeData(data:NSData) -> BaseSensorData {
        
        let gyroscopeData = GyroscopeData()
        let array = convertMotionData(data)
        
        let gyroScale:Double = (65536.0 / 500.0)
        
        let xIndex:Int = 0
        let yIndex:Int = 1
        let zIndex:Int = 2
        
        gyroscopeData.x = Double(array[xIndex]) / gyroScale
        gyroscopeData.y = Double(array[yIndex]) / gyroScale
        gyroscopeData.z = Double(array[zIndex]) / gyroScale
        
        return gyroscopeData
    }
    
    //conver the data to uT (micro Tesla).
    func convertMagnetometerData(data:NSData) -> BaseSensorData {
        let magnetometerData = MagnetometerData()
        
        let array = convertMotionData(data)
        let xIndex:Int = 6
        let yIndex:Int = 7
        let zIndex:Int = 8
        
        magnetometerData.x = Double(array[xIndex])
        magnetometerData.y = Double(array[yIndex])
        magnetometerData.z = Double(array[zIndex])
        
        return magnetometerData
    }

    func convertTemperatureData(data:NSData) -> BaseSensorData {
        let temperatureData = TemperatureData()
        
        let ambientTemperature = Float(getAmbientTemperature(data))

        temperatureData.temperature = Double(getObjectTemperature(data,ambientTemperature: Double(ambientTemperature)))

        return temperatureData
    }
    
    // Get ambient temperature value
    func getAmbientTemperature(value : NSData) -> Double {
        let dataFromSensor = dataToSignedBytes16(value)
        let ambientTemperature = Double(dataFromSensor[1])/128
        return ambientTemperature
    }
    
    // Get object temperature value
    func getObjectTemperature(value : NSData, ambientTemperature : Double) -> Double {
        let dataFromSensor = dataToSignedBytes16(value)
        let Vobj2 = Double(dataFromSensor[0]) * 0.00000015625
        
        let Tdie2 = ambientTemperature + 273.15
        let Tref  = 298.15
        
        let S0 = 6.4e-14
        let a1 = 1.75E-3
        let a2 = -1.678E-5
        let b0 = -2.94E-5
        let b1 = -5.7E-7
        let b2 = 4.63E-9
        let c2 = 13.4
        
        let S = S0*(1+a1*(Tdie2 - Tref)+a2*pow((Tdie2 - Tref),2))
        let Vos = b0 + b1*(Tdie2 - Tref) + b2*pow((Tdie2 - Tref),2)
        let fObj = (Vobj2 - Vos) + c2*pow((Vobj2 - Vos),2)
        let tObj = pow(pow(Tdie2,4) + (fObj/S),0.25)
        
        let objectTemperature =  tObj.isNaN ? -999 : (tObj - 273.15)
        
        return objectTemperature
    }
    
    func dataToSignedBytes16(value : NSData) -> [Int16] {
        let count = value.length
        var array = [Int16](count: count, repeatedValue: 0)
        value.getBytes(&array, length:count * sizeof(Int16))
        return array
    }
    
    func dataToUnsignedBytes16(value : NSData) -> [UInt16] {
        
        /*
        print(value)
        let count = value.length
        var array = [UInt16](count: count, repeatedValue: 0)
        value.getBytes(&array, length:count * sizeof(UInt16))
        return array
        */
        
        
        // the number of elements:
        let count = value.length / sizeof(UInt16)
        
        // create array of appropriate length:
        var array = [UInt16](count: count, repeatedValue: 0)
        
        // copy bytes into array
        value.getBytes(&array, length:count * sizeof(UInt16))
        
        return array
    }

    func convertHumidityData(data:NSData) -> BaseSensorData {
        
        let humidityData = HumidityData()
        
        let dataFromSensor = dataToUnsignedBytes16(data)
        
        //let swappedValue = Double(CFSwapInt16(dataFromSensor[1]))
        humidityData.humidity = (Double(dataFromSensor[1]) / 65536) * 100
        
        return humidityData
    }
    
}

