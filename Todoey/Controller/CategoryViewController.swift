//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Bernard Lyu on 12/20/18.
//  Copyright © 2018 Bernard Lyu. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var categories : [Category] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        RetrieveData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row].name
        
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! ToDoViewController
        if let selectedRow = tableView.indexPathForSelectedRow?.row {
            destVC.category = categories[selectedRow]
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }

    
    
    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    //Add Action
    @IBAction func AddCategoryPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add a Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .cancel) { (action) in
            let txt = alert.textFields?[0].text
            if txt != nil && txt != "" {
                //Add a new entry to entity
                let cat = Category(context: self.context)
                cat.name = txt!
                self.categories.append(cat)
                self.tableView.reloadData()
                
                //save data after updating/appending a new item
                self.SaveData()
            }
            //Or we can use item ?? "Default Value" to avoid a nil value
        }
        
        //do nothing to opt out ! cause alert view do dismissal automatically
        let actionOut = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addAction(action)
        alert.addAction(actionOut)
        alert.addTextField { (txtField) in
            //doing textfield setup here
            txtField.placeholder = "Create New Category"
        }
        present(alert, animated: true, completion: nil)
    }
    
    
    //Data Retrieve
    func RetrieveData() {
        do {
            let request : NSFetchRequest<Category> = Category.fetchRequest()
            categories = try context.fetch(request)
        } catch {
            categories = []
            print("Error fetching Category Data\(error)")
        }
    }

    //Data Save
    func SaveData() {
        do {
          try context.save()
        } catch {
            print("Error Saving Category Data\(error)")
        }
    }
}
