//
//  ViewController.swift
//  Todoey
//
//  Created by Bernard Lyu on 11/27/18.
//  Copyright © 2018 Bernard Lyu. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ToDoViewController: UITableViewController {

    //Variables
    var items = [Item(title: "Find My Iphone"),Item(title: "Buy PS4")]
    var bannerView : GADBannerView!
    
    //let defaultData = UserDefaults.standard
    
    //GET FileDirectoryURLs
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //retrieve saved useful data
        retrieveItems()
        
        //initialize and configure BannerAdView
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.delegate = self
        
        bannerView.load(GADRequest())
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row].title
        
        cell.accessoryType = items[indexPath.row].checked ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count 
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
        
        //revised method for check mark
        if items[indexPath.row].checked {
            cell?.accessoryType = .none
            items[indexPath.row].checked = false
        } else {
            cell?.accessoryType = .checkmark
            items[indexPath.row].checked = true
        }
        
        //save check status after updating
        saveItems()
    }

    @IBAction func AddItemPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New TODO Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .cancel) { (action) in
            //TODO: user add a new item
            let txt = alert.textFields?[0].text
            if txt != nil && txt != "" {
                let item = Item(title: txt!)
                self.items.append(item)
                self.tableView.reloadData()
                
                //save data after updating/appending a new item
                self.saveItems()
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
    func saveItems() {
        
//      Userdefault Solution
//       var elemList = [Data]()
//       for elem in self.items {
//       elemList.append(try! PropertyListEncoder().encode(elem))
//       }
//       self.defaultData.set(elemList, forKey: "todoitem")
        
        //Self-encoded plist Solution
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(self.items)
            try data.write(to: self.dataFilePath!)
            //FileManager.default.contents(atPath: (dataFilePath!.absoluteString))
        } catch {
            print("Error when encoding data")
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
        let decoder = PropertyListDecoder()
        do {
            let data = try Data(contentsOf: dataFilePath!)
            items = try decoder.decode([Item].self, from: data)
        } catch {
            print("Error when decoding data")
        }
    }
    
    
    //Add BannerAdView to Current View as a subview and add constraints
    func addBannerToView() {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
//        let cons = NSLayoutConstraint(item: <#T##Any#>, attribute: <#T##NSLayoutConstraint.Attribute#>, relatedBy: <#T##NSLayoutConstraint.Relation#>, toItem: <#T##Any?#>, attribute: <#T##NSLayoutConstraint.Attribute#>, multiplier: <#T##CGFloat#>, constant: <#T##CGFloat#>)
        view.addConstraints([NSLayoutConstraint(item: bannerView,
                                                attribute: .bottom,
                                                relatedBy: .equal,
                                                toItem: bottomLayoutGuide,
                                                attribute: .top,
                                                multiplier: 1,
                                                constant: 0),
                             NSLayoutConstraint(item: bannerView,
                                                attribute: .centerX,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: .centerX,
                                                multiplier: 1,
                                                constant: 0)
            ])
    }
}

