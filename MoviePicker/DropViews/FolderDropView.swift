//
//  FolderDropView.swift
//  movieFiler
//
//  Created by Dylan Southard on 2018/01/07.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//




import Cocoa

protocol FolderDropViewDelegate {
    func folderDropped(url:URL)
}

class FolderDropView: DropView {
    
    
    var delegate:FolderDropViewDelegate?
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([NSPasteboard.PasteboardType.URL])
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
    
    override func checkExtension(_ drag: NSDraggingInfo) -> Bool {
        if let url = self.getUrl(drag) {
            return url.hasDirectoryPath
        }
        return false
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if self.isEnabled == true {
            if let vc = delegate  {
                vc.folderDropped(url:self.getUrl(sender)!)
            }
            UserDefaults.standard.set(self.getUrl(sender)!.path, forKey: "folder")
            return true
        } else {
            return false
        }
        
    }
    
    
}
