//
//  Item.swift
//  Todoey
//
//  Created by Bernard Lyu on 5/30/19.
//  Copyright © 2019 Bernard Lyu. All rights reserved.
//

import Foundation
import RealmSwift

/*
 Realm Model Docs
 
 There are three exceptions to this: LinkingObjects, List and RealmOptional. Those properties cannot be declared as dynamic because generic properties cannot be represented in the Objective‑C runtime, which is used for dynamic dispatch of dynamic properties. These properties should always be declared with let.
 https://realm.io/docs/swift/latest/#property-cheatsheet
 
 Realm has several types that help represent groups of objects, which we refer to as “Realm collections”:
 
 1, Results, a class representing objects retrieved from queries.
 2, List, a class representing to-many relationships in models.
 3, LinkingObjects, a class representing inverse relationships in models.
 4, RealmCollection, a protocol defining the common interface to which all Realm collections conform.
 5, AnyRealmCollection, a type-erased class that can forward calls to a concrete Realm collection like Results, List or LinkingObjects.
 */
class ItemR : Object {
    @objc dynamic var done : Bool = false
    @objc dynamic var title : String = ""
    @objc dynamic var date : Date?
    let parentCategory = LinkingObjects(fromType: CategoryR.self, property: "items")
}

//class Item : Codable {
//    var title:String?
//    var checked:Bool = false
//
//    init(title t:String) {
//        title = t
//    }
//}
