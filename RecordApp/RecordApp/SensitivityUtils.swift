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

//handle the sensitivity values
class SensitivityUtils {
    
    static let prefs = NSUserDefaults.standardUserDefaults()
    
    static func set(name:String, sensitivity:Double){
        prefs.setDouble(sensitivity, forKey: name)
    }
    
    static func delete(name:String){
        prefs.removeObjectForKey(name)
        prefs.removeObjectForKey(getStatusPrefName(name))
    }
    
    static func get(name:String) -> Double{
        return prefs.doubleForKey(name)
    }
    
    static func setDisableStatus(name:String, isDisabled:Bool){
        prefs.setBool(isDisabled, forKey: getStatusPrefName(name))
    }
    
    static func isDisabled(name:String) -> Bool{
        return prefs.boolForKey(getStatusPrefName(name))
    }
    
    static private func getStatusPrefName(name:String) -> String{
        return "\(name)_status"
    }
}