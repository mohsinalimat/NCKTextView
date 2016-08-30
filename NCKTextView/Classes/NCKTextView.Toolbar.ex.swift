//
//  NCKTextView.Toolbar.ex.swift
//  Pods
//
//  Created by Chanricle King on 30/08/2016.
//
//

import Foundation

public var toolbar: UIToolbar?
public var toolbarHeight: CGFloat = 40
public var currentFrame: CGRect = CGRectZero

public var toolbarButtonTintColor: UIColor = UIColor.blackColor()
public var toolbarButtonHighlightColor: UIColor = UIColor.orangeColor()

var formatButton: UIBarButtonItem?

var nck_formatTableViewController: NCKFormatTableViewController?
var formatMenuView: UIView?

extension NCKTextView {
    /**
     Enable the toolbar, binding the show and hide events.
     
     */
    public func enableToolbar() -> UIToolbar {
        toolbar = UIToolbar(frame: CGRect(origin: CGPoint(x: 0, y: CGRectGetHeight(UIScreen.mainScreen().bounds)), size: CGSize(width: CGRectGetWidth(UIScreen.mainScreen().bounds), height: toolbarHeight)))
        toolbar?.autoresizingMask = .FlexibleWidth
        toolbar?.backgroundColor = UIColor.clearColor()
        
        toolbar?.items = enableBarButtonItems()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShowOrHide(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShowOrHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        return toolbar!
    }
    
    // MARK: - Toolbar buttons
    
    func enableBarButtonItems() -> [UIBarButtonItem] {
        let bundle = NSBundle(path: NSBundle(forClass: NCKTextView.self).pathForResource("NCKTextView", ofType: "bundle")!)
        
        let flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        let hideKeyboardButton = UIBarButtonItem(image: UIImage(named: "icon-keyboard", inBundle: bundle, compatibleWithTraitCollection: nil), style: .Plain, target: self, action: #selector(self.hideKeyboardButtonAction))
        
        formatButton = UIBarButtonItem(image: UIImage(named: "icon-format", inBundle: bundle, compatibleWithTraitCollection: nil), style: .Plain, target: self, action: #selector(self.formatButtonAction))
        
        let buttonItems = [formatButton!, flexibleSpaceButton, hideKeyboardButton]
        
        // Button styles
        for buttonItem in buttonItems {
            buttonItem.tintColor = toolbarButtonTintColor
        }
        
        return buttonItems
    }
    
    func formatButtonAction() {
        if formatMenuView == nil {
            let bundle = NSBundle(path: NSBundle(forClass: NCKTextView.self).pathForResource("NCKTextView", ofType: "bundle")!)
            let nck_formatNavigationController = UIStoryboard(name: "NCKTextView", bundle: bundle).instantiateViewControllerWithIdentifier("NCKFormatNavigationController") as! UINavigationController
            
            nck_formatTableViewController = nck_formatNavigationController.viewControllers[0] as! NCKFormatTableViewController
            nck_formatTableViewController?.selectedCompletion = { [unowned self] (type) in
                let currentParagraphType = self.currentParagraphType()
                
                switch type {
                case .Title:
                    self.inputFontMode = .Title
                    self.changeCurrentParagraphTextWithInputFontMode(.Title)
                    
                    break
                case .Body:
                    self.inputFontMode = .Normal
                    if currentParagraphType == .Title {
                        self.changeCurrentParagraphTextWithInputFontMode(.Normal)
                    }
                    
                    break
                case .BulletedList:
                    self.buttonActionWithOrderedOrUnordered(orderedList: false, listPrefix: "• ")
                    break
                case .DashedList:
                    self.buttonActionWithOrderedOrUnordered(orderedList: false, listPrefix: "- ")
                    break
                case .NumberedList:
                    self.buttonActionWithOrderedOrUnordered(orderedList: true, listPrefix: "1. ")
                    break
                }
            }
            
            let superViewSize = self.superview!.bounds.size
            let toolbarOriginY = toolbar!.frame.origin.y
            let menuViewHeight: CGFloat = toolbarOriginY - 200 >= 44 ? 180 : 120
            
            nck_formatNavigationController.view.frame = CGRect(origin: CGPointZero, size: CGSize(width: superViewSize.width, height: menuViewHeight))
            
            formatMenuView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: toolbarOriginY + 44 - menuViewHeight), size: CGSize(width: superViewSize.width, height: menuViewHeight)))
            formatMenuView?.addSubview(nck_formatNavigationController.view)
            
            nck_formatTableViewController?.navigationItem.title = NSLocalizedString("Formatting", comment: "")
            nck_formatTableViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(self.formatMenuViewDoneButtonAction))
        }
        
        self.superview?.addSubview(formatMenuView!)
    }
    
    func formatMenuViewDoneButtonAction() {
        formatMenuView?.removeFromSuperview()
    }
    
    func hideKeyboardButtonAction() {
        self.resignFirstResponder()
    }
    
    func keyboardWillShowOrHide(notification: NSNotification) {
        guard let info = notification.userInfo else {
            return
        }
        
        let duration = info[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let keyboardEnd = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        let toolbarHeight = toolbar!.frame.size.height
        
        if notification.name == UIKeyboardWillShowNotification {
            formatMenuView?.removeFromSuperview()
            
            self.superview?.addSubview(toolbar!)
            
            var textViewFrame = self.frame
            textViewFrame.size.height = self.superview!.frame.height - keyboardEnd.height - toolbarHeight
            self.frame = textViewFrame
            
            UIView.animateWithDuration(duration, animations: {
                var frame = toolbar!.frame
                frame.origin.y = self.superview!.frame.height - (keyboardEnd.height + toolbarHeight)
                toolbar!.frame = frame
                }, completion: nil)
        } else {
            self.frame = currentFrame
            
            UIView.animateWithDuration(duration, animations: {
                var frame = toolbar!.frame
                frame.origin.y = self.superview!.frame.size.height
                toolbar!.frame = frame
                
                }, completion: { (success) in
                    toolbar!.removeFromSuperview()
            })
        }
    }
}
