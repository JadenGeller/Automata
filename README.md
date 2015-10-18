Quickly and easily built finite automata in Swift!

First define the states that exist in your automata.
```swift
    let evenZeros = State()
    let oddZeros = State()
```

Then, define the transitions that exist between each state.
```swift
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
```

Note that, an `otherwise` parameter can be included to indicate what should happen on failure to match---either a state to indicate a transition, `stay` to stay, or `fail` to throw an exception. If no otherwise parameter is provided, the default is `fail`. You can also provide an otherwise transition for an unhandled state as well.

Next, we create our `Automata` and run it!
```swift
    var machine = Automata(initialState: evenZeros, transitions: instructions)
    try machine.run([0, 0, 0, 1, 1, 0, 1, 1, 0])
    print(machine.state == evenZeros) // -> false
    print(machine.state == oddZeros)  // -> true
```

Since our input (which can be any `SequenceType`) has an odd number of zeros, we expect to end in the odd state---and we do!

Here's another example: This finite automata parses the string "hey" or the string "hello" with an arbitrary number of l's. Note that we had to specify the type of the instructions since Swift infers things like `"h"` to be of type `String` rather than `Character`---not what we want.

```swift
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
    try machine.run("helllllllo".characters)
    print(machine.state == success) // -> true
```
