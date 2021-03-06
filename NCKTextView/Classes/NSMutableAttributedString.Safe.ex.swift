//
//  NSMutableAttributedString.Safe.ex.swift
//  Pods
//
//  Created by Chanricle King on 08/09/2016.
//
//

import Foundation

extension NSMutableAttributedString {
    // MARK: - Safe methods
    
    func safeReplaceCharactersInRange(_ range: NSRange, withString str: String) {
        if isSafeRange(range) {
            replaceCharacters(in: range, with: str)
        }
    }
    
    func safeReplaceCharactersInRange(_ range: NSRange, withAttributedString attrStr: NSAttributedString) {
        if isSafeRange(range) {
            replaceCharacters(in: range, with: attrStr)
        }
    }
    
    func safeAddAttributes(_ attrs: [String : AnyObject], range: NSRange) {
        if isSafeRange(range) {
            addAttributes(attrs, range: range)
        }
    }
}

extension NSAttributedString {
    func safeAttribute(_ attrName: String, atIndex location: Int, effectiveRange range: NSRangePointer?, defaultValue: AnyObject?) -> AnyObject? {
        var attributeValue: AnyObject? = nil

        if location >= 0 && location < string.length() {
            attributeValue = attribute(attrName, at: location, effectiveRange: range) as AnyObject?
        }
        
        return attributeValue == nil ? defaultValue : attributeValue
    }
    
    func isSafeRange(_ range: NSRange) -> Bool {
        if range.location < 0 {
            return false
        }
        
        let maxLength = range.location + range.length
        if maxLength <= string.length() {
            return true
        } else {
            return false
        }
    }
}
