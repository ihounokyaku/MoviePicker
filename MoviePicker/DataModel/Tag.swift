//
//  File.swift
//  MoviePicker
//
//  Created by Dylan Southard on 2018/04/21.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Foundation
import RealmSwift

class Tag : Object {
    
    @objc dynamic var name:String = ""
    

    var movies = LinkingObjects(fromType: Movie.self, property: "tags")
}
