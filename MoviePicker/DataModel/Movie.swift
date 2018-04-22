//
//  Movie.swift
//  MoviePicker
//
//  Created by Dylan Southard on 2018/04/21.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Foundation
import RealmSwift

class Movie: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var urlPath: String = ""
    @objc dynamic var imagePath: String = ""
    @objc dynamic var lastUpdated: Double = 0
    
    let tags = List<Tag>()
    
}
