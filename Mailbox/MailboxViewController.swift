//
//  MailboxViewController.swift
//  Mailbox
//
//  Created by Mudit Mittal on 2/20/16.
//  Copyright © 2016 Mudit Mittal. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.stringByTrimmingCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet)
        var int = UInt32()
        NSScanner(string: hex).scanHexInt(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

class MailboxViewController: UIViewController {
    var iconOffset = 24
    var iconMoveOffset = 60
    var iconChangeOffset = 260
    var screenWidth = 320

    var singleMessageOriginalCenter: CGPoint!
    var singleMessageOffset: CGPoint!
    
    @IBOutlet weak var laterIconView: UIImageView!
    @IBOutlet weak var listIconView: UIImageView!
    @IBOutlet weak var archiveIconView: UIImageView!
    @IBOutlet weak var deleteIconView: UIImageView!

    @IBOutlet weak var leftIconView: UIView!
    @IBOutlet weak var rightIconView: UIView!
    @IBOutlet weak var feedView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var messageParentView: UIView!
    @IBOutlet weak var singleMessageView: UIImageView!
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var rescheduleImageView: UIImageView!
    @IBOutlet weak var listImageView: UIImageView!
    
    var edgeHandle: UIImageView!
    @IBOutlet weak var inboxView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize = CGSize(width: 320, height: 1366)
        messageParentView.backgroundColor = UIColor.init(hexString: "#FFFFFF")
        hideIcons()
        let edgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: "onEdgePan:")
        edgeGesture.edges = UIRectEdge.Left
        inboxView.addGestureRecognizer(edgeGesture)
    }

    func hideIcons() {
        laterIconView.alpha = 0
        listIconView.alpha = 0
        archiveIconView.alpha = 0
        deleteIconView.alpha = 0
        rescheduleImageView.alpha = 0
        listImageView.alpha = 0
    }

    @IBAction func didPanMessage(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(view)
        
        if sender.state == UIGestureRecognizerState.Began {
            singleMessageOriginalCenter = singleMessageView.center
        
        } else if sender.state == UIGestureRecognizerState.Changed {
            singleMessageView.center = CGPoint(x: singleMessageOriginalCenter.x + translation.x, y: singleMessageOriginalCenter.y)
            
            // MESSAGE PANNING TO RIGHT
            if translation.x > 0 && translation.x < CGFloat(iconMoveOffset) {
                messageParentView.backgroundColor = UIColor.init(hexString: "#E3E3E3")
                deleteIconView.alpha = 0
                archiveIconView.alpha = convertValue((translation.x)/100, r1Min: 0, r1Max: 50, r2Min: 0, r2Max: 100)

            } else if translation.x > CGFloat(iconMoveOffset) && translation.x < CGFloat(iconChangeOffset) {
                messageParentView.backgroundColor = UIColor.init(hexString: "#6CDA5B")
                archiveIconView.alpha = 1
                deleteIconView.alpha = 0
                leftIconView.center.x = CGFloat(iconOffset) + convertValue(translation.x, r1Min: CGFloat(iconMoveOffset), r1Max: CGFloat(screenWidth), r2Min: 0, r2Max: CGFloat(iconChangeOffset))
            
            } else if translation.x > CGFloat(iconChangeOffset) {
                messageParentView.backgroundColor = UIColor.init(hexString: "#ED5329")
                archiveIconView.alpha = 0
                deleteIconView.alpha = 1
                leftIconView.center.x = CGFloat(iconOffset) + convertValue(translation.x, r1Min: CGFloat(iconMoveOffset), r1Max: CGFloat(screenWidth), r2Min: 0, r2Max: CGFloat(iconChangeOffset))
            
            }
            
            // MESSAGE PANNING TO LEFT
            if translation.x < 0 && abs(translation.x) < CGFloat(iconMoveOffset) {
                // BG is Grey and ICON fades in
                messageParentView.backgroundColor = UIColor.init(hexString: "#E3E3E3")
                listIconView.alpha = 0
                laterIconView.alpha = convertValue(abs(translation.x)/100, r1Min: 0, r1Max: 50, r2Min: 0, r2Max: 100)
                
            } else if translation.x < 0 && abs(translation.x) > CGFloat(iconMoveOffset) && abs(translation.x) < CGFloat(iconChangeOffset) {
                // BG changes to Green and ICON starts moving
                messageParentView.backgroundColor = UIColor.init(hexString: "#FBD30A")
                laterIconView.alpha = 1
                listIconView.alpha = 0
                rightIconView.center.x = CGFloat(screenWidth) + CGFloat(iconOffset) + CGFloat(iconMoveOffset) + convertValue(translation.x, r1Min: CGFloat(iconMoveOffset), r1Max: CGFloat(screenWidth), r2Min: 0, r2Max: CGFloat(iconChangeOffset))
                
            } else if translation.x < 0 && abs(translation.x) > CGFloat(iconChangeOffset) {
                // BG changes to Red and ICON changes and keeps moving
                messageParentView.backgroundColor = UIColor.init(hexString: "#D9A771")
                laterIconView.alpha = 0
                listIconView.alpha = 1
                rightIconView.center.x = CGFloat(screenWidth) + CGFloat(iconOffset) + CGFloat(iconMoveOffset) + convertValue(translation.x, r1Min: CGFloat(iconMoveOffset), r1Max: CGFloat(screenWidth), r2Min: 0, r2Max: CGFloat(iconChangeOffset))

            }
            
        } else if sender.state == UIGestureRecognizerState.Ended {

            // PANNING TO RIGHT ENDED
            if translation.x > 0 && translation.x < CGFloat(iconMoveOffset) {
                // SNAP message back to left end
                UIView.animateWithDuration(0.2, animations: {
                    self.singleMessageView.center = self.singleMessageOriginalCenter
                    }, completion: { (Bool) -> Void in
                })
                archiveIconView.alpha = 0
                
            } else if translation.x > CGFloat(iconMoveOffset) && translation.x < CGFloat(iconChangeOffset) {
                // SWIPE message and icon to right end, and animate hiding
                UIView.animateWithDuration(0.2, animations: {
                    self.singleMessageView.center = CGPoint(x: self.singleMessageView.center.x + CGFloat(self.screenWidth), y: self.singleMessageView.center.y)
                    self.leftIconView.center = CGPoint(x: self.leftIconView.center.x + CGFloat(self.screenWidth), y: self.leftIconView.center.y)
                    }, completion: { (Bool) -> Void in
                        UIView.animateWithDuration(0.2, animations: {
                            self.messageParentView.bounds.size.height = 0
                            self.leftIconView.alpha = 0
                            }, completion: { (Bool) -> Void in
                                UIView.animateWithDuration(0.2, animations: {
                                    self.feedView.center.y -= 86
                                    }, completion: { (Bool) -> Void in
                                        self.leftIconView.alpha = 1
                                })
                        })
                })
                displayMessage()
                
            } else if translation.x > CGFloat(iconChangeOffset) {
                UIView.animateWithDuration(0.2, animations: {
                    // SWIPE message and icon to right end, and animate hiding
                    self.singleMessageView.center = CGPoint(x: self.singleMessageView.center.x + CGFloat(self.screenWidth), y: self.singleMessageView.center.y)
                    }, completion: { (Bool) -> Void in
                        UIView.animateWithDuration(0.2, animations: {
                            self.messageParentView.bounds.size.height = 0
                            self.deleteIconView.alpha = 0
                            self.leftIconView.alpha = 0
                            }, completion: { (Bool) -> Void in
                                UIView.animateWithDuration(0.2, animations: {
                                    self.feedView.center.y -= 86
                                    }, completion: { (Bool) -> Void in
                                        self.leftIconView.alpha = 1
                                })

                        })
                })
                displayMessage()
                
            }
            
            // PANNING TO LEFT ENDED
            if translation.x < 0 && abs(translation.x) < CGFloat(iconMoveOffset) {
                // SNAP message back to right end
                UIView.animateWithDuration(0.2, animations: {
                    self.singleMessageView.center = self.singleMessageOriginalCenter
                    }, completion: { (Bool) -> Void in
                })
                
            } else if translation.x < 0 && abs(translation.x) > CGFloat(iconMoveOffset) && abs(translation.x) < CGFloat(iconChangeOffset) {
                // SWIPE message and icon to left end, and animate hiding
                rescheduleImageView.alpha = 1
                
            } else if translation.x < 0 && abs(translation.x) > CGFloat(iconChangeOffset) {
                // SWIPE message and icon to left end, and animate hiding, and show menu
                listImageView.alpha = 1
                
            }

        }

    }
    
    func displayMessage() {
        UIView.animateWithDuration(0.1, delay: 2, options: [], animations: {
            self.feedView.center.y += 86
            }, completion: { (Bool) -> Void in
                self.messageParentView.bounds.size.height = 86
                self.singleMessageView.center = CGPoint(x: self.singleMessageOriginalCenter.x, y: self.singleMessageOriginalCenter.y)
                
        })
        
    }
    
    @IBAction func onRescheduleMenuTap(sender: UITapGestureRecognizer) {
        rescheduleImageView.alpha = 0
        listImageView.alpha = 0
        UIView.animateWithDuration(0.2, animations: {
            self.singleMessageView.center = CGPoint(x: self.singleMessageView.center.x - CGFloat(self.screenWidth), y: self.singleMessageView.center.y)
            self.rightIconView.center = CGPoint(x: self.rightIconView.center.x - CGFloat(self.screenWidth), y: self.rightIconView.center.y)
            }, completion: { (Bool) -> Void in
                UIView.animateWithDuration(0.2, animations: {
                    self.messageParentView.bounds.size.height = 0
                    self.rightIconView.alpha = 0
                    }, completion: { (Bool) -> Void in
                        UIView.animateWithDuration(0.2, animations: {
                            self.feedView.center.y -= 86
                            }, completion: { (Bool) -> Void in
                                self.rightIconView.alpha = 1
                        })
                })
        })
        
        // Display Message Again
        displayMessage()

    }

    @IBAction func onMenuPan(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(view)
        let initialCenter = inboxView.center.x
        
        if sender.state == UIGestureRecognizerState.Began {
            menuImageView.alpha = 1
            
        } else if sender.state == UIGestureRecognizerState.Changed {
            inboxView.center.x = initialCenter + translation.x

        } else if sender.state == UIGestureRecognizerState.Ended {
            UIView.animateWithDuration(0.2, animations: {
                self.inboxView.frame.origin.x = 280
            })
        }
        
    }

    @IBAction func onMenuTapGesture(sender: UITapGestureRecognizer) {
        UIView.animateWithDuration(0.2, animations: {
            self.inboxView.frame.origin.x = 0
            self.menuImageView.alpha = 0
        })

    }
    
    func onEdgePan(sender: UIScreenEdgePanGestureRecognizer) {
        let translation = sender.translationInView(view)
        let initialCenter = inboxView.center.x
        
        if sender.state == UIGestureRecognizerState.Began {
            menuImageView.alpha = 1
            
        } else if sender.state == UIGestureRecognizerState.Changed {
            inboxView.center.x = initialCenter + translation.x
            
        } else if sender.state == UIGestureRecognizerState.Ended {
            UIView.animateWithDuration(0.2, animations: {
                self.inboxView.frame.origin.x = 280
            })
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func onMenu(sender: AnyObject) {

    }

    @IBAction func onCompose(sender: AnyObject) {

    }

}
