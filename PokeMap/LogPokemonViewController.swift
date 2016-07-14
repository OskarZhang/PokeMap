//
//  LogViewController.swift
//  PokeMap
//
//  Created by Oskar Zhang on 7/13/16.
//  Copyright © 2016 OskarZhang. All rights reserved.
//

import Foundation
import UIKit

class LogPokemonViewController:UIViewController,UITableViewDelegate,UISearchBarDelegate {

    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var tableView:UITableView!
    static let id = "logPokemonViewController"
    
    var submissionCoordinator:SubmissionCoordinator?
    
    var dataSource = LogPokemonViewDataSource()
    var currentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.estimatedRowHeight = 114
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        configrueSearchBar()
    }

    override func viewDidAppear(animated: Bool) {
        searchBar.becomeFirstResponder()
    }
    
    func configrueSearchBar() {
        let textFieldInsideSearchBar = searchBar.valueForKey("searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.whiteColor()
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.valueForKey("placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = UIColor.whiteColor()
        searchBar.tintColor = UIColor.whiteColor()
    }
    
    func getPokemons(keywords:String) {
        PMClient.sharedClient.autocompletePokemonByName(keywords, page: currentPage) { (pokemons, error) in
            if (error == nil && pokemons != nil) {
                let pokemonObjects = pokemons.flatMap({ (object) -> Pokemon? in
                    return object as? Pokemon
                })
                self.dataSource.pokemons = pokemonObjects
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func didClickCancel(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        currentPage = 0
        getPokemons(searchBar.text!)
    }
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        currentPage = 0
        getPokemons(searchBar.text!)
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        getPokemons(searchBar.text!)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        submissionCoordinator?.moveToLocationVC(dataSource.pokemons[indexPath.item])
        
    }
    
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.view.endEditing(true)
    }
    @IBAction func dismissView(sender: AnyObject) {
        self.view.endEditing(true)
        submissionCoordinator?.dismissViewController(self)
    }
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! PokemonSearchCell
        cell.containerView.backgroundColor = UIColor(hex: 0xfddc49).colorWithAlphaComponent(0.80)
    }
    func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! PokemonSearchCell
        cell.containerView.backgroundColor = UIColor(hex: 0xffffff).colorWithAlphaComponent(0.35)
    }
}




class LogPokemonViewDataSource:NSObject,UITableViewDataSource {
    var pokemons:[Pokemon] = []

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  pokemons.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchCell", forIndexPath: indexPath) as! PokemonSearchCell
        cell.nameLabel.text =  pokemons[indexPath.item].name!
        cell.nameLabel.font = UIFont(name: "Pocket Monk", size: 26)
        
        cell.pokemonIconImageView?.image = UIImage(named: pokemons[indexPath.item].pid!)
        return cell
    }
}