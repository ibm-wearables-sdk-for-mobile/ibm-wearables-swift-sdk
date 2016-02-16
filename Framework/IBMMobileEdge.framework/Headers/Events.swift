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


public class Command{

    public typealias CommandHandler = Void -> ()
    private var handlers = [CommandHandler]()
    
    public func addHandler(handler:CommandHandler){
        handlers.append(handler)
    }
    
    public func trigger(){
        for command in handlers{
            command()
        }
    }
}

public class Event<T> {
    
    public typealias EventHandler = T -> ()
    private var eventHandlers = [EventHandler]()
    private var eventHandlersDictionary = [String:EventHandler]()
    
    public func addHandler(handler:EventHandler) {
        eventHandlers.append(handler)
    }
    
    public func addHandler(handler:EventHandler, withName name:String){
        eventHandlersDictionary[name] = handler
    }
    
    public func removeHandler(name:String){
        eventHandlersDictionary.removeValueForKey(name)
    }
    
    public func trigger(data:T) {
        
        //first iterate the handlers without name
        for handler in eventHandlers {
            handler(data)
        }
        
        //then iterate the handlers with name
        for (_,handler) in eventHandlersDictionary {
            handler(data)
        }
    }
}

public class SensorEvents {
    
    public let turnOnCommand = Command()
    public let turnOffCommand = Command()
    public let dataEvent = Event<BaseSensorData>()
}

public class SystemEvents {
    
    private var eventsMap = [SensorType:SensorEvents]()
    
    //lazy init
    public func getSensorEvents(type:SensorType) -> SensorEvents{
        
        if let events = eventsMap[type] {
            return events
        }
        
        else{
            let events = SensorEvents()
            eventsMap[type] = events
            return events
        }
    }
}