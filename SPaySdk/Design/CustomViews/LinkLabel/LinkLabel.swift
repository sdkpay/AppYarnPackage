//
//  LinkLabel.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 14.06.2023.
//

import UIKit

typealias StringAction = ((String) -> Void)

typealias LinkAction = (((link: String, text: String)) -> Void)

final class LinkLabel: UILabel {
    var linkTapped: LinkAction?
    private let linkTag = "url"
    private let closeTagSymbol = ">"
    private let pointerSymbol = "="
    private var links: [String: String] = [:]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let url = url(at: touches) {
            linkTapped?(url)
        } else {
            super.touchesEnded(touches, with: event)
        }
    }
    
    func setLinkText(string: String, with attributes: [NSAttributedString.Key: Any]) {
        let openTag = "<\(linkTag)"
        let closeTag = "</\(linkTag)>"
        
        links = getLinkDictionary(from: string.slices(from: openTag, to: closeTag))
        
        let urls = Array(links.values) as [String]
        
        var garbage: [String] = urls
        garbage.append(openTag)
        garbage.append(closeTag)
        garbage.append(closeTagSymbol)
        garbage.append(pointerSymbol)

        var clearText = string
        for value in garbage {
            clearText = clearText.replacingOccurrences(of: value, with: "")
        }

        attributedText = NSAttributedString(text: clearText,
                                            dedicatedParts: Array(links.keys),
                                            attrebutes: attributes)
    }
    
    private func getLinkDictionary(from strings: [String]) -> [String: String] {
        var linkTextDictionary: [String: String] = [:]
        
        strings.forEach { string in
            let components = string.components(separatedBy: closeTagSymbol)
            if let name = components.last, let link = components.first {
                linkTextDictionary[name] = link.replacingOccurrences(of: pointerSymbol, with: "")
            }
        }
        return linkTextDictionary
    }
    
    private func url(at touches: Set<UITouch>) -> (link: String, text: String)? {
        guard let attributedText = attributedText, attributedText.length > 0 else { return nil }
        guard let touchLocation = touches.max(by: { $0.timestamp < $1.timestamp })?.location(in: self) else { return nil }
        guard let textStorage = preparedTextStorage() else { return nil }
        let layoutManager = textStorage.layoutManagers[0]
        let textContainer = layoutManager.textContainers[0]
        
        let characterIndex = layoutManager.characterIndex(for: touchLocation, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        guard characterIndex >= 0, characterIndex != NSNotFound else { return nil }

        let glyphRange = layoutManager.glyphRange(forCharacterRange: NSRange(location: characterIndex, length: 1), actualCharacterRange: nil)
        let characterRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        guard characterRect.contains(touchLocation) else { return nil }
        return findLink(at: characterIndex)
    }
    
    private func findLink(at index: Int) -> (link: String, text: String)? {
        guard let text = attributedText?.string else { return nil }
        for link in links {
            if let keyRange = text.range(of: link.key),
               keyRange.contains(String.Index(utf16Offset: index, in: text)) {
                return (link.key, link.value)
            }
        }
        return nil
    }
    
    private func preparedTextStorage() -> NSTextStorage? {
        guard let attributedText = attributedText, attributedText.length > 0 else { return nil }

        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0
        let textStorage = NSTextStorage(string: "")
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineBreakMode = lineBreakMode
        textContainer.size = textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines).size
        textStorage.setAttributedString(attributedText)
        
        return textStorage
    }
}
