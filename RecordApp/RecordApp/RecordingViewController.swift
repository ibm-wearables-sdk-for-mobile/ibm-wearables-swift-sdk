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

class RecordingViewController: UIViewController {

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var iterationLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var counter: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    var timer:NSTimer!
    var counterValue = 3
    let controller = AppDelegate.controller
    var id = ""
    var url = ""
    var uuid = ""
    var gesuteCouner = 1
    var recordingDots = 0
    var sensitivity:Double!
    var temp:NSString!
    let accelerometerListenerName = "accelerometerListener"
    let gyroscopeListenerName = "gyroscopeListener"
    var isDataSyncronizationDone = false
    var logFile = ""
    let minimunNumberOfIterations = 4 //minmum number of iteration before the user can save the gesture
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = AppDelegate.trainingGestureName
        
        statusLabel.hidden = true
        
        continueButton.hidden = false
        stopButton.hidden = true
        
        id = ""
        url = ""
        uuid = ""
        gesuteCouner = 1
        sensitivity = nil
        
        logFile = LogUtils.createFileForNewGesture(AppDelegate.trainingGestureName)
        
        startCounter()
    }
    
    func startCounter(){
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "runCounterCode", userInfo: nil, repeats: true)
        
        spinner.stopAnimating()
        
        imageView.hidden = true
        continueButton.hidden = true
        stopButton.hidden = true
        
        disableButtons()
        
        //handle the counter
        counterValue = 3
        counter.hidden = false
        counter.text = "\(counterValue)"
        
        setStatusText("Get Ready")
        setIterationNumber(gesuteCouner)
    }
    
    func runCounterCode(){
        
        if (counterValue == 1){
            
            counter.hidden = true
            
            startRecording()
            timer.invalidate()
        }
            
        else{
            counter.text = "\(counterValue-1)"
            counterValue--
        }
    }
    
    func startRecording(){
        pauseButton.hidden = false
        
        enableButtons()
        
        //clear the previous data
        print("Clean")
        AppDelegate.accelerometerRecordData.removeAll()
        AppDelegate.gyroscopeRecordData.removeAll()
        
        //turn on the sensonrs again
        turnSensorsOn()
        
        spinner.startAnimating()
        status.hidden = false
        
        
        setStatusText("Recording")
    }
    
    override func viewDidAppear(animated: Bool){
        super.viewDidAppear(animated)
        
        //clear the old data
        print("Clean")
        AppDelegate.accelerometerRecordData.removeAll()
        AppDelegate.gyroscopeRecordData.removeAll()
        
        
        controller.sensors.accelerometer.registerListener(accelerometerDataChanged, withName:accelerometerListenerName)
        controller.sensors.gyroscope.registerListener(gyroscopeDataChanged, withName: gyroscopeListenerName)
    }

    override func viewDidDisappear(animated: Bool){
        super.viewDidDisappear(animated)
        
        turnSensorsOff()
        
        controller.sensors.accelerometer.unregisterListener(accelerometerListenerName)
        controller.sensors.gyroscope.unregisterListener(gyroscopeListenerName)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "moveToFinal"
        {
            if let resultViewController = segue.destinationViewController as? ResultViewController{
                
                resultViewController.url = url
                resultViewController.uuid = uuid
                resultViewController.sensitivity = sensitivity
            }
        }
    }
    
    func setStatusText(text:String){
        status.text = text
    }
    
    func setIterationNumber(iteration:Int){
        iterationLabel.text = "Iteration \(iteration)"
    }
    
    func accelerometerDataChanged(data:AccelerometerData) {
        AppDelegate.accelerometerRecordData.append([data.x,data.y,data.z])
        makeDataRateCorrection()
    }
    
    func gyroscopeDataChanged(data:GyroscopeData){
        AppDelegate.gyroscopeRecordData.append([data.x,data.y,data.z])
        makeDataRateCorrection()
    }
    
    //fix the data leght so that the data will synsconized
    func makeDataRateCorrection(){
        
        let accelerometerLength = AppDelegate.accelerometerRecordData.count
        let gyroscopeLength = AppDelegate.gyroscopeRecordData.count
        
        //data syncronization done only after the first set of readings (check when one leght of the data is equal to 4)
        if (!isDataSyncronizationDone && gyroscopeLength > 3 && accelerometerLength > 3){
            
            //need to dropt the first acceleroment data so that the data will be of the same legth (syncronized)
            if (accelerometerLength > gyroscopeLength){
                AppDelegate.accelerometerRecordData.removeFirst(accelerometerLength - gyroscopeLength)
                print("Info: data syncronization fix. droped first \(accelerometerLength - gyroscopeLength) reads of accelerometer")
            }
            
            else if (gyroscopeLength > accelerometerLength){
                AppDelegate.gyroscopeRecordData.removeFirst(gyroscopeLength - accelerometerLength)
                print("Info: data syncronization fix. droped first \(gyroscopeLength - accelerometerLength) reads of gyroscope")
            }
            
            isDataSyncronizationDone = true
        }
    }
    
    @IBAction func onStopButtonClicked(sender: AnyObject) {
        turnSensorsOff()
        self.performSegueWithIdentifier("moveToFinal", sender: self)
    }
    
    @IBAction func onPauseButtonClicked(sender: AnyObject) {
        
        disableButtons()
        continueButton.hidden = true
        status.hidden = false
        
        setStatusText("Validating")
        turnSensorsOff()
        
        //validate the the date usign the service
        RequestUtils.sendTrainRequest(AppDelegate.accelerometerRecordData, gyroscopeData: AppDelegate.gyroscopeRecordData, uuid: id, onSuccess: onTrainRequestSuccess, onFailure: onTrainRequestError)
    }
    
    func disableButtons(){
        pauseButton.enabled = false
        pauseButton.alpha = 0.5
        
        continueButton.enabled = false
        continueButton.alpha = 0.5
    }
    
    func enableButtons() {
        pauseButton.enabled = true
        pauseButton.alpha = 1
        
        continueButton.enabled = true
        continueButton.alpha = 1
    }
    
    
    func turnSensorsOn(){
        print("On")
        
        //this will enable data syncronization again
        isDataSyncronizationDone = false
        
        controller.sensors.accelerometer.on()
        controller.sensors.gyroscope.on()
    }
    
    func turnSensorsOff(){
        print("Off")
        controller.sensors.accelerometer.off()
        controller.sensors.gyroscope.off()
    }
    
    @IBAction func onContinueButtonClicked(sender: AnyObject) {
        startCounter()
    }
    
    //this function is called after each succesul recorded iteration
    func onTrainRequestSuccess(result:NSDictionary!){
        
        if let url = result["jsURI"] {
            self.url = url as! String
        }
        
        if let id = result["id"] {
            self.id = id as! String
        }
        
        if let uuid = result["UUID"] {
            self.uuid = "\(uuid)"//id as! String
        }
        
        if let sensitivity = result["sensitivity"] {
            self.sensitivity = Double(sensitivity as! String)
        }
        
        if let sensitivity = result["sensitivity"], let length = result["length"]{
            dispatch_async(dispatch_get_main_queue()) {
                self.statusLabel.hidden = false
                self.statusLabel.text = "Currect sensitivity: \(sensitivity). Lenght: \(length)"
            }
        }
        
        //save the current iteration to a log file
        print("save the data to log")
        LogUtils.saveLog(logFile, iterationNumber: gesuteCouner, accelerometerDataArray: AppDelegate.accelerometerRecordData, gyroscopeDataArray: AppDelegate.gyroscopeRecordData)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.spinner.stopAnimating()
            
            self.enableButtons()
            
            self.setStatusText("Iteration Accepted!")
            
            self.imageView.hidden = false
            self.imageView.image = UIImage(named: "success")
            self.continueButton.hidden = false
            self.gesuteCouner++
            
            if (self.gesuteCouner > self.minimunNumberOfIterations){
                self.stopButton.hidden = false
            }
        }
    }
    
    //this function is called in case the recorded iteration was rejected
    func onTrainRequestError(msg:String!){
        
        dispatch_async(dispatch_get_main_queue()) {
            
            self.spinner.stopAnimating()
            self.enableButtons()
            self.continueButton.hidden = false
            self.setStatusText("Iteration Failed!")
            self.imageView.hidden = false
            self.imageView.image = UIImage(named: "failure")
            
            Utils.showMsgDialog(self, withMessage:msg)
        }
    }
}
