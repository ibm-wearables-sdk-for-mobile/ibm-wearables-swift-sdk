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

class TestingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var table: UITableView!
    
    var tableData = [Data]()
    var tableIndexToDelete:NSIndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateData()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(animated: Bool){
        updateData()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.table.reloadData()
        })
    }
    
    //update the table data
    func updateData(){
        tableData.removeAll()
        
        //get the updated list of files
        for name in FileUtils.getJsFileNames(){
            tableData.append(Data(name: name, withSensativity: SensitivityUtils.get(name)))
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "DataCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! DataCell
        
        let data = tableData[indexPath.row]
        
        cell.setData(data)
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            tableIndexToDelete = indexPath
            let dataToDelete = tableData[indexPath.row]
            confirmDelete(dataToDelete.name)
        }
    }
    
    func confirmDelete(gestureName: String) {
        let alert = UIAlertController(title: "Delete Gesture", message: "Are you sure you want to delete \(gestureName)?", preferredStyle: .ActionSheet)
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: handleDeleteGesture)
        let CancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: cancelDeleteGesture)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func handleDeleteGesture(alertAction: UIAlertAction!) -> Void {
        
        //first delete the file from local storage
        FileUtils.deleteJSFile(tableData[tableIndexToDelete.row].name)
        
        //unload the gesture from the JS code
        JSEngine.instance.executeMethod("removeGesture", payload: tableData[tableIndexToDelete.row].name)
        
        //update the UI
        table.beginUpdates()
        tableData.removeAtIndex(tableIndexToDelete.row)
        
        table.deleteRowsAtIndexPaths([tableIndexToDelete], withRowAnimation: .Automatic)
        tableIndexToDelete = nil
        table.endUpdates()
    }
    
    func cancelDeleteGesture(alertAction: UIAlertAction!) {
        tableIndexToDelete = nil
    }
}
