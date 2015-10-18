//
//  Internals.swift
//  StateMachine
//
//  Created by Jaden Geller on 10/17/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

protocol StateType: class, Hashable { }
extension StateType {
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
}
func ==<S: StateType>(lhs: S, rhs: S) -> Bool {
    return lhs === rhs
}

class State: StateType { }

class NamedState: State {
    let name: String
    
    init(_ name: String) {
        self.name = name
    }
}

typealias SymbolType = Hashable

protocol TransitionFollowthrough {
    typealias State: StateType
    var destination: State { get }
}