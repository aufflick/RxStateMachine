//
//  RxStateMachineTests.swift
//  RxStateMachineTests
//
//  Created by Mark Aufflick on 10/5/17.
//  Copyright © 2017 The High Technology Bureau. All rights reserved.
//

import XCTest
import RxStateMachine
import RxSwift
import SwiftyStateMachine

struct NumberKeeper {
    var n: Int
}


enum Number {
    case one, two, three
}

enum Operation {
    case increment, decrement
}


class StateMachineTests: XCTestCase {
    
    var keeperMachine: StateMachine<StateMachineSchema<Number, Operation, NumberKeeper>>!
    var keeper = NumberKeeper(n: 1)

    override func setUp() {
        super.setUp()
        
        let schema = StateMachineSchema<Number, Operation, NumberKeeper>(initialState: .one) { (state, event) in
            let decrement: (NumberKeeper) -> () = { _ in self.keeper.n -= 1 }
            let increment: (NumberKeeper) -> () = { _ in self.keeper.n += 1 }
            
            switch state {
            case .one: switch event {
                case .decrement: return nil
                case .increment: return (.two, increment)
                }
                
                case .two: switch event {
                case .decrement: return (.one, decrement)
                case .increment: return (.three, increment)
                }
                
                case .three: switch event {
                case .decrement: return (.two, decrement)
                case .increment: return nil
                }
            }
        }
        
        keeperMachine = StateMachine(schema: schema, subject: keeper)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSimpleEvent() {
        XCTAssertEqual(keeper.n, 1)
        keeperMachine.handleEvent(.increment)
        XCTAssertEqual(keeper.n, 2)
    }
    
    func testSimpleStateChange() {
        XCTAssertEqual(keeperMachine.state, Number.one)
        keeperMachine.handleEvent(.increment)
        XCTAssertEqual(keeperMachine.state, Number.two)
    }
    
}

class RxStateMachineTests: XCTestCase {
    
    var keeper = NumberKeeper(n: 1)
    
    let events = Variable<Operation?>(nil)
    var states: Observable<Number>!
    var disposeBag = DisposeBag()
    var currentState: Number?
    
    override func setUp() {
        super.setUp()
        
        disposeBag = DisposeBag()
        
        let schema = StateMachineSchema<Number, Operation, NumberKeeper>(initialState: .one) { (state, event) in
            let decrement: (NumberKeeper) -> () = { _ in self.keeper.n -= 1 }
            let increment: (NumberKeeper) -> () = { _ in self.keeper.n += 1 }
            
            switch state {
            case .one: switch event {
            case .decrement: return nil
            case .increment: return (.two, increment)
                }
                
            case .two: switch event {
            case .decrement: return (.one, decrement)
            case .increment: return (.three, increment)
                }
                
            case .three: switch event {
            case .decrement: return (.two, decrement)
            case .increment: return nil
                }
            }
        }
        
        states = StateMachine.rx(schema: schema, subject: keeper, events: events.asObservable().filter { $0 != nil }.map { $0! })
        
        states.subscribe(onNext: { newState in
            self.currentState = newState
        }).addDisposableTo(disposeBag)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSimpleRxEvent() {
        XCTAssertEqual(keeper.n, 1)
        events.value = .increment
        XCTAssertEqual(keeper.n, 2)
    }
    
    func testSimpleRxStateChange() {
        events.value = .increment
        XCTAssertEqual(currentState!, Number.two)
        events.value = .increment
        XCTAssertEqual(currentState!, Number.three)
        events.value = .decrement
        XCTAssertEqual(currentState!, Number.two)
    }
}

class TerminatingRxStateMachineTests: XCTestCase {
    
    var keeper = NumberKeeper(n: 1)
    
    let events = Variable<Operation?>(nil)
    var states: Observable<Number>!
    var disposeBag = DisposeBag()
    var currentState: Number?
    var hasTerminated = false
    
    override func setUp() {
        super.setUp()
        
        disposeBag = DisposeBag()
        
        let schema = StateMachineSchema<Number, Operation, NumberKeeper>(initialState: .one) { (state, event) in
            let decrement: (NumberKeeper) -> () = { _ in self.keeper.n -= 1 }
            let increment: (NumberKeeper) -> () = { _ in self.keeper.n += 1 }
            
            switch state {
            case .one: switch event {
            case .decrement: return nil
            case .increment: return (.two, increment)
                }
                
            case .two: switch event {
            case .decrement: return (.one, decrement)
            case .increment: return (.three, increment)
                }
                
            case .three: switch event {
            case .decrement: return (.two, decrement)
            case .increment: return nil
                }
            }
        }
        
        states = StateMachine<StateMachineSchema<Number, Operation, NumberKeeper>>.terminatingRx(schema: schema,
                                            subject: keeper,
                                            terminalStates: [Number.three],
                                            events: events.asObservable().filter { $0 != nil }.map { $0! })
        
        states.subscribe(onNext: { newState in
            self.currentState = newState
        }, onCompleted: {
            self.hasTerminated = true
        }).addDisposableTo(disposeBag)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSimpleRxEvent() {
        XCTAssertEqual(keeper.n, 1)
        events.value = .increment
        XCTAssertEqual(keeper.n, 2)
    }
    
    func testSimpleRxStateChange() {
        events.value = .increment
        XCTAssertEqual(currentState!, Number.two)
        events.value = .increment
        XCTAssertEqual(currentState!, Number.three)
        XCTAssert(hasTerminated)
    }
}

