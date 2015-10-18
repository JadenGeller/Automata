//
//  Building.swift
//  StateMachine
//
//  Created by Jaden Geller on 10/17/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

struct SymbolTransition<State: StateType, Symbol: SymbolType> {
    let condition: Symbol
    let destination: State
}

infix operator ->> { }
func ->><State: StateType, Symbol: SymbolType>(condition: Symbol, destination: State) -> SymbolTransition<State, Symbol> {
    return SymbolTransition(condition: condition, destination: destination)
}

enum TransitionError: ErrorType {
    case UndefinedTransition
}

func fail<State: StateType>() throws -> State {
    throw TransitionError.UndefinedTransition
}

struct StateTransition<State: StateType, Symbol: SymbolType> {
    let origin: State
    let transitions: Sparse<Symbol, State>
}

struct StayIdentifier {}
let stay = StayIdentifier()

extension StateType {
    typealias Me = Self
    
    func transition<Symbol: SymbolType>(always always: Self) -> StateTransition<Self, Symbol> {
        return _transition([], otherwise: always)
    }
    
    func transition<Symbol: SymbolType>(always always: StayIdentifier) -> StateTransition<Self, Symbol> {
        return _transition([], otherwise: always)
    }
    
    func transition<Symbol: SymbolType>(always always: () throws -> Self) -> StateTransition<Self, Symbol> {
        return _transition([], otherwise: always)
    }

    func transition<Symbol: SymbolType>(transitions: SymbolTransition<Self, Symbol>..., otherwise: StayIdentifier) -> StateTransition<Self, Symbol> {
        return _transition(transitions, otherwise: otherwise)
    }

    func transition<Symbol: SymbolType>(transitions: SymbolTransition<Self, Symbol>..., otherwise: Self) -> StateTransition<Self, Symbol> {
        return _transition(transitions, otherwise: otherwise )
    }
    
    func transition<Symbol: SymbolType>(transitions: SymbolTransition<Self, Symbol>..., otherwise: () throws -> Self = fail) -> StateTransition<Self, Symbol> {
        return _transition(transitions, otherwise: otherwise)
    }
    
    func _transition<Symbol: SymbolType>(transitions: [SymbolTransition<Self, Symbol>], otherwise: StayIdentifier) -> StateTransition<Self, Symbol> {
        return _transition(transitions, otherwise: { self })
    }
    
    func _transition<Symbol: SymbolType>(transitions: [SymbolTransition<Self, Symbol>], otherwise: Self) -> StateTransition<Self, Symbol> {
        return _transition(transitions, otherwise: { otherwise })
    }
    
    func _transition<Symbol: SymbolType>(transitions: [SymbolTransition<Self, Symbol>], otherwise: () throws -> Self = fail) -> StateTransition<Self, Symbol> {
        var sparse = Sparse<Symbol, Me>(defaultTransform: { _ in return try otherwise() })
        for transition in transitions {
            sparse.setValue(transition.destination, forKey: transition.condition)
        }
        return StateTransition(origin: self, transitions: sparse)
    }
}

func fail<State: StateType>(state: State) throws -> State {
    throw TransitionError.UndefinedTransition
}

func stay<State: StateType>(state: State) -> State {
    return state
}

struct Transitions<State: StateType, Symbol: SymbolType> {
    let backing: Sparse<State, Sparse<Symbol, State>>
}

func state<State: StateType, Symbol: SymbolType>(transitions: StateTransition<State, Symbol>..., otherwise: State throws -> State = fail) -> Transitions<State, Symbol> {
    return _state(transitions, otherwise: otherwise)
}

func state<State: StateType, Symbol: SymbolType>(transitions: StateTransition<State, Symbol>..., otherwise: State) -> Transitions<State, Symbol> {
    return _state(transitions, otherwise: otherwise)
}

func _state<State: StateType, Symbol: SymbolType>(transitions: [StateTransition<State, Symbol>], otherwise: State) -> Transitions<State, Symbol> {
    return _state(transitions, otherwise: { _ in otherwise })
}

func _state<State: StateType, Symbol: SymbolType>(transitions: [StateTransition<State, Symbol>], otherwise: State throws -> State = fail) -> Transitions<State, Symbol> {
    var sparse = Sparse<State, Sparse<Symbol, State>>(defaultTransform: { state in Sparse(defaultTransform: { _ in try otherwise(state) }) })
    for transition in transitions {
        sparse.setValue(transition.transitions, forKey: transition.origin)
    }
    return Transitions(backing: sparse)
}


