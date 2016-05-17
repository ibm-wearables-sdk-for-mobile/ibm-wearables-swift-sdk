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
    var tableIndexForOperation:NSIndexPath!
    
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
            tableData.append(Data(name: name, sensativity: SensitivityUtils.get(name),isDisabled: SensitivityUtils.isDisabled(name)))
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
    
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?  {
        
        var enableDisableAction:UITableViewRowAction!
        
        //hold the index for the current operation
        tableIndexForOperation = indexPath
        
        if (tableData[tableIndexForOperation.row].isDisabled){
            enableDisableAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Enable" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
                self.setGestureDisableStatus(indexPath,isDisabled: false)
            })
        }
        
        else{
            enableDisableAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Disable" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
                let dataToDisable = self.tableData[indexPath.row]
                self.confirmDisable(dataToDisable.name)
            })
        }
       
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            
            let dataToDelete = self.tableData[indexPath.row]
            self.confirmDelete(dataToDelete.name)
        })
        
        return [enableDisableAction,deleteAction]
    }
    
    
    
    /*
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            tableIndexToDelete = indexPath
            let dataToDelete = tableData[indexPath.row]
            confirmDelete(dataToDelete.name)
        }
    }
    */
    
    func confirmDelete(gestureName: String) {
        let alert = UIAlertController(title: "Delete Gesture", message: "Are you sure you want to delete \(gestureName)?", preferredStyle: .ActionSheet)
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: handleDeleteGesture)
        let CancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: handleCancelOfOperation)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func confirmDisable(gestureName: String) {
        let alert = UIAlertController(title: "Disable Gesture", message: "Are you sure you want to disable \(gestureName)?", preferredStyle: .ActionSheet)
        
        let DeleteAction = UIAlertAction(title: "Disable", style: .Destructive, handler: handleDisableGesture)
        let CancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: handleCancelOfOperation)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func handleDeleteGesture(alertAction: UIAlertAction!) -> Void {
        
        //first delete the file from local storage
        FileUtils.deleteJSFile(tableData[tableIndexForOperation.row].name)
        
        //unload the gesture from the JS code
        JSEngine.instance.executeMethod("removeGesture", payload: tableData[tableIndexForOperation.row].name)
        
        //update the UI
        table.beginUpdates()
        tableData.removeAtIndex(tableIndexForOperation.row)
        
        table.deleteRowsAtIndexPaths([tableIndexForOperation], withRowAnimation: .Automatic)
        tableIndexForOperation = nil
        table.endUpdates()
    }
    
    func setGestureDisableStatus(rowIndex:NSIndexPath, isDisabled:Bool){
        tableData[tableIndexForOperation.row].isDisabled = isDisabled
        
        print(tableIndexForOperation.row)
        table.reloadRowsAtIndexPaths([tableIndexForOperation], withRowAnimation: .Right)
        //table.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
        //table.reloadData()
    }
    
    func handleDisableGesture(alertAction: UIAlertAction!) -> Void {
        setGestureDisableStatus(tableIndexForOperation, isDisabled: true)
    }
    
    
    func handleCancelOfOperation(alertAction: UIAlertAction!) {
        tableIndexForOperation = nil
    }
}
