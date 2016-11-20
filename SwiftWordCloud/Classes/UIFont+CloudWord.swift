//
//  UIFont+Extenstion.swift
//  WordCloud-Swift
//
//  Created by Saleh AlDhobaie on 11/1/16.
//  Copyright © 2016 Saleh AlDhobaie. All rights reserved.
//

import Foundation
import UIKit

public extension UIFont {
    
    /* @nonobjc */
//    public static let kLALsystemPointSize : CGFloat = 16.0
//    class let kLALsystemPointSize : CGFloat = 16.0
    
    public class func kLALsystemPointSize() -> CGFloat {
        return 16.0
    }


    /**
     Returns the count of font choices available to the user
     
     @return The total number of possible font choices
     */
    public class func lal_numberOfPreferredFonts() -> Int {
        return 8
    }
    
    /**
     Returns a content (point) size delta based on the user's preferred content size
     
     This is used to adjust the font pointSize for fonts which aren't the system font
     
     @return A delta point size
     */
    class func lal_preferredContentSizeDelta() -> CGFloat {
        
        let pointSizeDeltas = [
            UIContentSizeCategory.accessibilityExtraExtraExtraLarge: 6.0,
            UIContentSizeCategory.accessibilityExtraExtraLarge: 5.0,
            UIContentSizeCategory.accessibilityExtraLarge: 4.0,
            UIContentSizeCategory.accessibilityLarge: 4.0,
            UIContentSizeCategory.accessibilityMedium: 3.0,
            UIContentSizeCategory.extraExtraExtraLarge: 3.0,
            UIContentSizeCategory.extraExtraLarge: 2.0,
            UIContentSizeCategory.extraLarge: 1.0,
            UIContentSizeCategory.large: 0.0,
            UIContentSizeCategory.medium: (-1.0),
            UIContentSizeCategory.small: (-2.0),
            UIContentSizeCategory.extraSmall: (-3.0)
        ]
        
        let contentSize : UIContentSizeCategory = UIApplication.shared.preferredContentSizeCategory
        let delta = pointSizeDeltas[contentSize];
        
        return CGFloat(delta!)
    }




}
