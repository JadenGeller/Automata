//
//  AutomataTests.swift
//  AutomataTests
//
//  Created by Jaden Geller on 10/18/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

import XCTest
@testable import Automata

class AutomataTests: XCTestCase {
    
    func testParityFA() {
        let evenZeros = State()
        let oddZeros = State()
        
        let instructions = state(
            evenZeros.transition(
                0 ->> oddZeros,
                otherwise: stay
            ),
            oddZeros.transition(
                0 ->> evenZeros,
                otherwise: stay
            )
        )
        
        var machine = Automata(initialState: evenZeros, transitions: instructions)
        
        XCTAssertNotNil(try? machine.run([0, 0, 0, 1, 1, 0, 1, 1, 0]))
        
        XCTAssertNotEqual(evenZeros, machine.state)
    }
    
    func testStringParsingFA() {
        let empty = State()
        let h = State()
        let he = State()
        let hel1 = State() // l can be repeated 1 or more times
        
        let success = State()
        let failure = State()
        
        let instructions: Transitions<State, Character> = state(
            empty.transition(
                "h" ->> h,
                otherwise: failure
            ),
            h.transition(
                "e" ->> he,
                otherwise: failure
            ),
            he.transition(
                "l" ->> hel1,
                "y" ->> success,
                otherwise: failure
            ),
            hel1.transition(
                "l" ->> hel1,
                "o" ->> success,
                otherwise: failure
            ),
            success.transition(
                always: failure
            ),
            failure.transition(
                always: stay
            )
        )
        
        var machine = Automata(initialState: empty, transitions: instructions)
        
        XCTAssertNotNil(try? machine.run("helllllllo".characters))
        
        XCTAssertEqual(success, machine.state)
    }
}
