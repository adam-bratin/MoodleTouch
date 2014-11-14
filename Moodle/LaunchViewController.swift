//
//  LaunchViewController.swift
//  Moodle
//
//  Created by Adam Bratin on 11/11/14.
//  Copyright (c) 2014 Bratin. All rights reserved.
//

import UIKit
import CoreData

class LaunchViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet var serverPicker : UIPickerView!
    var pickerData = []
    @IBAction func connectToServer(button : UIButton) {
        let selectedServer : Int = self.serverPicker.selectedRowInComponent(0)
//        let vc : webViewController = webViewController(domainNew: self.pickerData[selectedServer].domain)
        let vc : webViewController = self.storyboard?.instantiateViewControllerWithIdentifier(Constants.webViewController) as webViewController
        vc.domain = self.pickerData[selectedServer].domain
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func addServer(button : UIButton) {
        let vc : LoginViewController = self.storyboard?.instantiateViewControllerWithIdentifier(Constants.loginViewControllerIdentifier) as LoginViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
        }()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
//        println(managedObjectContext!)
        let fetchRequest = NSFetchRequest(entityName: Constants.serverItemIdentifier)
        var error: NSError? = nil
        self.pickerData = managedObjectContext!.executeFetchRequest(fetchRequest, error:&error) as [Server]
        if(self.pickerData.count == 0) {
            self.pickerData = ["No Servers"]
        }
        self.serverPicker.delegate = self
        self.serverPicker.dataSource = self
        self.serverPicker.selectRow(0, inComponent: 0, animated: true)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        let fetchRequest = NSFetchRequest(entityName: Constants.serverItemIdentifier)
        var error: NSError? = nil
        self.pickerData = managedObjectContext!.executeFetchRequest(fetchRequest, error:&error) as [Server]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerData.count
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if(self.pickerData[row] is Server) {
            let server : Server = self.pickerData[row] as Server
            return server.domain
        } else {
            return self.pickerData[row] as String
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
    }
}