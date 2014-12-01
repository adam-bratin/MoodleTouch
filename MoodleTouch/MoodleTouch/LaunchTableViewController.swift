//
//  LaunchTableViewController.swift
//  MoodleTouch
//
//  Created by Adam Bratin on 11/25/14.
//  Copyright (c) 2014 Bratin. All rights reserved.
//

import UIKit
import CoreData

class LaunchTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate {
    @IBOutlet var mTableView : UITableView!
    @IBOutlet var searchbar : UISearchBar!
    @IBOutlet var settingsButton : UIBarButtonItem!
    
    @IBAction func buttonClick(sender : AnyObject) {
        if(sender as UIBarButtonItem == self.settingsButton) {
            let vc : LoginViewController = self.storyboard?.instantiateViewControllerWithIdentifier(Constants.loginViewControllerIdentifier) as LoginViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    var servers = []
    var filterdServers : NSMutableArray = []
    
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
//        self.tableView.registerClass(ServerTableViewCell.self, forCellReuseIdentifier: Constants.cellID)
        self.tableView.registerNib(UINib(nibName: Constants.cellID, bundle: nil), forCellReuseIdentifier: Constants.cellID)
        self.mTableView.delegate = self
        self.mTableView.dataSource = self
        loadServers()
        self.filterdServers = NSMutableArray(capacity: self.servers.count)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        loadServers()
        self.tableView.reloadData()
    }
    
    func loadServers() {
        let fetchRequest = NSFetchRequest(entityName: Constants.serverItemIdentifier)
        var error: NSError? = nil
        self.servers = managedObjectContext?.executeFetchRequest(fetchRequest, error:&error) as [Server]
    }

    // MARK: - UITableViewDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.searchDisplayController!.searchResultsTableView) {
            return self.filterdServers.count
        } else {
            return self.servers.count
        }
    }
    
    //MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(Constants.cellID, forIndexPath: indexPath) as ServerTableViewCell
        if(self.servers[indexPath.row] is Server) {
            if(tableView == self.searchDisplayController!.searchResultsTableView) {
                var server : Server = self.filterdServers[indexPath.row] as Server
                cell.serverLabel.text = server.domain as String
            } else {
                var server : Server = self.servers[indexPath.row] as Server
                cell.loadCell(server.domain)
            }
        } else {
            if(tableView == self.searchDisplayController!.searchResultsTableView) {
                cell.serverLabel.text = self.filterdServers[indexPath.row] as? String
            } else {
                cell.serverLabel.text = self.servers[indexPath.row] as? String
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.searchDisplayController!.setActive(false, animated: false)
        let vc : webViewController = self.storyboard?.instantiateViewControllerWithIdentifier(Constants.webViewController) as webViewController
        if(tableView == self.searchDisplayController!.searchResultsTableView) {
            vc.domain = self.filterdServers[indexPath.row].domain
        } else {
            vc.domain = self.servers[indexPath.row].domain
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44;
    }
    
    //MARK: - UIScrollViewDelegate
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if(scrollView.contentOffset.y < self.navigationController!.navigationBar.frame.size.height * -1 + self.searchDisplayController!.searchBar.frame.size.height * -1) {
            scrollView.contentOffset.y = self.navigationController!.navigationBar.frame.size.height * -1 + self.searchDisplayController!.searchBar.frame.size.height * -1
        }
        var visibleRows : NSArray = self.mTableView.visibleCells()
        var lastCellPath : NSIndexPath = NSIndexPath(forRow: self.servers.count - 1, inSection: 0)
        if(visibleRows.count == 0 && lastCellPath.row >= 0) {
            self.mTableView.scrollToRowAtIndexPath(lastCellPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
        }
    }
    
    //MARK: - ContentFiltering
    func filterContentForSearchText(searchText : NSString) {
        self.filterdServers.removeAllObjects()
        var predicate : NSPredicate = NSPredicate(format: "SELF.domain contains[c] %@",searchText)!
        self.filterdServers = NSMutableArray(array: self.servers.filteredArrayUsingPredicate(predicate))
    }
    
    //MARK: - UISearchDisplayController Delegate Methods
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        filterContentForSearchText(searchString)
        return true
    }
}
