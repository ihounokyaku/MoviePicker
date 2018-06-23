//
//  Extensions.swift
//  MoviePicker
//
//  Created by Dylan Southard on 2018/04/21.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Foundation
import Cocoa

extension URL {
    
    func tags() -> [String] {
        var tagsToReturn = [String]()
        do {
            let tags = try (self as NSURL).resourceValues(forKeys: [.tagNamesKey])
            if let tagStrings = tags[.tagNamesKey] as? [String] {
                tagsToReturn = tagStrings
            }
        } catch let error as NSError {
            print("could not get tags for directory \(self.lastPathComponent)\n\(error)")
        }
        return tagsToReturn
    }
    
    func lastModified()-> Double {
        do {
            let resources = try self.resourceValues(forKeys: [.contentModificationDateKey])
            return resources.contentModificationDate!.timeIntervalSince1970
        } catch let error as NSError{
            print(error)
        }
        return 0
    }
}

extension NSImage {
    public func writePNG(toURL url: URL) {
        
        guard let data = tiffRepresentation,
            let rep = NSBitmapImageRep(data: data),
            let imgData = rep.representation(using: .png, properties: [.compressionFactor : NSNumber(floatLiteral: 1.0)]) else {
                
                Swift.print("\(self.self) Error Function '\(#function)' Line: \(#line) No tiff rep found for image writing to \(url)")
                return
        }
        
        do {
            try imgData.write(to: url)
        }catch let error {
            Swift.print("\(self.self) Error Function '\(#function)' Line: \(#line) \(error.localizedDescription)")
        }
    }
}

extension String {
    
    func asImage()-> NSImage {
        var image = #imageLiteral(resourceName: "noImage")
        if let newImage = NSImage(contentsOfFile: self) {
            image = newImage
        }
        return image
    }
    
}

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}
