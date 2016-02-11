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
import JavaScriptCore


public class JSEngine{
    
    public static let instance = JSEngine()
    let jsContext = JSContext()
    var loadedFileNames = Set<String>()
    
    private init() {
        
        //catch all the JS errors
        jsContext.exceptionHandler = { context, exception in
            print("JS Error: \(exception)")
        }
        
        //debug output
        let simplifyString: @convention(block) String -> String = { input in
            
            let result = input.stringByApplyingTransform(NSStringTransformToLatin, reverse: false)
            print("Debug: \(result!)")
            
            return result?.stringByApplyingTransform(NSStringTransformStripCombiningMarks, reverse: false) ?? ""
        }
        jsContext.setObject(unsafeBitCast(simplifyString, AnyObject.self), forKeyedSubscript: "debug")
    }
    
    public func loadJSFromPath(filePath:String){
        
        //load the file only if it not loaded yet
        if (!loadedFileNames.contains(filePath)){
            let jsFileContent = try! String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
            jsContext.evaluateScript(jsFileContent)
            
            loadedFileNames.insert(filePath)
        }
    }
    
    public func loadJS(fileName:String){
            
            //first look for the file in the application
            if let path = NSBundle.mainBundle().pathForResource(fileName, ofType:"js") {
              
                loadJSFromPath(path)
            }
            
            //later look for the file in the framework
            else{
                let frameworkBundle = NSBundle.allFrameworks().filter { (bundle) -> Bool in
                    return bundle.bundlePath.containsString("IBMMobileEdge.framework")
                    }.first
                
                if (frameworkBundle != nil){
                    if let path = frameworkBundle!.pathForResource(fileName, ofType:"js") {
                        
                        loadJSFromPath(path)
                    }
                }
            }
    }
    
    public func executeMethod(methodName:String, payload:AnyObject) -> JSValue{
        
        let testFunction = jsContext.objectForKeyedSubscript(methodName)
        let result = testFunction.callWithArguments([payload])
        
        return result
    }
}