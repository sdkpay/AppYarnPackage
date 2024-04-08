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
        sizeToFit()
        addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                    action: #selector(tapLabel(gesture:))))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc 
    private func tapLabel(gesture: UITapGestureRecognizer) {
        
        for link in links {
            
            guard let linkRange = (text as? NSString)?.range(of: link.key) else { return }
            
            if gesture.didTapAttributedTextInLabel(label: self, inRange: linkRange) {
                linkTapped?((link.value, link.key))
                return
            }
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
}

extension UITapGestureRecognizer {

    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        guard let attributedText = label.attributedText else { return false }

        let mutableStr = NSMutableAttributedString(attributedString: attributedText)
        mutableStr.addAttributes([
            NSAttributedString.Key.font: label.font!
        ],
                                 range: NSRange(location: 0, length: attributedText.length))
        
        // If the label have text alignment. Delete this code if label have a default (left) aligment. Possible to add the attribute in previous adding.
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        mutableStr.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], 
                                 range: NSRange(location: 0, length: attributedText.length))

        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: mutableStr)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, 
                                                            in: textContainer,
                                                            fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}
