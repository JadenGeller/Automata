//
//  Automata.swift
//  StateMachine
//
//  Created by Jaden Geller on 10/17/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

protocol AutomataType {
    typealias Symbol: SymbolType
    typealias State: StateType
    mutating func step(symbol: Symbol) throws
    var state: State { get }
}

extension AutomataType {
    mutating func run<I: SequenceType where I.Generator.Element == Symbol>(input: I) throws {
        for symbol in input {
            try step(symbol)
        }
    }
}

struct Automata<State: StateType, Symbol: SymbolType>: AutomataType {
    let transitions: Sparse<State, Sparse<Symbol, State>>
    var state: State
    
    mutating func step(symbol: Symbol) throws {
        state = try transitions.getValue(forKey: state).getValue(forKey: symbol)
    }
    
    init(initialState: State, transitions: Transitions<State, Symbol>) {
        self.state = initialState
        self.transitions = transitions.backing
    }
}