//
//  CloudLayoutOperation.swift
//  WordCloud-Swift
//
//  Created by Saleh AlDhobaie on 10/31/16.
//  Copyright © 2016 Saleh AlDhobaie. All rights reserved.
//

import UIKit
import CoreText
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


protocol CloudLayoutOperationDelegate : NSObjectProtocol {
    /**
     Insert a title into the delegate's cloud view
     
     @param cloudTitle The descriptive title (source) to be displayed in the cloud
     */
    
    func insertTitle(_ cloudTitle: String)
    
    /**
     Insert a word into the delegate's cloud view
     
     @param word The word to be displayed in the cloud
     
     @param pointSize The word's font pointsize
     
     @param color The word's color index
     
     @param center The word's center point
     
     @param isVertical Whether the word orientation is vertical
     */
    func insertWord(_ word: String, pointSize: CGFloat, color: Int, center: CGPoint, vertical: Bool)

    #if DEBUG
    /**
     Insert a bounding rect into the delegate's cloud view
     
     @param boundingRect The bounding rect to be displayed in the cloud
     */
    //optional func insertBoundingRect(boundingRect: CGRect)
    func insertBoundingRect(_ boundingRect: CGRect)
    #endif

}

class CloudLayoutOperation: Operation {
    
    //MARK: vars
    
    /**
     The name of the font that the cloud will use for its words
     */
    fileprivate var cloudFont : String!
    /**
     The descriptive title (source) for the words
     */
    fileprivate var cloudTitle : String!
    /**
     A strong reference to our cloud's list of words
     */
    fileprivate var cloudWords: [CloudWord]
    /**
     The size of the container that the words must fit in
     */
    fileprivate var containerSize : CGSize!
    /**
     The scale of the container that the words must fit in
     
     @note This is the same as [[UIScreen mainScreen] scale]
     */
    fileprivate var containerScale : CGFloat!
    
    /**
     A weak reference to the cloud layout operation's delegate
     */
    fileprivate weak var delegate: CloudLayoutOperationDelegate!
    
    /**
     A strong reference to a quadtree of cloud word (glyph) bounding rects
     */
    fileprivate var glyphBoundingRects : QuadTree!

    /**
     Initialize a cloud layout operation
     
     @param cloudWords A dictionary of words and their word counts
     
     @param title The descriptive title (source) for the words
     
     @param fontName The name of the font that the words will use
     
     @param containerSize The size of the delegate's container (view) that the words must fit in
     
     @param containerScale The scale factor associated with the device's screen
     
     @param delegate The delegate which will receive word layout and progress updates
     */
    init(cloudWords : [CloudWord], title: String, fontName: String, forContainerSize containerSize: CGSize, withScale containerScale: CGFloat, delegate: CloudLayoutOperationDelegate) {
        
        // Custom initialization
        
        //var words : [CloudWord] = []
        //NSMutableArray *words = [[NSMutableArray alloc] initWithCapacity:[cloudWords count]];
        self.cloudWords = cloudWords
        self.cloudTitle = title
        self.cloudFont = fontName
        self.containerSize = containerSize
        self.containerScale = containerScale
        self.delegate = delegate
        
        
        //
        let frame = CGRect(x: 0.0, y: 0.0, width: containerSize.width, height: containerSize.height)
        self.glyphBoundingRects = QuadTree(frame: frame)
        
        
    }
    
    //MARK - Private methods
    
    internal override func main() {
        
        if isCancelled == true {
            return;
        }
        
        layoutCloudTitle()
        
        if isCancelled == true {
            return;
        }
        
        normalizeWordWeights()
        
        if isCancelled == true {
            return;
        }
        
        assignColorsForWords()
        
        if isCancelled == true {
            return;
        }
        
        assignPreferredPlacementsForWords()
        
        if isCancelled == true {
            return;
        }
        
        reorderWordsByDescendingWordArea()
        
        if isCancelled == true {
            return;
        }
        
        layoutCloudWords()
    }
    
    func normalizeWordWeights() {
        
        // Determine minimum and maximum weight of words
        
        
        let minWordCloudObject = cloudWords.min { (value1, value2) -> Bool in
            return value1.wordCount < value2.wordCount
            }?.wordCount
        
        let minWordCount : CGFloat = CGFloat(minWordCloudObject!)
        
        
//        let minWordCount : CGFloat = ((cloudWords as NSArray).valueForKeyPath("@min.wordCount")?.flatness!)!
        
        let maxWordCloudObject = cloudWords.max { (value1, value2) -> Bool in
            return value1.wordCount < value2.wordCount
            }?.wordCount
        
        let maxWordCount : CGFloat = CGFloat(maxWordCloudObject!)
        
//        let maxWordCount : CGFloat = ((cloudWords as NSArray).valueForKeyPath("@max.wordCount")?.flatness!)!
        
        let deltaWordCount : CGFloat = maxWordCount - minWordCount
        let ratioCap : CGFloat = 20.0
        
        //MARK: FIXME!!
        //#pragma clang diagnostic push
        //#pragma clang diagnostic ignored "-Wgnu-statement-expression"
        //CGFloat maxMinRatio = MIN((maxWordCount / minWordCount), ratioCap);
        //#pragma clang diagnostic pop
        
        // MIN((maxWordCount / minWordCount), ratioCap);
        let maxMinRatio : CGFloat = min((maxWordCount / minWordCount), ratioCap)
        
        // Start with these values, which will be decreased as needed that all the words may fit the container
        
        var fontMin : CGFloat = 12.0;
        var fontMax : CGFloat = fontMin * maxMinRatio
        
        let dynamicTypeDelta : Int = Int(UIFont.lal_preferredContentSizeDelta())
        
        let containerArea : CGFloat = self.containerSize.width * self.containerSize.height * 0.9;
        var wordAreaExceedsContainerSize : Bool = false
        
        repeat {
            
            var wordArea : CGFloat = 0.0
            wordAreaExceedsContainerSize = false
            
            let fontRange : CGFloat = fontMax - fontMin
            let fontStep : CGFloat = 3.0
            
            // Normalize word weights
            
            for word in cloudWords {
                if isCancelled == true {
                    return;
                }
                
                let scale : CGFloat = ( CGFloat(word.wordCount) - minWordCount) / deltaWordCount;
                word.pointSize = fontMin + (fontStep * floor(scale * (fontRange / fontStep))) + CGFloat(dynamicTypeDelta)
                
                word.determineRandomWordOrientationInContainerWithSize(containerSize, scale:containerScale, fontName:cloudFont)
                
                // Check to see if the current word fits in the container
                wordArea += word.boundsArea
                
                if (wordArea >= containerArea || word.boundsSize.width >= self.containerSize.width || word.boundsSize.height >= self.containerSize.height)
                {
                    wordAreaExceedsContainerSize = true
                    fontMin-=1
                    fontMax = fontMin * maxMinRatio;
                    break;
                }
            }
        } while (wordAreaExceedsContainerSize == true)
    
        
        return;
    }
    
    /**
     */
    func assignColorsForWords() {
        
        let cloudWordsCount : Int = cloudWords.count;
        
        
        for (index, word) in cloudWords.enumerated() {
            
            if isCancelled == true {
                break
            }
            let scale : CGFloat = CGFloat((cloudWordsCount - index) / cloudWordsCount)
            word.determineColorForScale(scale)
            
        }
        
        /*
        [self.cloudWords enumerateObjectsUsingBlock:^(CloudWord *word, NSUInteger index, BOOL *stop) {
            *stop = [self isCancelled];
            CGFloat scale = (cloudWordsCount - index) / cloudWordsCount;
            [word determineColorForScale:scale];
            }];
        */
        
    }
    
    /**
     Assigns a preferred placement location for each cloud word
     */
    func assignPreferredPlacementsForWords() {
        
        for word in cloudWords {
            if isCancelled == true {
                return;
            }
            
            // Assign a new preferred location for each word, as the size may have changed
            word.determineRandomWordPlacementInContainerWithSize(containerSize, scale:containerScale)
        }
    }
    
    func reorderWordsByDescendingWordArea() {
        
//        let primarySortDescriptor : NSSortDescriptor = NSSortDescriptor(key: "boundsArea", ascending: false)
        
//        let secondarySortDescriptor : NSSortDescriptor = NSSortDescriptor(key: "pointSize", ascending: false)
//        print("Before \(cloudWords)")
        
        cloudWords = cloudWords.sorted { (value1, value2) -> Bool in
            return value1.boundsArea < value2.boundsArea && value1.pointSize < value2.pointSize
        }
//        print("First \(cloudWords)")
//        cloudWords = cloudWords.sort { (value1, value2) -> Bool in
//            return value1.pointSize < value2.pointSize
//        }
//        print("Second \(cloudWords)")
        
//        cloudWords = (cloudWords as NSArray).sortedArrayUsingDescriptors([primarySortDescriptor, secondarySortDescriptor]) as! [CloudWord]
        
    }
    
    
    func layoutCloudTitle() {
        
        
        let sizingButton : UIButton = UIButton(type: .system)
        sizingButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 8.0, 5.0, 2.0);
        
        sizingButton.setTitle(cloudTitle, for:UIControlState())
        let pointSize : CGFloat = UIFont.kLALsystemPointSize() + UIFont.lal_preferredContentSizeDelta()
        
        sizingButton.titleLabel!.font = UIFont.systemFont(ofSize: pointSize)
        
        // UIKit sizeToFit is not thread-safe
        sizingButton.performSelector(onMainThread: #selector(sizingButton.sizeToFit), with: nil, waitUntilDone: true)
        
        let bounds : CGRect = CGRect(x: 0.0, y: containerSize.height - sizingButton.bounds.height, width: sizingButton.bounds.width, height: sizingButton.bounds.height)
        
        _ = glyphBoundingRects.insertBoundingRect(bounds)
        
        DispatchQueue.main.async {
            #if DEBUG
            self.delegate.insertTitle(self.cloudTitle)
            #endif
        }
    }
    
    func layoutCloudWords() {
        
        for word in cloudWords {
            
            if isCancelled == true {
                return;
            }
            
            // Can the word can be placed at its preferred location?
            if hasPlacedWord(word){
                // Yes. Move on to the next word
                continue;
            }
            
            var placed = false
            
            // If there's a spot for a word, it will almost always be found within 50 attempts.
            // Make 100 attempts to handle extremely rare cases where more than 50 attempts are needed to place a word
            
            for _ in 0..<100 {
                
                // Try alternate placements along concentric circles
                if self.hasFoundConcentricPlacementForWord(word) {
                    placed = true
                    break;
                }
                
                if isCancelled == true {
                    return;
                }
                
                // No placement found centered on preferred location. Pick a new location at random
                word.determineRandomWordOrientationInContainerWithSize(self.containerSize, scale:self.containerScale, fontName:cloudFont)
                word.determineRandomWordPlacementInContainerWithSize(self.containerSize, scale:self.containerScale)
            }
            
            /*
            for (NSUInteger attempt = 0; attempt < 100; attempt++) {
                // Try alternate placements along concentric circles
                if hasFoundConcentricPlacementForWord(word) {
                    placed = true
                    break;
                }
                
                
                if cancelled == true) {
                    return;
                }
                
                // No placement found centered on preferred location. Pick a new location at random
                word.determineRandomWordOrientationInContainerWithSize(containerSize, scale:containerScale, fontName:cloudFont)
                word.determineRandomWordPlacementInContainerWithSize(containerSize, scale:containerScale)
            }*/
            
            // Reduce font size if word doesn't fit
            #if DEBUG
            if placed == false {
                print("Couldn't find a spot for %@", word.debugDescription);
            }
            #endif
            
        }
    }

    func hasFoundConcentricPlacementForWord(_ word :CloudWord) -> Bool {
        
        let containerRect : CGRect = CGRect(x: 0.0, y: 0.0, width: self.containerSize.width, height: self.containerSize.height);
        let savedCenter : CGPoint = word.boundsCenter;
        
        var radiusMultiplier : Int = 1; // 1, 2, 3, until radius too large for container
        
        var radiusWithinContainerSize : Bool = true
        
        // Placement terminated once no points along circle are within container
        
        while (radiusWithinContainerSize)
        {
            // Start with random angle and proceed 360 degrees from that point
            
            let initialDegree : Int = Int(arc4random_uniform(360))
            let finalDegree  : Int = initialDegree + 360
            
            // Try more points along circle as radius increases
            
            let degreeStep : Int = radiusMultiplier == 1 ? 15 : radiusMultiplier == 2 ? 10 : 5;
            
            let radius : CGFloat = CGFloat(radiusMultiplier) * word.pointSize;
            
            radiusWithinContainerSize = false // NO until proven otherwise
            
            
            var degrees = initialDegree
            while degrees < finalDegree {
                
                if isCancelled == true {
                    return false
                }
                
                let radians : Double = Double(degrees) * M_PI / 180.0;
                
                let x : CGFloat = CGFloat( cos(radians) * Double(radius) )
                let y : CGFloat = CGFloat( sin(radians) * Double(radius) )
                
                word.determineNewWordPlacementFromSavedCenter(savedCenter, xOffset:x, yOffset:y, scale:containerScale)
                
                let wordRect : CGRect = word.paddedFrame()
                
                if containerRect.contains(wordRect) {
                    radiusWithinContainerSize = true
                    if hasPlacedWord(word, atRect:wordRect) {
                        return true
                    }
                }
                
                degrees += degreeStep
            }
            
            
            
            // No placement found for word on points along current radius.  Try larger radius.
            radiusMultiplier+=1
        }
        
        // The word did not fit along any concentric circles within the bounds of the container
        
        return false
    }
    
    func hasPlacedWord(_ word :CloudWord) -> Bool {
        let wordRect : CGRect = word.paddedFrame()
        return hasPlacedWord(word, atRect:wordRect)
    }
    
    func hasPlacedWord(_ word :CloudWord, atRect wordRect: CGRect) -> Bool {
    
        if glyphBoundingRects.hasGlyphThatIntersectsWithWordRect(wordRect) {
            // Word intersects with another word
            return false
        }
        
        // Word doesn't intersect any (glyphs of) previously placed words.  Place it
        
        //__weak id<CloudLayoutOperationDelegate> delegate = self.delegate;
        
        DispatchQueue.main.async { 
            self.delegate.insertWord(word.wordText, pointSize:word.pointSize, color:Int(word.wordColor), center:word.boundsCenter, vertical:word.wordOrientationVertical)
        }
        addGlyphBoundingRectsToQuadTreeForWord(word)
    
    return true
    }
    
    func addGlyphBoundingRectsToQuadTreeForWord(_ word : CloudWord) {
        
        let wordRect : CGRect = word.frame;
        
        // Typesetting is always done in the horizontal direction
        
        // There's a small possibility that a particular typeset word using a particular font, may still not fit within a slightly larger frame.  Give the typesetter a very large frame, to ensure that any word, at any point size, can be typeset on a line
        
        let width : CGFloat = (word.wordOrientationVertical == true) ? self.containerSize.height : self.containerSize.width;
        let height : CGFloat = (word.wordOrientationVertical == true) ? self.containerSize.width : self.containerSize.height;
        let horizontalFrame : CGRect = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        
        let attributes : [String : AnyObject] = [
            NSFontAttributeName : UIFont(name:cloudFont, size:word.pointSize)!
        ]
        
        let attributedString : NSAttributedString = NSAttributedString(string: word.wordText, attributes: attributes)
        
        

        let framesetter : CTFramesetter = CTFramesetterCreateWithAttributedString(attributedString)
        let drawingPath : CGPath = CGPath(rect: horizontalFrame, transform: nil)
        let textFrame : CTFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributedString.length), drawingPath, nil)
        
        // MARK: FIXME !!
        //CFRelease(framesetter)
        //CFRelease(drawingPath)
        
        let lines : CFArray = CTFrameGetLines(textFrame)
        
        let linesCount : CFIndex = CFArrayGetCount(lines)
        if linesCount > 0 {
            
            var lineOrigin : CGPoint = CGPoint.zero
            CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 1), &lineOrigin)
            
            // MARK: FIXME !!!!!
//            let line = UnsafePointer<CTLine>(CFArrayGetValueAtIndex(lines, 0))
            
            var runs = CTLineGetGlyphRuns(unsafeBitCast(CFArrayGetValueAtIndex(lines, 0), to: CTLine.self)) as [AnyObject] as! [CTRun]
            
            runs = runs.reversed()
            
            
            var runIndex : CFIndex = 0
            while runIndex < CFArrayGetCount(runs as CFArray!) {
                // MARK: FIXME !!!!!
//                let runValue : UnsafePointer<CTRun> = UnsafePointer<CTRun>(CFArrayGetValueAtIndex(runs, runIndex))
//                let run : CTRunRef = runValue.memory
                let run : CTRun = unsafeBitCast(CFArrayGetValueAtIndex(runs as CFArray!, runIndex), to: CTRun.self)
                
                let runAttributes : CFDictionary =  CTRunGetAttributes(run)
                
                // MARK: FIXME !!!!!
                
//                let fontValue = UnsafePointer<CTFont>(CFDictionaryGetValue(runAttributes, NSFontAttributeName))
//                let font : CTFontRef = fontValue.memory
                let dictionary : NSDictionary = NSDictionary(dictionary: runAttributes)
                let font : CTFont = dictionary[NSFontAttributeName] as! CTFont
                
//                let font : CTFontRef = unsafeBitCast(CFDictionaryGetValue(runAttributes!, NSFontAttributeName), CTFont.self)
                
                
                var glyphIndex : CFIndex = 0
                
                while glyphIndex < CTRunGetGlyphCount(run) {
                    
                    var glyphPosition : CGPoint  = CGPoint.zero
                    CTRunGetPositions(run, CFRangeMake(glyphIndex, 1), &glyphPosition);
                    
                    var glyph : CGGlyph = CGGlyph()
                    CTRunGetGlyphs(run, CFRangeMake(glyphIndex, 1), &glyph);
                    
                    var glyphBounds : CGRect = CGRect.zero
                    
                    CTFontGetBoundingRectsForGlyphs(font, CTFontOrientation.default, &glyph, &glyphBounds, 1)

                    var glyphRect : CGRect = CGRect.zero
                    
                    var glyphX : CGFloat = lineOrigin.x + glyphPosition.x + glyphBounds.minX;
                    var glyphY : CGFloat = horizontalFrame.height - (lineOrigin.y + glyphPosition.y + glyphBounds.maxY);
                    
                    let status = CTRunGetStatus(run)
                    switch status {
                    case CTRunStatus.rightToLeft:
                        
                        // https://github.com/PetahChristian/LionAndLamb/issues/1
//                        glyphX = lineOrigin.x - wordRect.origin.x - CGRectGetMaxX(glyphBounds)
//                        glyphX = CGRectGetMaxX(glyphBounds) - glyphPosition.x - glyphBounds.size.width
                        glyphX = horizontalFrame.width - (lineOrigin.x + glyphPosition.x + glyphBounds.maxX)
                        glyphY = horizontalFrame.height - (lineOrigin.y + glyphPosition.y + glyphBounds.maxY);
                        
                        break
                    default:
//                        glyphX = lineOrigin.x + glyphPosition.x + CGRectGetMinX(glyphBounds);
//                        glyphY = CGRectGetHeight(horizontalFrame) - (lineOrigin.y + glyphPosition.y + CGRectGetMaxY(glyphBounds));
                        break
                    }
//                    CGFloat glyphX = lineOrigin.x + glyphPosition.x + CGRectGetMinX(glyphBounds);
//                    CGFloat glyphY = CGRectGetHeight(horizontalFrame) - (lineOrigin.y + glyphPosition.y + CGRectGetMaxY(glyphBounds));
                    
                    print("lineOrigin : \(lineOrigin)")
                    if word.wordOrientationVertical == true {
                        let x = wordRect.width - glyphY
                        let height = -(glyphBounds.height)
                        glyphRect = CGRect(x: x, y: glyphX, width: height, height: glyphBounds.width)
                        
                    } else {
                        glyphRect = CGRect(x: glyphX, y: glyphY, width: glyphBounds.width, height: glyphBounds.height)
                    }

                    glyphRect = glyphRect.offsetBy(dx: wordRect.minX, dy: wordRect.minY);
                    
                    /*
                    let status = CTRunGetStatus(run)
                    switch status {
                    case CTRunStatus.RightToLeft:
                    
//                        var newX = glyphRect.origin.x - glyphRect.size.width - wordRect.size.width
//                        var newY = glyphRect.origin.y
//                        if word.wordOrientationVertical == true {
//                            newX = glyphRect.origin.x
//                            newY = glyphRect.origin.y - glyphRect.size.height - wordRect.size.height
//                        }
//                        let width = glyphRect.size.width
//                        let height = glyphRect.size.height
//                        glyphRect = CGRectMake(newX, newY, width, height)
                        break
                    default:
                        break
                    }*/
                    
                    print("glyphRect: \(glyphRect), wordRect : \(wordRect)")
                    _ = self.glyphBoundingRects.insertBoundingRect(glyphRect)
                    glyphIndex += 1
                    #if DEBUG
                        
                        DispatchQueue.main.async {
                            self.delegate.insertBoundingRect(glyphRect)
                        }
                    #endif
                }
            //MARK: FIX ME!!!
            //        CFRelease(textFrame);
                runIndex += 1
            }
            
//            let runs : CFArray = CTLineGetGlyphRuns(line.memory)
//            let runs  = CTLineGetGlyphRuns(line.memory)
//            let runs : CFArrayRef = unsafeBitCast(CTLineGetGlyphRuns(line.memory), CFArrayRef.self)
//            print(CFArrayGetCount(runs))
            
            /*
            for runIndex : CFIndex  in  runIndex..<CFArrayGetCount(runs) {
                
                // MARK: FIXME !!!!!
                let runValue : UnsafePointer<CTRun> = UnsafePointer<CTRun>(CFArrayGetValueAtIndex(runs, runIndex))
                let run : CTRunRef = runValue.memory
                
                let runAttributes : CFDictionaryRef =  CTRunGetAttributes(run)
                
                // MARK: FIXME !!!!!
                let fontValue = UnsafePointer<CTFont>(CFDictionaryGetValue(runAttributes, NSFontAttributeName))
                let font : CTFontRef = fontValue.memory
                
                print(CTRunGetGlyphCount(run))
                
                
                for glyphIndex : CFIndex in glyphIndex..<CTRunGetGlyphCount(run) {
                    
                    var glyphPosition : CGPoint  = CGPointZero
                    CTRunGetPositions(run, CFRangeMake(glyphIndex, 1), &glyphPosition);
                    
                    let glyph : UnsafeMutablePointer<CGGlyph> = UnsafeMutablePointer<CGGlyph>()
                    CTRunGetGlyphs(run, CFRangeMake(glyphIndex, 1), &glyph.memory);
                    
                    var glyphBounds : CGRect = CGRectZero
                    
                    CTFontGetBoundingRectsForGlyphs(font, CTFontOrientation.kCTFontDefaultOrientation, &glyph.memory, &glyphBounds, 1)
                    
                    var glyphRect : CGRect = CGRectZero
                    
                    let glyphX : CGFloat = lineOrigin.x + glyphPosition.x + CGRectGetMinX(glyphBounds);
                    let glyphY : CGFloat = CGRectGetHeight(horizontalFrame) - (lineOrigin.y + glyphPosition.y + CGRectGetMaxY(glyphBounds));
                    
                    if word.wordOrientationVertical == true {
                        let x = CGRectGetWidth(wordRect) - glyphY
                        let height = -(CGRectGetHeight(glyphBounds))
                        glyphRect = CGRectMake(x, glyphX, height, CGRectGetWidth(glyphBounds))
                        
                    } else {
                        glyphRect = CGRectMake(glyphX, glyphY, CGRectGetWidth(glyphBounds), CGRectGetHeight(glyphBounds))
                    }
                    
                    glyphRect = CGRectOffset(glyphRect, CGRectGetMinX(wordRect), CGRectGetMinY(wordRect));
                    self.glyphBoundingRects.insertBoundingRect(glyphRect)
                    
                    #if DEBUG

                        dispatch_async(dispatch_get_main_queue()) {
                            self.delegate.insertBoundingRect(glyphRect)
                            }

                        /*
                                    __weak id<CloudLayoutOperationDelegate> delegate = self.delegate;
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [delegate insertBoundingRect:glyphRect];
                                    });
                         */
                    #endif
                }
            }*/
            
            //MARK: FIX ME!!!
            //        CFRelease(textFrame);
        }
    }


    
    
    

}
