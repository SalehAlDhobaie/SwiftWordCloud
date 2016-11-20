//
//  UIColor+CloudWord.swift
//  WordCloud-Swift
//
//  Created by Saleh AlDhobaie on 11/1/16.
//  Copyright © 2016 Saleh AlDhobaie. All rights reserved.
//

import Foundation
import UIKit


public enum LALSettingsColor : Int {
    case blueGreen
    case magentaBlue
    case mustardRed
    case greenBlue
    case coralReef
    case spicyOlive
    case maroonGrey
    case black
    case white
    
    
    var colors : [UIColor] {
        switch self {
            
        case .blueGreen :
            return [
            UIColor(hue:216.0/360.0, saturation:1.0, brightness:0.3, alpha:1.0),
            UIColor(hue:216.0/360.0, saturation:0.9, brightness:0.8, alpha:1.0),
            UIColor(hue:216.0/360.0, saturation:0.8, brightness:1.0, alpha:1.0),
            UIColor(hue:184.0/360.0, saturation:0.9, brightness:0.8, alpha:1.0),
            UIColor(hue:152.0/360.0, saturation:0.9, brightness:0.8, alpha:1.0),
            ]
        case .magentaBlue :
            return [
            UIColor(hue:306.0/360.0, saturation:1.0, brightness:0.3, alpha:1.0),
            UIColor(hue:306.0/360.0, saturation:0.9, brightness:0.8, alpha:1.0),
            UIColor(hue:306.0/360.0, saturation:0.8, brightness:0.6, alpha:1.0),
            UIColor(hue:274.0/360.0, saturation:0.9, brightness:0.8, alpha:1.0),
            UIColor(hue:242.0/360.0, saturation:0.9, brightness:0.8, alpha:1.0),
            ]
        case .mustardRed :
            return [
            UIColor(hue: 36.0/360.0, saturation:1.0, brightness:0.3, alpha:1.0),
            UIColor(hue: 36.0/360.0, saturation:0.9, brightness:0.8, alpha:1.0),
            UIColor(hue: 36.0/360.0, saturation:0.8, brightness:1.0, alpha:1.0),
            UIColor(hue:  4.0/360.0, saturation:0.9, brightness:0.8, alpha:1.0),
            UIColor(hue:332.0/360.0, saturation:0.9, brightness:0.8, alpha:1.0),
            ]
        case .greenBlue :
            return [
            UIColor(hue:126.0/360.0, saturation:1.0, brightness:0.3, alpha:1.0),
            UIColor(hue:126.0/360.0, saturation:0.9, brightness:0.8, alpha:1.0),
            UIColor(hue:126.0/360.0, saturation:0.8, brightness:0.6, alpha:1.0), // Brightness 0.6 instead of 1.0
            UIColor(hue:190.0/360.0, saturation:0.9, brightness:0.8, alpha:1.0), // Hue + 64 instead of - 32
            UIColor(hue:222.0/360.0, saturation:0.9, brightness:0.8, alpha:1.0), // Hue + 96 instead of - 64
            ]
        case .coralReef :
            return [
            UIColor(red: 51.0/255.0, green: 77.0/255.0, blue: 92.0/255.0, alpha:1.0),
            UIColor(red:226.0/255.0, green:122.0/255.0, blue: 63.0/255.0, alpha:1.0),
            UIColor(red:239.0/255.0, green:201.0/255.0, blue: 76.0/255.0, alpha:1.0),
            UIColor(red: 69.0/255.0, green:178.0/255.0, blue:157.0/255.0, alpha:1.0),
            UIColor(red:223.0/255.0, green: 90.0/255.0, blue: 73.0/255.0, alpha:1.0),
            ]
        case .spicyOlive :
            
            return [
            UIColor(red:242.0/255.0, green: 92.0/255.0, blue:  5.0/255.0, alpha:1.0),
            UIColor(red:136.0/255.0, green:166.0/255.0, blue: 27.0/255.0, alpha:1.0),
            UIColor(red:242.0/255.0, green:159.0/255.0, blue:  5.0/255.0, alpha:1.0),
            UIColor(red:217.0/255.0, green: 37.0/255.0, blue: 37.0/255.0, alpha:1.0),
            UIColor(red: 47.0/255.0, green:102.0/255.0, blue:179.0/255.0, alpha:1.0),
            ]
        case .maroonGrey :
            return [
            UIColor(hue:17.0/360.0, saturation:1.0, brightness:0.4, alpha:1.0),
            UIColor(hue:17.0/360.0, saturation:0.0, brightness:0.0, alpha:1.0),
            UIColor(hue:17.0/360.0, saturation:0.0, brightness:0.3, alpha:1.0),
            UIColor(hue:17.0/360.0, saturation:0.3, brightness:0.6, alpha:1.0),
            UIColor(hue:17.0/360.0, saturation:1.0, brightness:0.6, alpha:1.0),
            ]
            
        case .black :
            return [UIColor.black]
        case .white :
            return [UIColor.white]
        }
    }
    
    
    
    
}

extension UIColor {
    
    /**
     Returns the count of color choices available to the user
     
     @return The total number of possible color choices
     */
    class func lal_numberOfPreferredColors() -> Int {
        return 9
    }
    /**
     Returns an array of colors associated with the preferred color choice
     
     @param preferredColor An enum representing the user's preferred color preference
     
     @return An array of colors associated with the specified preferredColor enum
     */
    class func lal_colorsForPreferredColor(_ preferredColor : LALSettingsColor) -> [UIColor] {
        
        return preferredColor.colors
    }
    /**
     Returns the background color associated with the preferred color choice
     
     @param preferredColor An enum representing the user's preferred color preference
     
     @return A background color associated with the specified preferredColor enum
     */
    class func lal_backgroundColorForPreferredColor(_ preferredColor: LALSettingsColor) -> UIColor {
        return preferredColor == .white ? UIColor.black : UIColor.white
    }
    /**
     Returns the sample attributed text with the preferred color choice
     
     @param preferredColor An enum representing the user's preferred color preference
     
     @return A sample attributed string with the specified preferredColor
     */
    class func lal_attributedTextWithPreferredColor(_ preferredColor : LALSettingsColor, contentSizeDelta:CGFloat) -> NSAttributedString {
        
        let colors = UIColor.lal_colorsForPreferredColor(preferredColor)
        
        let isMonochrome : Bool = (colors.count == 1)
        
        let fontName : String = UIFont.systemFont(ofSize: 16.0).fontName
        var attributes : [String : AnyObject] = [
            NSFontAttributeName : UIFont(name: fontName, size:20.0 + contentSizeDelta)!,
            NSForegroundColorAttributeName : colors.first!
        ]
        
        
        let attributedText : NSMutableAttributedString = NSMutableAttributedString(string: "Jesus", attributes: attributes)
        
        
        attributes = [
            NSFontAttributeName : UIFont(name:fontName, size:18.0 + contentSizeDelta)!,
            NSForegroundColorAttributeName : isMonochrome ? colors[0] : colors[1] ]
        
        let attribute2 = NSAttributedString(string:"Christ" ,attributes: attributes);
        attributedText.append(attribute2)
        
        
        attributes = [
            NSFontAttributeName : UIFont(name:fontName, size:16.0 + contentSizeDelta)!,
            NSForegroundColorAttributeName : isMonochrome ? colors[0] : colors[2] ]
        
        attributedText.append(NSAttributedString(string:"King" ,attributes: attributes))
        
        attributes = [
            NSFontAttributeName : UIFont(name:fontName, size:14.0 + contentSizeDelta)!,
            NSForegroundColorAttributeName : isMonochrome ? colors[0] : colors[3] ]
        
        attributedText.append(NSAttributedString(string:"of" ,attributes: attributes))
        
        attributes = [
            NSFontAttributeName : UIFont(name:fontName, size:12.0 + contentSizeDelta)!,
            NSForegroundColorAttributeName : isMonochrome ? colors[0] : colors[4] ]
        
        attributedText.append(NSAttributedString(string:"kings" ,attributes: attributes))
        
        return attributedText;
        
    }

    
    
    
}
