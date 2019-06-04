//
//  SwipeViewController.swift
//  Todoey
//
//  Created by Bernard Lyu on 6/3/19.
//  Copyright © 2019 Bernard Lyu. All rights reserved.
//

import UIKit
import SwipeCellKit
//import ChameleonFramework

class SwipeViewController: UITableViewController, SwipeTableViewCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 80
        tableView.separatorStyle = .none
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwipeCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
//        cell.backgroundColor = RandomFlatColor()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        return []
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        
        if orientation == .right {
            options.expansionStyle = .destructive
            options.transitionStyle = .border
        } else {
            options.expansionStyle = .fill
            options.transitionStyle = .border
        }
        
        return options
    }
    
}
