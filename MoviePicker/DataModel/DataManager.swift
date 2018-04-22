//
//  DataManager.swift
//  MoviePicker
//
//  Created by Dylan Southard on 2018/04/21.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Foundation
import RealmSwift

class DataManager : NSObject {
    
    //MARK: - VARIABLES
    let realm = try! Realm()
    
    var movies:Results<Movie>!
    var tags: Results<Tag>!
    
    
    //MARK: - INIT
    override init() {
        super.init()
        
        // - load movies and tags
        self.reload()
    }
    
    //MARK: - METHODS
    func save(object:Object) {
        do {
            try self.realm.write {
                realm.add(object)
            }
        } catch {
            print("Error saving Category \(error)")
        }
    }
    
    func deleteObject(object:Object) {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print("error deleting \(object) \n \(error)")
        }
    }
    
    
    func reload() {
        self.movies = realm.objects(Movie.self)
        self.tags = realm.objects(Tag.self)
    }
    
    //MRK: - CREATE NEW
    func newMovie(title:String, urlPath:String, imagePath:String?, tags:[String])-> Movie {
        let movie = Movie()
        let date = Date()
        
        movie.title = title
        movie.urlPath = urlPath
        movie.lastUpdated = date.timeIntervalSince1970
        
        if let path = imagePath {
            movie.imagePath = path
        }
        
        for tag in tags {
            if let result = self.getTag(withName: tag) {
                movie.tags.append(result)
            } else {
                let newTag = Tag()
                newTag.name = tag
                movie.tags.append(newTag)
            }
        }
        
        return movie
    }

    
    //MARK: - QUERIES
    func getTag(withName name:String)-> Tag? {
        return self.tags.filter("name == %@", name).first
    }
    
    func getMovie(withTitle title:String)-> Movie? {
        
        return self.movies.filter("title == %@", title).first
    }
}
