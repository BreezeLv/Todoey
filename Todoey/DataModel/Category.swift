//
//  Category.swift
//  Todoey
//
//  Created by Bernard Lyu on 5/30/19.
//  Copyright © 2019 Bernard Lyu. All rights reserved.
//

import Foundation
import RealmSwift

class CategoryR : Object {
    @objc dynamic var name : String = ""
    let items = List<ItemR>()
    @objc dynamic var bgcolor : String = UIColor.white.hexValue()
}
