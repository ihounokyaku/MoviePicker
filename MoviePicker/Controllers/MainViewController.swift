//
//  ViewController.swift
//  MoviePicker
//
//  Created by Dylan Southard on 2018/04/21.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Cocoa
import SYFlatButton


import SwiftHEXColors
class MainViewController: NSViewController, FolderDropViewDelegate {
    
    //MARK: - ============== DECLARED VARIABLES =====================
    
    //MARK: IBOutlets
    @IBOutlet weak var dropView: FolderDropView!
    @IBOutlet weak var coverCollection: NSCollectionView!
    
    
    //MARK: Managers, etc.
    var dataManager = DataManager()
    

    //MARK: - ============== INITIATE VIEW =====================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //-- Create collectionItem
        let item = NSNib(nibNamed: NSNib.Name(rawValue: "CollectionItem"), bundle: nil)
        self.coverCollection.register(item, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CollectionItem"))
        
        //-- Set Delegates
        self.dropView.delegate = self
        self.coverCollection.delegate = self
        self.coverCollection.dataSource = self
        
        
        
        //-- Set View colors
        view.wantsLayer = true
        dropView.wantsLayer = true
        view.layer?.backgroundColor = NSColor(hexString: "#586160", alpha: 0.8)?.cgColor
        dropView.layer?.backgroundColor = NSColor(hexString: "#756F61", alpha: 0.8)?.cgColor
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    //MARK: - ===============Folder Dropped Methods===============
    func folderDropped(url: URL) {
        print("DRAGGED")
        
        
        //--Get subfolders
        let subFolders = self.getSubfolders(inFolder: url)
        var movies = [[String:Any]]()
        var moviesToDelete = [Movie]()
        
        for folder in subFolders {
            
            var tags = folder.tags().map({return $0.lowercased()})
            
            //-- Check if directory is a movie
            if tags.contains("movie") {
                
                //-- Check if it already exists & if so if it has been modified
                if let movie = self.dataManager.getMovie(withTitle: folder.lastPathComponent) {
                    if movie.lastUpdated >= folder.lastModified() {
                        continue
                    } else {
                        moviesToDelete.append(movie)
                    }
                }
                
                //-- Create Movie Dictionary
                tags.remove(at: tags.index(of: "movie")!)
                
                //-- Save Directory Image
                let imagePath = self.saveIcon(image:NSWorkspace.shared.icon(forFile: folder.path), name:folder.lastPathComponent)
                
                //-- Append Dictionary Item
                movies.append(["title":folder.lastPathComponent, "tags":tags, "imagePath":imagePath, "urlPath":folder.path])
            }
        }
        self.saveAndUpdateDataBase(from: movies, toDelete: moviesToDelete)
    }
    
    
    
    func saveAndUpdateDataBase(from dictionaries:[[String:Any]], toDelete:[Movie]) {
        for movie in toDelete {
            self.dataManager.deleteObject(object: movie)
        }
        
        for item in dictionaries {
           let movie = self.dataManager.newMovie(title: item["title"] as! String, urlPath: item["urlPath"] as! String, imagePath: item["imagePath"] as? String, tags: item["tags"] as! [String])
            self.dataManager.save(object: movie)
        }
    }
    
    //MARK: - get folder contents
    
    func getContentsOfFolder(atUrl folderUrl:URL) -> [URL] {
        var urls = [URL]()
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: folderUrl.path)
            urls = contents.map { return folderUrl.appendingPathComponent($0) }
        } catch let error as NSError {
            print("Error getting contents of folder: \(folderUrl)\n\(error)")
        }
        return urls
    }
    
    func getSubfolders(inFolder folderUrl:URL)-> [URL] {
        var subfolders = [URL]()
        let allUrls = self.getContentsOfFolder(atUrl: folderUrl)
        for url in allUrls {
            if url.hasDirectoryPath {
                subfolders.append(url)
            }
        }
        return subfolders
    }
    
    //MARK: - ImageHandling
    
    func saveIcon(image:NSImage, name:String)-> String {
        
        let imageFolder = (FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!).appendingPathComponent("CoverImages")
        
        //-- create image folder if it does not exist
        if !FileManager.default.fileExists(atPath: imageFolder.path) {
            self.createFolder(atPath: imageFolder.path)
        }
        
        //--
        let url = imageFolder.appendingPathComponent(name)
        
        if !FileManager.default.fileExists(atPath: url.path) {
            image.writePNG(toURL: url)
        }
        
        return url.path + ".png"
    }
    
    //MARK: - Folder Management
    
    func createFolder(atPath filePath:String) {
        do {
            try FileManager.default.createDirectory(atPath:filePath , withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError{
            print("could not create directory ÷\(error)")
        }
    }
    
    //MARK: - =====================Randomizer=======================
    
    @IBAction func testPressed(_ sender: Any) {
        //TODO: make sure count > 1
        self.animateScroller(objectIndex: self.randomNum(), duration: 0.2)
    }
    
    func animateScroller(objectIndex:Int, duration:TimeInterval) {
        let indexPath = NSIndexPath(forItem: objectIndex, inSection: 0)
        let set: Set<IndexPath> = [indexPath as IndexPath]
        NSAnimationContext.runAnimationGroup({ (_) in
            NSAnimationContext.current.duration = duration
            NSAnimationContext.current.allowsImplicitAnimation = true
            self.coverCollection.animator().scrollToItems(at: set, scrollPosition: .centeredHorizontally)
        }) {
            if duration < 2.0 {
                self.animateScroller(objectIndex: self.randomNum(excluding:objectIndex), duration: duration * 1.2)
            } else {
                print("completed!")
            }
        }
    }
    
    
    func randomNum(excluding numberToExclude:Int = 9999)-> Int {
        let totalPossible = 10
        var rando = arc4random_uniform(UInt32(totalPossible))
        while rando == numberToExclude {
            rando = arc4random_uniform(UInt32(totalPossible))
        }
        return Int(rando)
    }
}

extension MainViewController : NSCollectionViewDataSource, NSCollectionViewDelegate {
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue:"CollectionItem")   , for: indexPath)
        
        return cell
    }
    
    
}



