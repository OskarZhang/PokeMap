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
                self.tableView.reloadData()
            }
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 114
        tableView.rowHeight = UITableViewAutomaticDimension

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
        return types == nil ? 0 : types.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("filterCell") as! FilterCell
        let type = types[indexPath.item]
        cell.titleLabel.text = type.name
        let tintColor = UIColor(hex: type.color!.integerValue)
        cell.titleLabel.textColor = tintColor
        cell.accessoryType = checked[indexPath.item] ? .Checkmark : .None
        cell.tintColor = tintColor
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
        checked[indexPath.item] = !checked[indexPath.item]
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }

}
