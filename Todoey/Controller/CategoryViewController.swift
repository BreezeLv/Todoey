//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Bernard Lyu on 12/20/18.
//  Copyright © 2018 Bernard Lyu. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class CategoryViewController: SwipeViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var categories : Results<CategoryR>?
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        RetrieveData()
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Category Created"
        cell.backgroundColor = UIColor(hexString: categories?[indexPath.row].bgcolor ?? "#ffffff")
        
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! ToDoViewController
        if let selectedRow = tableView.indexPathForSelectedRow?.row, let categ = categories {
            destVC.category = categ[selectedRow]
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            if let category = self.categories?[indexPath.row] {
                try! self.realm.write {
                    self.realm.delete(category)
                }
            }
        }
        
        // customize the action appearance
        deleteAction.image = #imageLiteral(resourceName: "icons8-trash-50")
        
        return [deleteAction]
    }
    
    
    //Add Action
    @IBAction func AddCategoryPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add a Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .cancel) { (action) in
            let txt = alert.textFields?[0].text
            if txt != nil && txt != "" {
                //Add a new entry to entity
                
                //MARK: Core Data Add Category
//                let cat = Category(context: self.context)
//                cat.name = txt!
//                self.categories.append(cat)
//                self.tableView.reloadData()
//
//                //save data after updating/appending a new item
//                self.SaveData()
                
                //MARK: Realm Add Category
                let cat = CategoryR()
                cat.name = txt!
                cat.bgcolor = RandomFlatColor().hexValue()
//                self.categories.append(cat)
                self.SaveData(withData: cat) //after write, result<category> object will auto-update !!
                self.tableView.reloadData()
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
        //Core Data Retrieve
//        do {
//            let request : NSFetchRequest<Category> = Category.fetchRequest()
//            categories = try context.fetch(request)
//        } catch {
//            categories = []
//            print("Error fetching Category Data\(error)")
//        }
        
        //Realm Retrieve
        categories = realm.objects(CategoryR.self)
//        for obj in realm.objects(CategoryR.self) {
//            categories.append(obj)
//        }
    }

    //Data Save
    func SaveData(withData data : Object?=nil) {
        //Core Data Save
//        do {
//          try context.save()
//        } catch {
//            print("Error Saving Category Data\(error)")
//        }
        
        //Realm Save
        // Add to the Realm inside a transaction
        if let data = data {
            try! realm.write {
                realm.add(data)
            }
        }
    }
}
