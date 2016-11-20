//
//  CloudWord.swift
//  WordCloud-Swift
//
//  Created by Saleh AlDhobaie on 10/31/16.
//  Copyright © 2016 Saleh AlDhobaie. All rights reserved.
//

import Foundation
import UIKit


/**
 A cloud word, consisting of text, and word weight
 
 It includes layout information, such as pointSize, and geometry
 */
open class CloudWord : NSObject {
    /**
     Returns the word that the cloud will display
     */
    open var wordText : String
    /**
     Returns an index for the color of this word
     */
    open var wordColor : UInt!
    /**
     Returns the unweighted number of occurrences of this word in the source
     */
    open var wordCount : Int!
    /**
     Returns the word's size, in points.  Based on the normalized word count of all the
     cloud words
     
     @note The cloud model has no details about the font that the view will use
     */
    open var pointSize : CGFloat!
    /**
     Returns the word's preferred location in the cloud, centered on the word
     */
    open var boundsCenter : CGPoint!
    /**
     Returns the oriented word's dimensions
     
     @note A horizontal word would generally be wider than it is tall.  A vertical word
     would generally be taller than it is wide
     */
    open var boundsSize : CGSize!
    /**
     Returns the computed area of the bounds size
     
     @note The cloud will sort and layout its words by descending area
     */
    open var boundsArea : CGFloat! {
        get {
            return self.boundsSize.width * self.boundsSize.height
        }
    }
    /**
     Returns the oriented word's computed frame, based on its boundsCenter and boundsSize
     */
    open var frame : CGRect {
        get {
            return CGRect(x: self.boundsCenter.x - self.boundsSize.width / 2.0,
                              y: self.boundsCenter.y - self.boundsSize.height / 2.0,
                              width: self.boundsSize.width,
                              height: self.boundsSize.height)
        }
    }
    /**
     Returns a Boolean value indicating whether the word orientation is vertical
     */
    //@property (nonatomic, assign, getter=isWordOrientationVertical) BOOL wordOrientationVertical;
    open var wordOrientationVertical: Bool!
        
    /**
     Initializes a newly allocated CloudWord object
     
     @param aWord The word that the cloud will display
     
     @param wordCount The unweighted number of occurrences of this word in the source
     
     @return An initialized CloudWord object
     */
    
    init(word: String, wordCount: Int) {
        
        self.wordText = word.characters.count > 0 ? word : "??"
        self.wordCount = wordCount > 0 ? wordCount :  1
        // Cloud layout will assign point size based on normalized word counts
        // Once the point size is known, cloud layout will determine the word's orientation and geometry
        
    }
    
    
    convenience override init() {
        let wordCount = 7
        self.init(word: "Default Value", wordCount: wordCount)
    }
    /**
     Assign an indexed color to the word
     
     @param scale The scale of the word in relation to the most frequent word
     
     @note Sets self.wordColor
     */
    func determineColorForScale(_ scale : CGFloat) {
        if (scale >= 0.95) // 5%
        {
            self.wordColor = 0;
        }
        else if (scale >= 0.8) // 15%
        {
            self.wordColor = 1;
        }
        else if (scale >= 0.55) // 25%
        {
            self.wordColor = 2;
        }
        else if (scale >= 0.30) // 25%
        {
            self.wordColor = 3;
        }
        else // 30%
        {
            self.wordColor = 4;
        }

    }
    /**
     Assign a random word orientation to the word
     
     @param containerSize The size of the container that the word will be oriented in
     
     @param scale The scale factor associated with the device's screen
     
     @param fontName The name of the font that the word will use
     
     @note Sets self.wordOrientationVertical and self.boundsSize
     */
    
    fileprivate static let containerMargin : CGFloat = 16.0;

    func determineRandomWordOrientationInContainerWithSize(_ containerSize: CGSize, scale:CGFloat, fontName:String) {
        
        // Assign random word orientation (10% chance for vertical)
        
        
        let isVertical = (arc4random_uniform(10) == 0)
        sizeWordVertical(isVertical, scale: scale, fontName: fontName)
        
        
        // Check word size against container smallest dimension
        let isPortrait : Bool = containerSize.height > containerSize.width
        
        
        if (isPortrait && !wordOrientationVertical && boundsSize.width >= containerSize.width - CloudWord.containerMargin) {
            
            // Force vertical orientation for horizontal word that's too wide
            sizeWordVertical(true, scale:scale, fontName:fontName)
        }
        else if (!isPortrait && wordOrientationVertical && boundsSize.height >= containerSize.height - CloudWord.containerMargin) {
            
            // Force horizontal orientation for vertical word that's too tall
            sizeWordVertical(false, scale:scale, fontName:fontName)
        }
        
    }
    
    /**
     Assign an integral random center point to the word
     
     @param containerSize The size of the container that the word will be positioned in
     
     @param scale The scale factor associated with the device's screen
     
     @note Sets self.boundsCenter
     */
    func determineRandomWordPlacementInContainerWithSize(_ containerSize : CGSize, scale:CGFloat) {
        
        var randomGaussianPoint : CGPoint = randomGaussian()
        
        // Place bounds upon standard normal distribution to ensure word is placed within the container
        
        while (fabs(randomGaussianPoint.x) > 5.0 || fabs(randomGaussianPoint.y) > 5.0) {
            randomGaussianPoint = randomGaussian()
        }
        
        // Midpoint +/- 50%
        let xOffset : CGFloat = (containerSize.width / 2.0) + (randomGaussianPoint.x * ((containerSize.width - self.boundsSize.width) * 0.1));
        let yOffset : CGFloat = (containerSize.height / 2.0) + (randomGaussianPoint.y * ((containerSize.height - self.boundsSize.height) * 0.1));
        
        // Return an integral point
        let x = roundValue(xOffset, scale: scale)
        let y = roundValue(yOffset, scale: scale)
        boundsCenter = CGPoint(x: x, y: y)
    }
    
    /**
     Assign a new integral center point to the word
     
     @param center The center point to be offset
     
     @param xOffset The x offset to apply to the given center
     
     @param yOffset The y offset to apply to the given center
     
     @param scale The scale factor associated with the device's screen
     
     @note Sets self.boundsCenter
     */
    func determineNewWordPlacementFromSavedCenter(_ center: CGPoint, xOffset: CGFloat, yOffset:CGFloat, scale: CGFloat) {
        
        let xOffsetValue = xOffset + center.x
        let yOffsetValue = yOffset + center.y
        
        // Assign an integral point
        let x = roundValue(xOffsetValue, scale: scale)
        let y = roundValue(yOffsetValue, scale: scale)
        boundsCenter = CGPoint(x: x, y: y)
    }
    /**
     Returns a padded frame to provide whitespace between words, or between a word and the container edge
     
     @return The padded frame adjusted for leading/trailing space
     */
    func paddedFrame() -> CGRect {
    
        let dx = wordOrientationVertical == true ? -2.0 : -5.0
        let dy = wordOrientationVertical == true ? -5.0 : -2.0
        
        return self.frame.insetBy(dx: CGFloat(dx), dy: CGFloat(dy))
    }
    
    
    //MARK: Private Method
    
    /**
     Sizes the word for a given orientation
     
     @param isVertical Whether the word orientation is vertical
     
     @param scale The scale factor associated with the device's screen
     
     @param fontName The name of the font that the word will use
     
     @note Sets self.wordOrientationVertical and self.boundsSize
     */
    func sizeWordVertical(_ isVertical: Bool, scale: CGFloat, fontName: String) {
    
    self.wordOrientationVertical = isVertical
    
        
        
        let attributes : [String : AnyObject] = [
        NSFontAttributeName : UIFont(name :fontName, size: self.pointSize)!
        ]
        
        let attributedWord : NSAttributedString = NSAttributedString(string: self.wordText, attributes: attributes)
        
        let attributedWordSize : CGSize = attributedWord.size()
    
        // Round up fractional values to integral points
    
        if wordOrientationVertical == true {
            
            // Vertical orientation.  Width <- sized height.  Height <- sized width
            
            let ceilValueWidth = ceilValue(attributedWordSize.height, scale: scale)
            let ceilValueHeight = ceilValue(attributedWordSize.width, scale: scale)
            
            boundsSize = CGSize(width: ceilValueWidth, height: ceilValueHeight)
        
        } else {
            let ceilValueWidth = ceilValue(attributedWordSize.width, scale: scale)
            let ceilValueHeight = ceilValue(attributedWordSize.height, scale: scale)
            
            boundsSize = CGSize(width: ceilValueWidth, height: ceilValueHeight)
            
        }
    }
    
    /**
     Returns two (pseudo-)random gaussian numbers
     
     @return A random gaussian CGPoint, distributed around { 0, 0 }
     */
    func randomGaussian() -> CGPoint {
        var x1, x2, w : CGFloat
        
        repeat {
            // drand48() less random but faster than ((float)arc4random() / UINT_MAX)
            x1 = 2.0 * CGFloat(drand48()) - 1.0;
            x2 = 2.0 * CGFloat(drand48()) - 1.0;
            w = x1 * x1 + x2 * x2;
        } while (w >= 1.0);
        
        w = sqrt((-2.0 * log(w)) / w);
        return CGPoint(x: x1 * w, y: x2 * w);
        
        
    }
    
    /**
     Returns a CGFloat rounded to the nearest integral pixel
     
     @param value A (fractional) coordinate
     
     @return A device-independent coordinate, rounded to the nearest device-dependent pixel
     
     @note Integral coordinates are not necessarily integer coordinates on a retina device
     */
    func roundValue(_ value : CGFloat, scale: CGFloat) -> CGFloat {
        let rValue = round(value * scale)
        return rValue / scale
    }
    
    /**
     Returns a CGFloat rounded up to the next integral pixel
     
     @param value A (fractional) coordinate
     
     @return A device-independent coordinate, rounded up to the next device-dependent pixel
     
     @note Integral coordinates are not necessarily integer coordinates on a retina device
     */
    func ceilValue(_ value : CGFloat, scale: CGFloat) -> CGFloat {
        return ceil(value * scale) / scale;
    }

    
    open override var debugDescription: String {
        return "<\(self.self): \(self)> word = \(wordText); wordCount = \(wordCount); pointSize = \(pointSize); center = \(boundsCenter); vertical = \(wordOrientationVertical); size = \(boundsSize); area = \(boundsArea)"
    }
}
