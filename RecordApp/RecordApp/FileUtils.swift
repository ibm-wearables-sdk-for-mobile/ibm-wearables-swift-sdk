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

class FileUtils {
    
    
    //get file path of a gesture file by name
    static func getFilePath(name:String) -> String{
        return (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("\(name).js")
    }

    //get all the gesture file names
    static func getJsFileNames() -> [String]{
        
        var fileNames = [String]()
        let filemanager = NSFileManager()
        let files = filemanager.enumeratorAtPath(NSTemporaryDirectory())
        
        while let file = files?.nextObject() {
            
            let nameWithoutExtension = String((file as! String).characters.dropLast(3))
            fileNames.append(nameWithoutExtension)
        }
        
        return fileNames
    }
    
    //get all gestures file paths
    static func getAllFilePaths() -> [String]{
        
        var filePaths = [String]()
        
        for name in getJsFileNames(){
            filePaths.append(getFilePath(name))
        }
        
        return filePaths
    }
    
    //delete gesture file by name
    static func deleteJSFile(name:String){
        let filemanager = NSFileManager()
        try! filemanager.removeItemAtPath(getFilePath(name))
    }
}