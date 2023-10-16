//
//  String+Extensions.swift.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 25.01.2023.
//

import Foundation

extension String {
    
    var card: String {
        "•• \(self)"
    }
}

extension String {
    
    func addEnding(ends: [String: String]) -> String {
        
        var ending: String = ""
        
        if validateForEnding() {
            
            return ending
        }
        
        guard let lastSymbol = last else { return "" }
        
        for end in ends where end.key.contains(lastSymbol) {
            ending = end.value
        }
        
        return "\(self) \(ending)"
    }
    
    private func validateForEnding() -> Bool {
        checkForMatches(with: ".*1.$") || checkForMatches(with: "\\.0*[1-9]")
    }
    
    private func checkForMatches(with pattern: String) -> Bool {
        let regex = try? NSRegularExpression(pattern: pattern)
        return ((regex?.firstMatch(in: self, range: NSRange(location: 0, length: utf16.count))) != nil)
    }
}
