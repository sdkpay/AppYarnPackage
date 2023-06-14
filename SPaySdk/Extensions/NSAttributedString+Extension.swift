//
//  NSAttributedString+Extension.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 14.04.2023.
//

import Foundation

extension NSAttributedString {
    convenience init(markedText: String,
                     openSymbol: Character = "<",
                     closeSymbol: Character = ">",
                     attrebutes: [NSAttributedString.Key: Any]) {
        let str = NSMutableAttributedString(string: markedText)
        
        guard let openMarkPosition = markedText.indexInt(of: openSymbol),
              let closeMarkPosition = markedText.indexInt(of: closeSymbol)
        else {
            self.init(attributedString: str)
            return
        }
        let markedRange = NSRange(location: openMarkPosition,
                                  length: closeMarkPosition - openMarkPosition)
        str.addAttributes(attrebutes, range: markedRange)
        str.replaceCharacters(in: NSRange(location: openMarkPosition, length: 1), with: "")
        str.replaceCharacters(in: NSRange(location: closeMarkPosition - 1, length: 1), with: "")
        self.init(attributedString: str)
    }
    
    convenience init(text: String,
                     dedicatedPart: String,
                     attrebutes: [NSAttributedString.Key: Any]) {
        let str = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: dedicatedPart)
        str.addAttributes(attrebutes, range: range)
        self.init(attributedString: str)
    }
    
    convenience init(text: String,
                     dedicatedParts: [String],
                     attrebutes: [NSAttributedString.Key: Any]) {
        let str = NSMutableAttributedString(string: text)
        for part in dedicatedParts {
            let range = (text as NSString).range(of: part)
            str.addAttributes(attrebutes, range: range)
        }
        self.init(attributedString: str)
    }
}

extension String {
    func indexInt(of char: Character) -> Int? {
        return firstIndex(of: char)?.utf16Offset(in: self)
    }
}
