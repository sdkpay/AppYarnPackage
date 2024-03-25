//
//  MetricsBuilder.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 18.03.2024.
//

import Foundation

enum MetricsBaseKey: String {
    
    case Touch
    
    case RQ
    case RS
    
    case ST
    
    case LC
    
    case MA
    case MAC
    
    case SC
}

enum MetricsActionKey: String {
    
    case Touch
    
    case Get
    case Save
    case Remove
    
    case Start
    case End
    
    case Appeared
    case Disappeared
    case Open
    
    case Init
}

enum MetricsStateKey: String {
    
    case Good
    case Fail
}

struct MetricsValue: RawRepresentable {
    
    var rawValue: String
    
    init(rawValue: String) {
        self.rawValue = rawValue
    }
}

final class EventBuilder {
    
    private var base = ""
    private var action = ""
    private var state = ""
    
    private var value = ""
    
    private var postAction = ""
    private var postState = ""
    
    @discardableResult
    func with(base: MetricsBaseKey) -> Self {
        
        self.base = base.rawValue
        return self
    }
    
    @discardableResult
    func with(action: MetricsActionKey) -> Self {
        
        self.action = action.rawValue
        return self
    }
    
    @discardableResult
    func with(state: MetricsStateKey) -> Self {
        
        self.state = state.rawValue
        return self
    }
    
    @discardableResult
    func with(value: MetricsValue) -> Self {
        
        self.value = value.rawValue
        return self
    }
    
    @discardableResult
    func with(postAction: MetricsActionKey) -> Self {
        
        self.postAction = postAction.rawValue
        return self
    }
    
    @discardableResult
    func with(postState: MetricsStateKey) -> Self {
        
        self.postState = postState.rawValue
        return self
    }
    
    func build() -> String {
        base.capFirst
        + action.capFirst
        + state.capFirst
        + value.capFirst
        + postAction.capFirst
        + postState.capFirst
    }
}

extension String {
    
    var capFirst: String {
           return prefix(1).capitalized + dropFirst()
      }
}
