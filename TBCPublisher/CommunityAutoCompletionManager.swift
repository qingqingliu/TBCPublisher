//
//  CommunityAutoCompletionManager.swift
//  Example
//
//  Created by Qingqing Liu on 4/24/20.
//  Copyright © 2020 Nathan Tannar. All rights reserved.
//

import Foundation
import InputBarAccessoryView
import UIKit

class CommunityAutoCompletionManager: AutocompleteManager {
    override open func attributedText(matching session: AutocompleteSession, fontSize: CGFloat = 15, keepPrefix: Bool = true) -> NSMutableAttributedString {
        guard let completion = session.completion else {
            return NSMutableAttributedString()
        }
        
        // Bolds the text that currently matches the filter
        let matchingRange = (completion.text as NSString).range(of: session.filter, options: .caseInsensitive)
        
        let attrs:[NSAttributedString.Key:AnyObject] = [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: fontSize),
            NSAttributedString.Key.foregroundColor : UIColor.darkText
        ]
        
        let attributedString = NSMutableAttributedString(string: completion.text, attributes: attrs)
        attributedString.addAttributes([.font: UIFont.boldSystemFont(ofSize: fontSize)], range: matchingRange)
        
        guard keepPrefix else { return attributedString }
        let stringWithPrefix = NSMutableAttributedString(string: String(session.prefix), attributes: attrs)
        stringWithPrefix.append(attributedString)
        return stringWithPrefix
    }
}
