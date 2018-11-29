//
//  Item.swift
//  Todoey
//
//  Created by Bernard Lyu on 11/28/18.
//  Copyright © 2018 Bernard Lyu. All rights reserved.
//

import Foundation

class Item : Codable {
    var title:String?
    var checked:Bool = false
    
    init(title t:String) {
        title = t
    }
}
