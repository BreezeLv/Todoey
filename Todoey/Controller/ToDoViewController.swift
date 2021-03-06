//
//  ViewController.swift
//  Todoey
//
//  Created by Bernard Lyu on 11/27/18.
//  Copyright © 2018 Bernard Lyu. All rights reserved.
//

import UIKit
import GoogleMobileAds
import CoreData
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class ToDoViewController: SwipeViewController, UISearchBarDelegate {

    let realm = try! Realm()
    
    //Variables & Constants
    var items : Results<ItemR>?
    var category : CategoryR? {
        didSet {
            //Will execute as soon as this optional get set
            retrieveItems()
        }
    }
    var bannerView : GADBannerView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //let defaultData = UserDefaults.standard
    @IBOutlet var searchBar: UISearchBar!
    
    //GET FileDirectoryURLs
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //get the path where we store data for this app
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        //initialize and configure BannerAdView
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.delegate = self
        
        bannerView.load(GADRequest())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navbar = navigationController?.navigationBar else {fatalError("Navbar doesn't exist")}
        navbar.barTintColor = UIColor(hexString: category?.bgcolor ?? "#ffffff")
        navbar.tintColor = ContrastColorOf(navbar.barTintColor!, returnFlat: true)
        navbar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : navbar.tintColor!]
        title = category?.name;
        
        searchBar.barTintColor = UIColor(hexString: category?.bgcolor ?? "#ffffff")
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = items?[indexPath.row].title ?? "No Item Assigned In \(category!)"
        cell.accessoryType = (items?[indexPath.row].done ?? false ? .checkmark : .none)// ?? .none
        
        //By applying color-darken method, make a maunal graident effects in to-do item list
        if let baseColor = UIColor(hexString: items?[indexPath.row].parentCategory[0].bgcolor ?? "#ffffff") {
            cell.backgroundColor = baseColor.darken(byPercentage:  CGFloat(indexPath.row)/CGFloat(items!.count))
            cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("You selected \(indexPath.row) row!")
        
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        
        //this method fails when encountering cell reuseage
//        if cell?.accessoryType == .checkmark {
//            cell?.accessoryType = .none
//        } else {
//            cell?.accessoryType = .checkmark
//        }
        
        if let items = items {
            //revised method for check mark
            if items[indexPath.row].done {
                cell?.accessoryType = .none
                try! self.realm.write {
                    items[indexPath.row].done = false
                }
                //Or use    items[indexPath.row].setValue(false, forKey: "done")
            } else {
                cell?.accessoryType = .checkmark
                try! self.realm.write {
                    items[indexPath.row].done = true
                }
            }
        }
        
        //save check status after updating
//        saveItems()
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            if let item = self.items?[indexPath.row] {
                try! self.realm.write {
                    self.realm.delete(item)
                }
            }
        }
        
        // customize the action appearance
        deleteAction.image = #imageLiteral(resourceName: "icons8-trash-50")
        
        return [deleteAction]
    }

    @IBAction func AddItemPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New TODO Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .cancel) { (action) in
            let txt = alert.textFields?[0].text
            if txt != nil && txt != "" {
                //Core Data Add
//                let item = Item(context: self.context)
//                item.title = txt
//                item.done = false
//                item.parentCategory = self.category
//                self.items.append(item)
//                self.tableView.reloadData()
//
//                //save data after updating/appending a new item
//                self.saveItems()
                
                //Realm Add
                let item = ItemR()
                item.title = txt!
                item.done = false
                item.date = Date()
                item.bgcolor = RandomFlatColor().hexValue()
                try! self.realm.write {
                    self.category!.items.append(item)
                }
//                self.items.append(item)
                self.saveItems(withData: item)
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
            txtField.placeholder = "Create New Item"
        }
        present(alert, animated: true, completion: nil)
        
    }
    
    //Data Storage & Retrieve Method
    func saveItems(withData data : Object?=nil) {
        
//      Userdefault Solution
//       var elemList = [Data]()
//       for elem in self.items {
//       elemList.append(try! PropertyListEncoder().encode(elem))
//       }
//       self.defaultData.set(elemList, forKey: "todoitem")
        
        //Self-encoded plist Solution
//        let encoder = PropertyListEncoder()
//        do {
//            let data = try encoder.encode(self.items)
//            try data.write(to: self.dataFilePath!)
//            //FileManager.default.contents(atPath: (dataFilePath!.absoluteString))
//        } catch {
//            print("Error when encoding data")
//        }
        
        //Core Data Solution
        //(UIApplication.shared.delegate as! AppDelegate).saveContext()
        
//        do {
//            try context.save()
//        } catch {
//            print("Error saving context\(error)")
//        }
        
        //Realm Version
        if let data = data {
            try! realm.write {
                realm.add(data)
            }
        }
    }
    
    func retrieveItems() {
        
        //UserDefault Solution
//        let elemList = (defaultData.array(forKey: "todoitem") ?? [Data]()) as! [Data]
//        if elemList.count > 0 {items = []}
//        for elem in elemList {
//            items.append(try! PropertyListDecoder().decode(Item.self, from: elem))
//        }
        
        //Self-decoded plist Solution
//        let decoder = PropertyListDecoder()
//        do {
//            let data = try Data(contentsOf: dataFilePath!)
//            items = try decoder.decode([Item].self, from: data)
//        } catch {
//            print("Error when decoding data")
//        }
        
        //Core Data Solution
//        do {
//            let request : NSFetchRequest<Item> = Item.fetchRequest()
//
//            request.predicate = NSPredicate(format: "parentCategory.name == %@", category!.name!)
//
//            items = try context.fetch(request)
//        } catch {
//            print("Error fetching context\(error)")
//        }
        
        //Realm Version
        items = category!.items.sorted(byKeyPath: "title", ascending: true)
//        items = realm.objects(ItemR.self).filter("ANY parentCategory.name == %@", category!.name)
//        for obj in realm.objects(ItemR.self).filter("ANY parentCategory.name == %@", category!.name) {
//            items.append(obj)
//        }
    }
    
    
    //MARK: Search Bar Delegate Method
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //Core Data Version
//        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        //Another Solution
        //let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1,predicate2...])
        
//        request.predicate = NSPredicate(format: "parentCategory.name == %@ && title CONTAINS[cd] %@", category!.name!, searchBar.text!)
//
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//        do {
//            items = try context.fetch(request)
//            tableView.reloadData()
//        } catch {
//            print("Error fetching context with search\(error)")
//        }
        
        //Realm Version
        /*
         Collections may only be sorted by properties of boolean, Date, NSDate, single and double-precision floating point, integer, and string types.
         */
        items = category!.items.filter("ANY parentCategory.name == %@ && title CONTAINS[cd] %@", category!.name, searchBar.text!).sorted(byKeyPath: "date", ascending: true)
//        items = realm.objects(ItemR.self).filter("ANY parentCategory.name == %@ && title CONTAINS[cd] %@", category!.name, searchBar.text!)
//        for obj in realm.objects(ItemR.self).filter("ANY parentCategory.name == %@ && title CONTAINS[cd] %@", category!.name, searchBar.text!) {
//            items.append(obj)
//        }
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        if searchText == "" {
            retrieveItems()
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}


//MARK: - BannerAd Methods
extension ToDoViewController {
    //Add BannerAdView to Current View as a subview and add constraints
    func addBannerToView() {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        //        let cons = NSLayoutConstraint(item: <#T##Any#>, attribute: <#T##NSLayoutConstraint.Attribute#>, relatedBy: <#T##NSLayoutConstraint.Relation#>, toItem: <#T##Any?#>, attribute: <#T##NSLayoutConstraint.Attribute#>, multiplier: <#T##CGFloat#>, constant: <#T##CGFloat#>)
        view.addConstraints([NSLayoutConstraint(item: bannerView as Any,
                                                attribute: .bottom,
                                                relatedBy: .equal,
                                                toItem: view.safeAreaLayoutGuide,
                                                attribute: .bottom,
                                                multiplier: 1,
                                                constant: 0),
                             NSLayoutConstraint(item: bannerView as Any,
                                                attribute: .centerX,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: .centerX,
                                                multiplier: 1,
                                                constant: 0)
            ])
    }
}

