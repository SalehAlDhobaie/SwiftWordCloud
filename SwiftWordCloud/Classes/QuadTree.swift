//
//  QuadTree.swift
//  WordCloud-Swift
//
//  Created by Saleh AlDhobaie on 10/31/16.
//  Copyright © 2016 Saleh AlDhobaie. All rights reserved.
//

import Foundation
import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


open class QuadTree : NSObject {
    
    fileprivate static let kLALBoundingRectThreshold : Int = 8;

    
    // MARK: private Vars
    // =====
    /**
     The frame (region) corresponding to this node
     */
    fileprivate var frame : CGRect!
    
    /**
     A strong reference to the bounding rects that fit within this node's frame
     
     @note These are rects that don't fit completely within a sub quad
     
     @note Will be nil if this node is empty, or if all its rects fit within sub quads
     */
    fileprivate var boundingRects : [CGRect]?
    
    /**
     A strong reference to the top left quadrant of this node
     
     @note Will be nil if this node has no sub quads
     */
    fileprivate var topLeftQuad : QuadTree?
    
    /**
     A strong reference to the top right quadrant of this node
     
     @note Will be nil if this node has no sub quads
     */
    fileprivate var topRightQuad : QuadTree?
    
    /**
     A strong reference to the bottom left quadrant of this node
     
     @note Will be nil if this node has no sub quads
     */
    fileprivate var bottomLeftQuad : QuadTree!
    
    /**
     A strong reference to the bottom right quadrant of this node
     
     @note Will be nil if this node has no sub quads
     */
    fileprivate var bottomRightQuad : QuadTree?
    
    // =====
    
    /**
     Returns a quadtree object
     
     @param frame The region in the delegate's cloud view that this node covers
     
     @return An initialized quadtree object, or nil if the object could not be created for some reason
     */

    
    override convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    init(frame: CGRect) {
        
        self.frame = frame
        super.init()
        
    }
    
    
    /**
     @warning Cannot initialize node without a region size (and origin).  Use initWithFrame:
     */
    // - (instancetype)init __attribute__((unavailable("Must use initWithFrame:")));
    
    /**
     @warning Cannot initialize node without a region size (and origin).  Use initWithFrame:
     */
    // + (instancetype)new __attribute__((unavailable("Must use initWithFrame:")));
    
    /**
     Add a bounding rect to this quadtree
     
     @param boundingRect The bounding rect to be inserted into the quadtree
     
     @return YES if the insert succeeds (i.e., the bounding rect fits completely within the node's frame), otherwise NO.
     */
    open func insertBoundingRect(_ boundingRect: CGRect) -> Bool {
        if (self.frame.contains(boundingRect) == false) {
            // The rect doesn't fit in this node.  Give up
            return false
        }
        
        // Pre-insert, check if no sub quads, and rect threshold reached
        if topLeftQuad == nil && boundingRects?.count > QuadTree.kLALBoundingRectThreshold {
            setupChildQuads()
            migrateBoundingRects()
        }
        
        if topLeftQuad != nil && migrateBoundingRect(boundingRect) {
            // The bounding rect was inserted into a sub quad
            return true
        }
        
        // The bounding rect did not fit into a sub quad.  Add it to this node's array
        if boundingRects == nil {
            boundingRects = []
        }
        boundingRects!.append(boundingRect)
        
        //[self.boundingRects addObject:[NSValue valueWithCGRect:boundingRect]];
        return true

    
    }
    
    /**
     Checks to see if the word's desired location intersects with any glyph's bounding rect
     
     @param wordRect The location to be compared against the quadtree
     
     @return YES if a glyph intersects the word's location, otherwise NO
     */
    open func hasGlyphThatIntersectsWithWordRect(_ wordRect : CGRect) -> Bool {
        
        // First test the node's bounding rects
        /*if boundingRects == nil {
            boundingRects = []
        }*/
        
        // Added By Saleh
        if let boundRects = boundingRects {
            // First test the node's bounding rects
            for glyphBoundingRect in boundRects {
                if glyphBoundingRect.intersects(wordRect) {
                    return true
                }
            }
        }
        
        /*for glyphBoundingRect in boundingRects! {
                if CGRectIntersectsRect(glyphBoundingRect, wordRect) {
                    return true
                }
        }*/
        
        
        // If no sub quads, we're done looking for intersections
        if (topLeftQuad == nil) {
            return false
        }
        /*
        // Added By Saleh
        guard let topLQ = self.topLeftQuad else {
            return false
        }*/
        
        // Added By Saleh
        if let check = checkIntersect(topLeftQuad!, wordRect: wordRect) {
            return check
        }
        
        
        /*
        // Check a sub quad if its frame intersects with the word
        if CGRectIntersectsRect(topLQ.frame, wordRect) {
            if topLQ.hasGlyphThatIntersectsWithWordRect(wordRect) {
                // One of its glyphs intersects with our word
                return true
            }
            if CGRectContainsRect(topLQuad.frame, wordRect) {
                // Our word fits completely within topLeft.  No need to check other sub quads
                return false
            }
        }*/
        
        // Added By Saleh
        if let topRQ = topRightQuad {
            if let check = checkIntersect(topRQ, wordRect: wordRect) {
                return check
            }
        }
        
        
        /*
        if CGRectIntersectsRect(self.topRightQuad.frame, wordRect) {
            if topRightQuad.hasGlyphThatIntersectsWithWordRect(wordRect) {
                // One of its glyphs intersects with our word
                return true
            }
            if CGRectContainsRect(topRightQuad.frame, wordRect) {
                // Our word fits completely within topRight.  No need to check other sub quads
                return false
            }
        }*/
        
        
        
        // Added By Saleh
        if let topLQ = bottomLeftQuad {
            if let check = checkIntersect(topLQ, wordRect: wordRect) {
                return check
            }
        }
        
        /*if CGRectIntersectsRect(bottomLeftQuad.frame, wordRect) {
            if bottomLeftQuad.hasGlyphThatIntersectsWithWordRect(wordRect) {
                // One of its glyphs intersects with our word
                return true
            }
            if (CGRectContainsRect(self.bottomLeftQuad.frame, wordRect)) {
                // Our word fits completely within bottomLeft.  No need to check other sub quads
                return false
            }
        }*/
        
        
        
        // Added By Saleh
        guard let bottomRQ = bottomRightQuad else {
            return false
        }
        
        if (bottomRQ.frame.intersects(wordRect)) {
            if bottomRQ.hasGlyphThatIntersectsWithWordRect(wordRect) {
                // One of its glyphs intersects with our word
                return true
            }
        }
        
        // No more sub quads to check.  If we've got this far, there are no intersections
        return false
    }
    
    
    func checkIntersect(_ quadTree: QuadTree, wordRect: CGRect) -> Bool? {
        
        if quadTree.frame.intersects(wordRect) {
            if quadTree.hasGlyphThatIntersectsWithWordRect(wordRect) {
                // One of its glyphs intersects with our word
                return true
            }
            if quadTree.frame.contains(wordRect) {
                // Our word fits completely within topRight.  No need to check other sub quads
                return false
            }
        }
        return nil
    }
    
    //MARK: Private Method
    
    /**
     Create sub quads, provided that they do not already exist
     */
    func setupChildQuads() {
        if topLeftQuad != nil {
            // Sub quads already exist
            return
        }
        
        // Create sub quads
        
        let currentX : CGFloat = frame.minX;
        var currentY : CGFloat = frame.minY;
        let childWidth : CGFloat = frame.width / 2.0;
        let childHeight : CGFloat = frame.width / 2.0;
        
        let topLeftRect = CGRect(x: currentX, y: currentY, width: childWidth, height: childHeight)
        topLeftQuad = QuadTree(frame: topLeftRect)
        
        let topRightRect = CGRect(x: currentX + childWidth, y: currentY, width: childWidth, height: childHeight)
        topRightQuad = QuadTree(frame: topRightRect)
        
        
        currentY += childHeight;
        let bottomLeftRect = CGRect(x: currentX, y: currentY, width: childWidth, height: childHeight)
        bottomLeftQuad = QuadTree(frame: bottomLeftRect)
        
        let bottomRightRect = CGRect(x: currentX + childWidth, y: currentY, width: childWidth, height: childHeight)
        bottomRightQuad = QuadTree(frame: bottomRightRect)
    }
    
    /**
     Migrate any existing bounding rects to any sub quads that can enclose them
     */
    func migrateBoundingRects() {
        // Setup an array to hold any migrated rects that will need to be deleted from this node's array of rects
        
        //NSMutableArray *migratedBoundingRects = [[NSMutableArray alloc] init];
        var migratedBoundingRects : [CGRect] = []
        
        for value in boundingRects! {
            
            if migrateBoundingRect(value) {
                // Can't delete during fast enumeration.  Save to be deleted
                migratedBoundingRects.append(value)
            }
        
        }
        
        if migratedBoundingRects.count > 0 {
            
            for value in migratedBoundingRects {
                if let index = boundingRects?.index(of: value) {
                    boundingRects?.remove(at: index)
                }
            }
            
        }
        
        if (boundingRects?.count == 0) {
            // All nodes were moved.  Free up empty array
            self.boundingRects = nil;
        }
    }
    
    /**
     Migrate an existing bounding rect to any sub quad that can enclose it
     
     @param boundingRect The bounding rect to insert into a sub quad
     
     @return YES if the bounding rect fit within a sub quad and was migrated, else NO
     */
    func migrateBoundingRect(_ boundingRect : CGRect) -> Bool {
        
        /*if let topLQ = topLeftQuad , topRQ = topRightQuad, bottomLQ = bottomLeftQuad, bottomRQ = bottomRightQuad {
            
        }*/
        
        
        
        if ((topLeftQuad != nil) && topLeftQuad!.insertBoundingRect(boundingRect)) ||
            ((topRightQuad != nil) && topRightQuad!.insertBoundingRect(boundingRect)) ||
            ((bottomLeftQuad != nil) && bottomLeftQuad.insertBoundingRect(boundingRect)) ||
            ((bottomRightQuad != nil) && bottomRightQuad!.insertBoundingRect(boundingRect)) {
            // Bounding rect migrated to a sub quad
            return true
        }
        
        return false
    }
    
    
    open override var debugDescription: String {
        return "<\(self.self): \(self)> frame = \(frame); boundingRects = \(boundingRects); topLeftQuad = \(topLeftQuad.debugDescription); topRightQuad = \(topRightQuad.debugDescription); bottomLeftQuad = \(bottomLeftQuad.debugDescription); bottomRightQuad = \(bottomRightQuad.debugDescription)"
    }
}

