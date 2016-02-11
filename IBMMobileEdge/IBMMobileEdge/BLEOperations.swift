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


//operation for the sensors
public enum BLEOperationType{
    case NotifyOn(String)
    case NotifyOff(String)
    case SetValue(String,[UInt8])
    case SetValueWithAND(String, OperationDataHolder, [UInt8])
    case SetValueWithOR(String, OperationDataHolder, [UInt8])
    case SetDynamicValue(String, OperationDataHolder)
}

public class OperationDataHolder {
    public var data:[UInt8] = [];
    
    public init(data:[UInt8]){
        self.data = data;
    }
}