//
//  CombinePlaygroundTests.swift
//  CombinePlaygroundTests
//
//  Created by Patrick Maltagliati on 10/22/20.
//

import XCTest
@testable import CombinePlayground
import Combine

class CombinePlaygroundTests: XCTestCase {
    private var disposeBag = Set<AnyCancellable>()
    
    func testSwitchToLatest() throws {
        let count = Int.random(in: 3...9)
        let internalSubject = PassthroughSubject<Int, Never>()
        let subject = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()
        let expectation = self.expectation(description: "expectation")
        expectation.expectedFulfillmentCount = count
        
        subject
            .switchToLatest()
            .sink { value in
                expectation.fulfill()
            }
            .store(in: &disposeBag)
        
        subject.send(internalSubject)
        (1...count).forEach { _ in internalSubject.send(Int.random(in: 0...9)) }
        
        waitForExpectations(timeout: 1)
    }
    
    func testSwitchToLatest_Multiple() throws {
        let count = Int.random(in: 3...9)
        let internalSubjectA = PassthroughSubject<Int, Never>()
        let internalSubjectB = PassthroughSubject<Int, Never>()
        let subject = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()
        let expectation = self.expectation(description: "expectation")
        expectation.expectedFulfillmentCount = count
        
        subject
            .switchToLatest()
            .sink { value in
                expectation.fulfill()
            }
            .store(in: &disposeBag)
        
        subject.send(internalSubjectA)
        subject.send(internalSubjectB)
        (1...count).forEach { _ in internalSubjectA.send(Int.random(in: 0...9)) }
        (1...count).forEach { _ in internalSubjectB.send(Int.random(in: 0...9)) }
        
        waitForExpectations(timeout: 1)
    }
    
    func testFlatMap() throws {
        let count = Int.random(in: 3...9)
        let internalSubject = PassthroughSubject<Int, Never>()
        let subject = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()
        let expectation = self.expectation(description: "expectation")
        expectation.expectedFulfillmentCount = count
        
        subject
            .flatMap {
                $0
            }
            .sink { value in
                expectation.fulfill()
            }
            .store(in: &disposeBag)
        
        subject.send(internalSubject)
        (1...count).forEach { _ in internalSubject.send(Int.random(in: 0...9)) }
        
        waitForExpectations(timeout: 1)
    }
    
    func testFlatMap_Multiple() throws {
        let count = Int.random(in: 3...9)
        let internalSubjectA = PassthroughSubject<Int, Never>()
        let internalSubjectB = PassthroughSubject<Int, Never>()
        let subject = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()
        let expectation = self.expectation(description: "expectation")
        expectation.expectedFulfillmentCount = 2 * count
        
        subject
            .flatMap {
                $0
            }
            .sink { value in
                expectation.fulfill()
            }
            .store(in: &disposeBag)
        
        subject.send(internalSubjectA)
        subject.send(internalSubjectB)
        (1...count).forEach { _ in internalSubjectA.send(Int.random(in: 0...9)) }
        (1...count).forEach { _ in internalSubjectB.send(Int.random(in: 0...9)) }
        
        waitForExpectations(timeout: 1)
    }
}
