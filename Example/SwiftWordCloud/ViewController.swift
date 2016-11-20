//
//  ViewController.swift
//  WordCloud-Swift
//
//  Created by Saleh AlDhobaie on 10/31/16.
//  Copyright © 2016 Saleh AlDhobaie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    /*
    /**
     A weak reference to the cloud's descriptive title
     */
    @property (nonatomic, weak) IBOutlet UIButton *cloudTitle;
    */
    
    ///**
    // A strong reference to the dictionary of words and their word counts
    // */
    //@property (nonatomic, strong) NSDictionary *cloudWords;
    /**
     A strong reference to an array of UIColor cloud colors
     
     @note These colors are related to the currentColorPreference enum
     */
    let cloudColors : [UIColor] = [UIColor.brown, UIColor.red, UIColor.blue, UIColor.cyan]
    /**
     A strong reference to the current cloud font name
     */
    let cloudFontName : String = "TheSans-Bold"
    /**
     A strong reference to the cloud layout operation queue
     
     @note This is a sequential operation queue that handles the layout for the cloud words
     */
    var cloudLayoutOperationQueue : OperationQueue
    /**
     The current source preference for the cloud's words
     
     @note This is the bible, the old or new testament, or a specific bible book
     */
    
    // var currentSourcePreference : Int
    
    /**
     The current (bible) version preference for the cloud's words
     */
    
    //var currentVersionPreference : Int
    
    /**
     The current font preference for the cloud's words
     */
    /**
     The current color preference for the cloud's words
     */
    // @property (nonatomic, assign) LALSettingsColor currentColorPreference = UIColor.redColor()


    required init?(coder aDecoder: NSCoder) {
        
        
        
        // Custom initialization
        cloudLayoutOperationQueue = OperationQueue()
        cloudLayoutOperationQueue.name = "Cloud layout operation queue"
        cloudLayoutOperationQueue.maxConcurrentOperationCount = 1
        
        super.init(coder: aDecoder)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.contentSizeCategoryDidChange(_:)), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        layoutCloudWords()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //MARK: - <UIStateRestoring>
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder : NSCoder) {
        super.decodeRestorableState(with: coder)
    }
    
    //MARK: - <UIContentContainer>

    override func viewWillTransition(to size : CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with:coordinator);
        coordinator.animate(alongsideTransition: { (context) in
            self.layoutCloudWords()
            }, completion: nil)
    
    }
    
    //MARK: - Notification handlers
    
    /**
     Content size category has changed.  Layout cloud again, to account for new pointSize
     */
    func contentSizeCategoryDidChange(_ notification : Notification) {
        layoutCloudWords()
    }

    func layoutCloudWords() {
        
        // Cancel any in-progress layout
        cloudLayoutOperationQueue.cancelAllOperations()
        cloudLayoutOperationQueue.waitUntilAllOperationsAreFinished()
        
        removeCloudWords()
        
        //self.cloudColors = [UIColor lal_colorsForPreferredColor:self.currentColorPreference];
        //self.view.backgroundColor = [UIColor lal_backgroundColorForPreferredColor:self.currentColorPreference];
        //self.cloudFontName = [UIFont lal_fontNameForPreferredFont:self.currentFontPreference];
        
        
        // Start a new cloud layout operation
        //NSArray *cloudWords = [[LALDataSource sharedDataSource] cloudWordsForTopic:self.currentSourcePreference includeRank:NO stopWords:NO inVersion:self.currentVersionPreference];
        //NSString *cloudTitle = [[LALDataSource sharedDataSource] titleForTopic:self.currentSourcePreference inVersion:self.currentVersionPreference];
        
        var cloudWords : [CloudWord] = []
        
        
//        let strings = "هناك حقيقة مثبتة منذ زمن طويل وهي أن المحتوى المقروء لصفحة ما سيلهي القارئ عن التركيز على الشكل الخارجي للنص أو شكل توضع الفقرات في الصفحة التي يقرأها. ولذلك يتم استخدام طريقة لوريم إيبسوم لأنها تعطي توزيعاَ طبيعياَ -إلى حد ما- للأحرف عوضاً عن استخدام هنا يوجد محتوى نصي، هنا يوجد محتوى نصي فتجعلها تبدو (أي الأحرف) وكأنها نص مقروء. العديد من برامح النشر المكتبي وبرامح تحرير صفحات الويب تستخدم لوريم إيبسوم بشكل إفتراضي كنموذج عن النص، وإذا قمت بإدخال في أي محرك بحث ستظهر العديد من المواقع الحديثة العهد في نتائج البحث. على مدى السنين ظهرت نسخ جديدة ومختلفة من نص لوريم إيبسوم، أحياناً عن طريق الصدفة، وأحياناً عن عمد كإدخال بعض العبارات الفكاهية إليها.".componentsSeparatedByString(" ")
        
        
        let strings = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.".components(separatedBy: " ")
        
        
        
        let upper = 5
        let lower = 1
        for string in strings {
            let random = Int(arc4random_uniform(10)) * (upper - lower) + lower
            let word = CloudWord(word: string, wordCount: random)
            cloudWords.append(word)
        }
        
        
//        let word1 = CloudWord(word: "مازن", wordCount: 100)
//        let word2 = CloudWord(word: "عبدالله", wordCount: 700)
//        let word3 = CloudWord(word: "ض", wordCount: 200)
//        let word4 = CloudWord(word: "صالح", wordCount: 1000)

        let size  = self.view.frame.size
        print(UIFont.fontNames(forFamilyName: "Noto Naskh Arabic"))
        
        
//        var cloudWords2 : [CloudWord] = []
//        cloudWords2 = [word1, word2, word3, word4]
//        cloudWords2 = [word1, word2]
//        cloudWords2 = [word3, word4]
        
        let newCloudLayoutOperation : CloudLayoutOperation = CloudLayoutOperation(cloudWords: cloudWords, title: "Test", fontName: cloudFontName, forContainerSize: size, withScale: UIScreen.main.scale, delegate: self)
        cloudLayoutOperationQueue.addOperation(newCloudLayoutOperation)
        
    }
    
    
    /**
     Remove all words from the cloud view
     */
    func removeCloudWords() {
        
        
        
        // Remove cloud words (UILabels)
        self.view.subviews.forEach { (subview) in
            if subview is UILabel {
                subview.removeFromSuperview()
            }
        }
        
    
        #if DEBUG
        // Remove bounding boxes
        self.view.layer.sublayers?.forEach({ (sublayer) in
            if sublayer.borderWidth > 0 && sublayer.delegate == nil {
                sublayer.removeFromSuperlayer()
            }
        })
            
    #endif
    }

    
}



extension ViewController : CloudLayoutOperationDelegate {
    
    
    func insertTitle(_ cloudTitle: String) {
        print(cloudTitle)
    }
    
    
    func insertWord(_ word: String, pointSize: CGFloat, color: Int, center: CGPoint, vertical: Bool) {
        
        let wordLabel : UILabel = UILabel(frame: CGRect.zero)
        
        wordLabel.text = word
        wordLabel.textAlignment = .center
        //wordLabel.textColor = self.cloudColors[color < self.cloudColors.count ? color : 0];
        wordLabel.textColor = UIColor.black
        wordLabel.font = UIFont(name: self.cloudFontName, size:pointSize)
        
        wordLabel.sizeToFit()
        
        // Round up size to even multiples to "align" frame without ofsetting center
        var wordLabelRect : CGRect = wordLabel.frame
        wordLabelRect.size.width = (((wordLabelRect.width + 3) / 2)) * 2;
        wordLabelRect.size.height = (((wordLabelRect.height + 3) / 2)) * 2;
        wordLabel.frame = wordLabelRect;
        
        wordLabel.center = center;
        
        if (vertical == true) {
            wordLabel.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
        }
        
        #if DEBUG
            wordLabel.layer.borderColor = UIColor.red.cgColor;
//            wordLabel.layer.borderWidth = 1;
        #endif
        print("wordLabelRect : \(wordLabel.frame)")
        self.view.addSubview(wordLabel);
        
    }

    #if DEBUG
    func insertBoundingRect(_ rect: CGRect) {
        let boundingRect : CALayer = CALayer()
        boundingRect.frame = rect
        
        boundingRect.frame.size.width = (((rect.width + 3) / 2)) * 2;
        boundingRect.frame.size.height = (((rect.height + 3) / 2)) * 2;
        
        print("rect : \(boundingRect)")
        boundingRect.borderColor = UIColor(red:0.0, green:0.0, blue:1.0, alpha:0.5).cgColor
        boundingRect.borderWidth = 0.5
        self.view.layer.addSublayer(boundingRect)
        
    }
    #endif

    
    
}



