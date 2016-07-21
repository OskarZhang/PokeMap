//
//  PokemonSearchViewController.swift
//  PokeMap
//
//  Created by Oskar Zhang on 7/18/16.
//  Copyright © 2016 OskarZhang. All rights reserved.
//

import Foundation
import UIKit
class PokemonSearchViewController:LogPokemonViewController {
    var coordinator:SearchCoordinator?
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        PMClient.sharedClient.applySearches(dataSource.pokemons[indexPath.item])
        coordinator?.dismissSearchView()
    }
    @IBAction func didClickHide(sender: AnyObject) {
        coordinator?.dismissSearchView()
    }
}