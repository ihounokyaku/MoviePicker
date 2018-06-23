//
//  CustomRow.swift
//  MoviePicker
//
//  Created by Dylan Southard on 2018/05/28.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Cocoa

enum TagSelectionType {
    case and
    case or
    case none
}

class CustomRow: NSTableRowView {
    var type:TagSelectionType = .none
    var color = NSColor.orange
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        if isSelected == true {
            switch type {
            case .or:
                color = NSColor.blue
            case .and:
                color = NSColor.orange
            case .none:
                color = NSColor.gray
            }
            
            color.set()
            dirtyRect.fill()
        }
    }
    
}
