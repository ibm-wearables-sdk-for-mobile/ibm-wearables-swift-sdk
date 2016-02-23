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


//Log the raw data of the recorded gestures
class LogUtils {
    
    
    static func createFileForNewGesture(gestureName:String) -> String{
        
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        
        let content = "\(gestureName),"
        let path = getDocumentsDirectory().stringByAppendingPathComponent("Log_\(gestureName)_\(formatter.stringFromDate(date))).csv")
        
        writeToFile(path, content: content)
        
        return path
    }
    
    static func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    static func saveLog(path:String, iterationNumber:Int, accelerometerDataArray:[[Double]], gyroscopeDataArray:[[Double]]){
     
        //let fileName = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("Log_\(gestureName).csv")
        
        var content = "\niteration\(iterationNumber),\n"
        
        for (index,element) in gyroscopeDataArray.enumerate() {
            
            content.appendContentsOf("\(element[0]),\(element[1]),\(element[2]),\(accelerometerDataArray[index][0]),\(accelerometerDataArray[index][1]),\(accelerometerDataArray[index][2])\n")
        }
        
        updateFile(path, content: content)
        
        //csvString.appendContentsOf()
        
    }
    
    static func readFromFile(path:String) -> String{
        do {
            let content = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
            return content
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
        return ""
    }
    
    static func writeToFile(path:String, content:String){
        do {
            try content.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    
    static func updateFile(path:String, content:String){
        var previousContent = readFromFile(path)
        previousContent.appendContentsOf(content)
        
        writeToFile(path, content: previousContent)
    }
}
