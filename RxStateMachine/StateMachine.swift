//
//  StateMachine.swift
//  RxStateMachine
//
//  Created by Mark Aufflick on 10/5/17.
//  Copyright © 2017 The High Technology Bureau. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyStateMachine_MarkAufflick

extension StateMachine where Schema : StateMachineSchemaType, Schema.Subject : Any, Schema.State : Equatable {
    
    public static func terminatingRx(schema: Schema, subject: Schema.Subject, terminalStates: [Schema.State], events: Observable<Schema.Event>) -> Observable<Schema.State> {
        
        return Observable.create({ observable -> Disposable in
            
            var hasTerminated = false
            
            let sm = StateMachine(schema: schema, subject: subject)
            sm.didTransitionCallback = { (_, _, newState) in
                
                precondition(!hasTerminated, "Event received after termination")

                observable.onNext(newState)
                
                if terminalStates.contains(newState) {
                    observable.onCompleted()
                    hasTerminated = true
                }
            }

            var eventsDisposable: DisposeBag? = DisposeBag()
            
            events.subscribe(onNext: { event in
                sm.handleEvent(event)
            }, onError: { (error) in
                observable.onError(error)
            }).addDisposableTo(eventsDisposable!)
            
            return Disposables.create {
                sm.didTransitionCallback = nil
                eventsDisposable = nil
            }
        })

    }
}

extension StateMachine where Schema : StateMachineSchemaType, Schema.Subject : Any {
    
    public static func rx(schema: Schema, subject: Schema.Subject, events: Observable<Schema.Event>) -> Observable<Schema.State> {
        
        return Observable.create({ observable -> Disposable in
            
            let sm = StateMachine(schema: schema, subject: subject)
            sm.didTransitionCallback = { (_, _, newState) in
                
                observable.onNext(newState)
            }
            
            var eventsDisposable: DisposeBag? = DisposeBag()
            
            events.subscribe(onNext: { event in
                sm.handleEvent(event)
            }, onError: { (error) in
                observable.onError(error)
            }).addDisposableTo(eventsDisposable!)
            
            return Disposables.create {
                sm.didTransitionCallback = nil
                eventsDisposable = nil
            }
        })
        
    }
}

extension StateMachine where Schema : StateMachineSchemaType, Schema.Subject == Void, Schema.State : Equatable {
    
    public static func terminatingRx(schema: Schema, terminalStates: [Schema.State], events: Observable<Schema.Event>) -> Observable<Schema.State> {
        
        return Observable.create({ observable -> Disposable in
            
            var hasTerminated = false
            
            let sm = StateMachine(schema: schema, subject: ())
            sm.didTransitionCallback = { (_, _, newState) in
                
                precondition(!hasTerminated, "Event received after termination")
                
                observable.onNext(newState)
                
                if terminalStates.contains(newState) {
                    observable.onCompleted()
                    hasTerminated = true
                }
            }
            
            var eventsDisposable: DisposeBag? = DisposeBag()
            
            events.subscribe(onNext: { event in
                sm.handleEvent(event)
            }, onError: { (error) in
                observable.onError(error)
            }).addDisposableTo(eventsDisposable!)
            
            return Disposables.create {
                sm.didTransitionCallback = nil
                eventsDisposable = nil
            }
        })
        
    }
}

extension StateMachine where Schema : StateMachineSchemaType, Schema.Subject == Void {
    
    public static func rx(schema: Schema, events: Observable<Schema.Event>) -> Observable<Schema.State> {
        
        return Observable.create({ observable -> Disposable in
            
            let sm = StateMachine(schema: schema, subject: ())
            sm.didTransitionCallback = { (_, _, newState) in
                
                observable.onNext(newState)
            }
            
            var eventsDisposable: DisposeBag? = DisposeBag()
            
            events.subscribe(onNext: { event in
                sm.handleEvent(event)
            }, onError: { (error) in
                observable.onError(error)
            }).addDisposableTo(eventsDisposable!)
            
            return Disposables.create {
                sm.didTransitionCallback = nil
                eventsDisposable = nil
            }
        })
        
    }
}
