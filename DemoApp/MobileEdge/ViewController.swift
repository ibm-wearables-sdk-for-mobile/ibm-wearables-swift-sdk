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


import UIKit
import CoreBluetooth
import IBMMobileEdge
import AVFoundation

class ViewController: UIViewController, ConnectionStatusDelegate{
    
    @IBOutlet weak var x: UILabel!
    @IBOutlet weak var y: UILabel!
    @IBOutlet weak var z: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var accelerometerSwitch: UISwitch!
    @IBOutlet weak var diconnectButton: UIButton!
    @IBOutlet weak var connectButton: UIButton!
    
    var device:DeviceConnector = SensorTag()  //Can be replace with 'Gemsense' or 'MicrosoftBand
    let controller = MobileEdgeController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.stopAnimating()
        diconnectButton.hidden = true
        controller.delegate = self
        
        controller.sensors.accelerometer.registerListener(updateAccelerometerUIData)
        controller.registerInterpretation(FallDetection(), withListener: fallDetected)
    }
    
    @IBAction func disconnectButtonClicked(sender: AnyObject) {
        
        //disconnect from the device
        device.disconnect()
    }
    
    @IBAction func onConnectButtonClicked(sender: AnyObject) {
        spinner.startAnimating()
        
        //start connection to the device
        controller.connect(device)
    }
    
    @IBAction func onAccelerometerSwitchChanged(sender: AnyObject) {
        if (accelerometerSwitch.on){
            controller.sensors.accelerometer.on()
        }
        else{
            controller.sensors.accelerometer.off()
        }
    }
    
    //notification about connection status change
    func connectionStatusChanged(deviceName: String, withStatus status: ConnectionStatus) {
        
        spinner.stopAnimating()
        switch status{
        case .Connected:
            print("Connected to \(deviceName)")
            connectButton.hidden = true
            diconnectButton.hidden = false
            
        case .Disconnected:
            showMobileEdgeDialog("Device Dissconected")
            connectButton.hidden = false
            diconnectButton.hidden = true
            
        case .BluetoothUnavailable:
            showMobileEdgeDialog("Bluetooth Unavailable")
            
            
        case .DeviceUnavailable:
            showMobileEdgeDialog("Device Unavailable")
        }
    }
    
    //this function will be called once a fall of the device is detected
    func fallDetected(additonalInfo: AnyObject!) {
        showMobileEdgeDialog("Falling movement of the device was detected!")
    }
    
    //this function will be called every time the accelerometer data is changed
    func updateAccelerometerUIData(data: AccelerometerData){
        x.text = "\(Float(data.x))"
        y.text = "\(Float(data.y))"
        z.text = "\(Float(data.z))"
    }
    
    func showMobileEdgeDialog(message:String){
        
        let alert = UIAlertController(title: "Demo Application", message: message, preferredStyle: .Alert)
        let continueAction = UIAlertAction(title: "Continue", style: .Default, handler: nil)
        alert.addAction(continueAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

