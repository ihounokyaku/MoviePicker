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
    @IBOutlet weak var dropView: FolderDropView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //-- Set Delegates
        self.dropView.delegate = self
        
        
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
        let subFolders = self.getSubfolders(inFolder: url)
        for folder in subFolders {
            print(folder.lastPathComponent)
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
}

