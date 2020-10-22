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
    private var disposeBag: Set<AnyCancellable>!
    private var count: Int!
    private var internalSubjectA: PassthroughSubject<Int, Never>!
    private var internalSubjectB: PassthroughSubject<Int, Never>!
    private var subject: PassthroughSubject<PassthroughSubject<Int, Never>, Never>!
    private var expectation: XCTestExpectation!
    
    override func setUpWithError() throws {
        count = Int.random(in: 3...9)
        subject = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()
        internalSubjectA = PassthroughSubject<Int, Never>()
        internalSubjectB = PassthroughSubject<Int, Never>()
        expectation = self.expectation(description: "expectation")
        disposeBag = Set()
    }
    
    func testSwitchToLatest() throws {
        expectation.expectedFulfillmentCount = count
        
        subject
            .switchToLatest()
            .sink { [weak self] value in
                self?.expectation.fulfill()
            }
            .store(in: &disposeBag)
        
        subject.send(internalSubjectA)
        (1...count).forEach { _ in internalSubjectA.send(Int.random(in: 0...9)) }
        
        waitForExpectations(timeout: 1)
    }
    
    func testSwitchToLatest_Multiple() throws {
        expectation.expectedFulfillmentCount = count
        
        subject
            .switchToLatest()
            .sink { [weak self] value in
                self?.expectation.fulfill()
            }
            .store(in: &disposeBag)
        
        subject.send(internalSubjectA)
        subject.send(internalSubjectB)
        (1...count).forEach { _ in internalSubjectA.send(Int.random(in: 0...9)) }
        (1...count).forEach { _ in internalSubjectB.send(Int.random(in: 0...9)) }
        
        waitForExpectations(timeout: 1)
    }
    
    func testFlatMap() throws {
        expectation.expectedFulfillmentCount = count
        
        subject
            .flatMap {
                $0
            }
            .sink { [weak self] value in
                self?.expectation.fulfill()
            }
            .store(in: &disposeBag)
        
        subject.send(internalSubjectA)
        (1...count).forEach { _ in internalSubjectA.send(Int.random(in: 0...9)) }
        
        waitForExpectations(timeout: 1)
    }
    
    func testFlatMap_Multiple() throws {
        expectation.expectedFulfillmentCount = 2 * count
        
        subject
            .flatMap {
                $0
            }
            .sink { [weak self] value in
                self?.expectation.fulfill()
            }
            .store(in: &disposeBag)
        
        subject.send(internalSubjectA)
        subject.send(internalSubjectB)
        (1...count).forEach { _ in internalSubjectA.send(Int.random(in: 0...9)) }
        (1...count).forEach { _ in internalSubjectB.send(Int.random(in: 0...9)) }
        
        waitForExpectations(timeout: 1)
    }
}
