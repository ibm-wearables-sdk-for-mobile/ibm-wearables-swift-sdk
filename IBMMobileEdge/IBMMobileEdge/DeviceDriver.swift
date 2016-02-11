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


public class DeviceConnector : NSObject {

    public var deviceName = ""
    public var connectionStatusDelegate:ConnectionStatusDelegate!
    

    public func connect(connectionStatusDelegate:ConnectionStatusDelegate!){
        self.connectionStatusDelegate = connectionStatusDelegate
    }

    public func disconnect(){

    }

    public func registerForEvents(systemEvents: SystemEvents){

    }

    public func getSupportedSensors() -> [SensorType]{
        return []
    }

    public func updateConnectionStatus(status:ConnectionStatus){
        if let delegate = connectionStatusDelegate {
            delegate.connectionStatusChanged(deviceName , withStatus: status)
        }
    }
}
