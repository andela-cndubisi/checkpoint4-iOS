//
//  HistoryViewController.swift
//  pro-tracker
//
//  Created by Chijioke Ndubisi on 24/11/2015.
//  Copyright © 2015 cjay. All rights reserved.
//

import Foundation
import UIKit

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var tableContent:[Productivity]? {
        didSet{
            tableView.reloadData()
        }
    }
    var coreDataStore:CoreDataStore!
    
    @IBAction func sortBy(sender: UIButton) {
        
    }
    
    func addLine() -> CALayer {
        let width = view.frame.width / 2 - sortButton.frame.width
        let border = CALayer()
        border.backgroundColor = UIColor.grayColor().CGColor
        border.frame = CGRectMake(0, sortButton.frame.origin.y + sortButton.frame.height/2, width, 0.5)
        return border
    }
 
    @IBAction func done(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: -
    // MARK: ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController!.navigationBar.barStyle = .Black
        navigationController!.navigationBar.barTintColor = UIColor(red:  16.0/225, green: 169.0/255, blue: 224.0/255, alpha: 1)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let leftBorder = addLine()
        leftBorder.frame.origin.x = 20
        view.layer.addSublayer(leftBorder)
        let rightBorder = addLine()
        rightBorder.frame.origin.x = sortButton.frame.origin.x + 20
        view.layer.addSublayer(rightBorder)
        tableContent = Productivity.getAllProductivity(coreDataStore.managedObjectContext)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    // MARK: -
    // MARK: TableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableContent!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let productivity = tableContent![section]
        return productivity.location!.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let productivity = tableContent![section]
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        let str = dateFormatter.stringFromDate(productivity.date!)
        return str
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdetifier = "HistoryCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdetifier, forIndexPath: indexPath)

        let locations = tableContent![indexPath.section].location!
        let location = (locations.allObjects as! [Location])[indexPath.row]
        
        cell.textLabel?.text = location.address
        return cell
    }
}