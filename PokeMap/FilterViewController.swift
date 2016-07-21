//
//  FilterViewController.swift
//  PokeMap
//
//  Created by Oskar Zhang on 7/16/16.
//  Copyright © 2016 OskarZhang. All rights reserved.
//

import Foundation
import UIKit
class FilterViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var types:[Type]!
    var checked:[Bool]!
    var selectedTypes:[Type]!
    weak var coordinator:FilterCoordinator!
    override func viewDidLoad() {
        PMClient.sharedClient.getTypes { (types, selectedTypes, error) in
            if error == nil {
                self.types = types
                self.selectedTypes = selectedTypes
                self.setChecked()
                
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
            }
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 114
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
    }
    
    func setChecked() {
        checked = Array<Bool>(count: types.count,repeatedValue: false)
        let selectedSet = Set<Type>(selectedTypes)
        for (index,type) in types.enumerate() {
            if selectedSet.contains(type) {
                checked[index] = true
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return types == nil ? 0 : types.count + 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("filterCell") as! FilterCell
        
        if indexPath.item == 0 {
            cell.titleLabel.text = "All Types"
            cell.titleLabel.textColor = UIColor(hex: 0xE45C38)
            cell.tintColor = UIColor(hex: 0xE45C38)
            cell.accessoryType = checked.contains(true) ? .None : .Checkmark
        }
        else
        {
            let type = types[indexPath.item-1]
            cell.titleLabel.text = type.name
            if let color = type.color {
                let tintColor = UIColor(hex: color.integerValue)
                cell.titleLabel.textColor = tintColor
                cell.tintColor = tintColor
            }
            cell.accessoryType = checked[indexPath.item-1] ? .Checkmark : .None
        
        }
        return cell
    }
    @IBAction func saveAll() {
        var newTypes:[Type] = []
        for index in 0...types.count-1 {
            if checked[index] {
                newTypes.append(types[index])
            }
        }
        PMClient.sharedClient.applyFilters(newTypes)
        coordinator.dismissFilterView()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.item == 0 {
            checked = Array<Bool>(count: types.count,repeatedValue: false)
            
        }
        else {
            checked[indexPath.item-1] = !checked[indexPath.item-1]
            
        }
//        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        self.tableView.reloadData()

    }

}
