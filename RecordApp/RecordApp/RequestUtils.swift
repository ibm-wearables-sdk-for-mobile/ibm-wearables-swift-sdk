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


class RequestUtils {

    static func sendValidationRequest(code:String, onSuccess:Void->Void, onFailure:Void->Void){
        
        print("sendValidationRequest")
        
        let newPost: NSDictionary = ["code": code]
        
        let postsEndpoint: String = "https://medge.mybluemix.net/alg/validateCode"
        
        guard let postsURL = NSURL(string: postsEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        
        let postsUrlRequest = NSMutableURLRequest(URL: postsURL)
        postsUrlRequest.HTTPMethod = "POST"
        
        do {
            let jsonPost = try! NSJSONSerialization.dataWithJSONObject(newPost, options: [])
            postsUrlRequest.HTTPBody = jsonPost
            
            postsUrlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: config)
            
            let task = session.dataTaskWithRequest(postsUrlRequest, completionHandler: {
                (data, response, error) in
                guard let responseData = data else {
                    onFailure()
                    return
                }

                let post: NSDictionary
                do {
                    post = try NSJSONSerialization.JSONObjectWithData(responseData, options: []) as! NSDictionary
                } catch  {
                    print("error parsing response from POST on /posts")
                    return
                }
                
                print("The post is: " + post.description)
                
                if let ok = post["ok"]{
                    
                    if (ok as! Bool == true){
                        onSuccess()
                    }
                    else{
                        onFailure()
                    }
                }
                
                else{
                    onFailure()
                }
                
            })
            task.resume()
        }
    }
    
    
    static func sendTrainRequest(accelerometerData:[[Double]], gyroscopeData:[[Double]], uuid:String, onSuccess:NSDictionary!->Void, onFailure:String!->Void){
        
        print("sendTrainRequest")
        
        var payload = Dictionary<String,AnyObject>()
        
        payload["accelerometer"] = accelerometerData
        payload["gyroscope"] = gyroscopeData
        
        let gestureName = AppDelegate.trainingGestureName
        
        let newPost: NSDictionary = ["name": gestureName,
            "id": uuid,
            "description": "nodescription",
            "imageFile": "nofile",
            "videoFile": "nofile",
            "rawData":  payload,
            "metaData": false,
            "isPublic": false]
        
        let postsEndpoint: String = "https://medge.mybluemix.net/alg/train"
        
        guard let postsURL = NSURL(string: postsEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        
        let postsUrlRequest = NSMutableURLRequest(URL: postsURL)
        postsUrlRequest.HTTPMethod = "POST"
        
        do {
            let jsonPost = try! NSJSONSerialization.dataWithJSONObject(newPost, options: [])
            postsUrlRequest.HTTPBody = jsonPost
            
            postsUrlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            //print(newPost)
            
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: config)
            
            let task = session.dataTaskWithRequest(postsUrlRequest, completionHandler: {
                (data, response, error) in
                guard let responseData = data else {
                    onFailure("No date receive from the request")
                    return
                }

                let post: NSDictionary
                do {
                    post = try NSJSONSerialization.JSONObjectWithData(responseData, options: []) as! NSDictionary
                } catch  {
                    print("error parsing response from POST on /posts")
                    return
                }

                print("The post is: " + post.description)
                
                if let error = post["error"]{
                    onFailure(error as! String)
                    return
                }
                
                onSuccess(post)
            })
            task.resume()
        }
    }

    
}