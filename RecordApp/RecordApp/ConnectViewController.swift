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
import IBMMobileEdge

class ConnectViewController: UIViewController, ConnectionStatusDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var statusLable: UILabel!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var connectButton: UIButton!
    
    let controller = AppDelegate.controller
    
    var pickerData = [DeviceConnector]()
    var selectedDeviceIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        controller.delegate = self

        spinner.stopAnimating()
        statusLable.hidden = true
        
        setUpConnectors()
    }
    
    func setUpConnectors(){
        for connector in AppDelegate.applicationConnectors{
            pickerData.append(connector)
        }
    }
    
    @IBAction func onConnectButtonClicked(sender: AnyObject) {
        
        if (pickerData.count > 0){
            performConnection()
        }
        
        else{
            Utils.showMsgDialog(self, withMessage: "You have not defined any connectors. Please refer to the wiki page (at GitHub.com) for detailed instructions");
        }
    }
    
    func performConnection(){
        connectButton.enabled = false
        spinner.startAnimating()
        statusLable.hidden = false
        
        statusLable.text = "Connecting to \(pickerData[selectedDeviceIndex].deviceName)..."
        
        //connect to the selected device
        controller.connect(pickerData[selectedDeviceIndex])
    }
    
    func connectionStatusChanged(deviceName: String, withStatus status: ConnectionStatus) {
        
        spinner.stopAnimating()
        statusLable.hidden = true
        
        switch status{
        case .Connected:
            self.performSegueWithIdentifier("moveToMain", sender: self)
            
        case .Disconnected:
            Utils.showMsgDialog(self, withMessage:"Device Dissconected")
            connectButton.enabled = true
            
        case .BluetoothUnavailable:
            Utils.showMsgDialog(self, withMessage:"Bluetooth Unavailable")
            connectButton.enabled = true
            
        case .DeviceUnavailable:
            Utils.showMsgDialog(self, withMessage:"Device Unavailable")
            connectButton.enabled = true
        }
    }
    
    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row].deviceName
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedDeviceIndex = row
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: pickerData[row].deviceName, attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        return attributedString
    }
}
