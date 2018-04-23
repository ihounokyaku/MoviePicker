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
    
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var tagTable: NSTableView!
    
    //MARK: Managers, etc.
    var dataManager = DataManager()
    
    //MARK: Other Variables
    var chosenMovie = 0
    

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
        self.tagTable.delegate = self
        self.tagTable.dataSource = self
        
        
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
        var moviesToCreate = [URL]()
        
        
        for folder in subFolders {
            let tags = folder.tags().map({return $0.lowercased()})
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
                moviesToCreate.append(folder)
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            for folder in moviesToCreate {
                DispatchQueue.main.async {
                    self.statusLabel.stringValue = "Reading File: \(folder.lastPathComponent)"
                }
                var tags = folder.tags().map({return $0.lowercased()})
                //-- Create Movie Dictionary
                tags.remove(at: tags.index(of: "movie")!)
                
                //-- Save Directory Image
                let imagePath = self.saveIcon(image:NSWorkspace.shared.icon(forFile: folder.path), name:folder.lastPathComponent)
                
                //-- Append Dictionary Item
                movies.append(["title":folder.lastPathComponent, "tags":tags, "imagePath":imagePath, "urlPath":folder.path])
            }
            DispatchQueue.main.async {
                self.saveAndUpdateDataBase(from: movies, toDelete: moviesToDelete)
                self.statusLabel.stringValue = url.path
                self.coverCollection.reloadData()
                self.dataManager.reloadTags()
                self.tagTable.reloadData()
            }
        }
        
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
        let url = imageFolder.appendingPathComponent(name).appendingPathExtension("png")
        
        if !FileManager.default.fileExists(atPath: url.path) {
            image.writePNG(toURL: url)
        }
        
        return url.path
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
        
        if self.dataManager.displayMovies.count > 1 {
            
            //-- Chose movie
            self.chosenMovie = Int(arc4random_uniform(UInt32(self.dataManager.displayMovies.count)))
            print("chosen movie is \(self.chosenMovie)")
            
            // -- get current cell
            let closestCell = self.coverCollection.visibleItems()[0]
            let indexPath = self.coverCollection.indexPath(for: closestCell)
            var currentItem = indexPath!.item
            
            if (self.chosenMovie - currentItem).magnitude > 7 {
                currentItem = randomNum(excluding: self.chosenMovie)
                let ip = NSIndexPath(forItem: currentItem, inSection: 0)
                let set: Set<IndexPath> = [ip as IndexPath]
                self.coverCollection.scrollToItems(at: set, scrollPosition: .centeredHorizontally)
                print("scrolled to item")
            }
            
            self.animateScroller(objectIndex: self.randomNum(excluding:currentItem), duration: 0.2, previousItem:currentItem)
        }
    }
    
    func animateScroller(objectIndex:Int, duration:TimeInterval, previousItem:Int) {
        print("animating")
        let indexPath = NSIndexPath(forItem: objectIndex, inSection: 0)
        let set: Set<IndexPath> = [indexPath as IndexPath]
        NSAnimationContext.runAnimationGroup({ (_) in

            NSAnimationContext.current.duration = duration
            NSAnimationContext.current.allowsImplicitAnimation = true
            self.coverCollection.animator().scrollToItems(at: set, scrollPosition: .centeredHorizontally)
        }) {
            if duration < 2.0 {
                self.animateScroller(objectIndex: self.randomNum(excluding:objectIndex), duration: duration * 1.2, previousItem: objectIndex)
            } else {
                if objectIndex != self.chosenMovie {
                    print("final aniation")
                    self.animateScroller(objectIndex: self.chosenMovie, duration: duration * 1.2, previousItem: objectIndex)
                }
            }
        }
    }
    
    
    func randomNum(excluding numberToExclude:Int)-> Int {
        
        print("getting random number")
        
        
        var rando = -1
        
        while rando < 0 || rando > self.dataManager.displayMovies.count - 1 || (rando - numberToExclude).magnitude > 18 || rando == numberToExclude {
            print("rando = \(rando)")
            if self.dataManager.displayMovies.count > 16 {
                rando = Int(arc4random_uniform(UInt32(16))) + (self.chosenMovie - 7)
            } else {
                rando = Int(arc4random_uniform(UInt32(self.dataManager.displayMovies.count)))
            }
        }
        
        //-- if space is too large, jump
        
//        let difference = Int(numberToExclude - Int(rando)).magnitude
//        if difference > 10 {
//            var index = Int(rando) + 10
//
//            while index >= self.dataManager.displayMovies.count {
//                index -= 1
//            }
//
//            let indexPath = NSIndexPath(forItem: index, inSection: 0)
//            let set: Set<IndexPath> = [indexPath as IndexPath]
//            print("skipping")
//            self.coverCollection.animator().scrollToItems(at: set, scrollPosition: .centeredHorizontally)
//        }
        print("returnging \(rando)")
        return rando
    }
}

extension MainViewController : NSCollectionViewDataSource, NSCollectionViewDelegate {
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        self.filterDisplayMovies()
        return self.dataManager.displayMovies.count
    }
    
    func filterDisplayMovies() {
        
        let selectedIndexes = Array(self.tagTable.selectedRowIndexes) as [Int]
        self.dataManager.displayMovies = self.dataManager.movies
        if selectedIndexes.count > 0 {
           
            for ind in selectedIndexes {
                self.dataManager.displayMovies = self.dataManager.displayMovies.filter("%@ IN tags", self.dataManager.displayTags[ind])
            }
        }
        self.statusLabel.stringValue = "Showing \(self.dataManager.displayMovies.count) choices"
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue:"CollectionItem"), for: indexPath) as! CollectionItem
        cell.coverImage.image = self.dataManager.displayMovies[indexPath.item].imagePath.asImage()
        return cell
    }
}

extension MainViewController : NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.dataManager.displayTags.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        
        cell.textField?.stringValue = self.dataManager.displayTags[row].name
        
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        self.coverCollection.reloadData()
    }
    
}



