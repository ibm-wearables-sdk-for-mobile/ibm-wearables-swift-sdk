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

//cell to display the data and the sensitivity values
class DataCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var sensativity: UITextField!
    
    var sourceData:Data!
    
    func setData(data:Data){
        sourceData = data
        name.text = data.name
        sensativity.text = "\(data.sensitivity)"
        
        name.enabled = !data.isDisabled
        sensativity.enabled = !data.isDisabled
        
        //will update the status in the prefs
        SensitivityUtils.setDisableStatus(sourceData.name, isDisabled: data.isDisabled)
    }

    @IBAction func onSensitivityChanged(sender: AnyObject) {
        sourceData.sensitivity = Double(sensativity.text!)!
        
        //change the sensativity pref
        SensitivityUtils.set(sourceData.name, sensitivity: sourceData.sensitivity)
    }
}
