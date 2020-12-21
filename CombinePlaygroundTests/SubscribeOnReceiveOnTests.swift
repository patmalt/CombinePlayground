//
//  SubscribeOnReceiveOnTests.swift
//  CombinePlaygroundTests
//
//  Created by Patrick Maltagliati on 12/21/20.
//

import XCTest
@testable import CombinePlayground
import Combine

class SubscribeOnReceiveOnTests: XCTestCase {
    private var disposeBag: Set<AnyCancellable>!
    private var expectation: XCTestExpectation!

    override func setUpWithError() throws {
        disposeBag = Set()
        expectation = self.expectation(description: "expectation")
    }

    func testCurrentThreadIsTheThreadTheSubscriptionStartsOn_Background() throws {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            Just(3)
                .handleEvents(receiveOutput: { _ in XCTAssertFalse(Thread.isMainThread) })
                .receive(on: DispatchQueue.main)
                .handleEvents(receiveOutput: { _ in XCTAssertTrue(Thread.isMainThread) })
                .receive(on: DispatchQueue.global(qos: .userInteractive))
                .handleEvents(receiveOutput: { _ in XCTAssertFalse(Thread.isMainThread) })
                .sink(receiveValue: { [weak self] _ in
                    self?.expectation.fulfill()
                })
                .store(in: &self.disposeBag)
        }
        waitForExpectations(timeout: 1)
    }

    func testCurrentThreadIsTheThreadTheSubscriptionStartsOn_Main() throws {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            Just(3)
                .handleEvents(receiveOutput: { _ in XCTAssertTrue(Thread.isMainThread) })
                .receive(on: DispatchQueue.main)
                .handleEvents(receiveOutput: { _ in XCTAssertTrue(Thread.isMainThread) })
                .receive(on: DispatchQueue.global(qos: .userInteractive))
                .handleEvents(receiveOutput: { _ in XCTAssertFalse(Thread.isMainThread) })
                .sink(receiveValue: { [weak self] _ in
                    self?.expectation.fulfill()
                })
                .store(in: &self.disposeBag)
        }
        waitForExpectations(timeout: 1)
    }

    func testSubscribeObThreadIsTheThreadTheSubscriptionStartsOn_Background() throws {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            Just(3)
                .handleEvents(receiveOutput: { _ in XCTAssertFalse(Thread.isMainThread) })
                .receive(on: DispatchQueue.main)
                .handleEvents(receiveOutput: { _ in XCTAssertTrue(Thread.isMainThread) })
                .receive(on: DispatchQueue.global(qos: .userInteractive))
                .handleEvents(receiveOutput: { _ in XCTAssertFalse(Thread.isMainThread) })
                .subscribe(on: DispatchQueue.global(qos: .userInteractive))
                .sink(receiveValue: { [weak self] _ in
                    self?.expectation.fulfill()
                })
                .store(in: &self.disposeBag)
        }
        waitForExpectations(timeout: 1)
    }

    func testSubscribeObThreadIsTheThreadTheSubscriptionStartsOn_Main() throws {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            Just(3)
                .handleEvents(receiveOutput: { _ in XCTAssertTrue(Thread.isMainThread) })
                .receive(on: DispatchQueue.main)
                .handleEvents(receiveOutput: { _ in XCTAssertTrue(Thread.isMainThread) })
                .receive(on: DispatchQueue.global(qos: .userInteractive))
                .handleEvents(receiveOutput: { _ in XCTAssertFalse(Thread.isMainThread) })
                .subscribe(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] _ in
                    self?.expectation.fulfill()
                })
                .store(in: &self.disposeBag)
        }
        waitForExpectations(timeout: 1)
    }

    func test1() throws {
        Deferred {
            Future<Int, Never> { promise in
                DispatchQueue.global(qos: .userInteractive).async {
                    promise(Result.success(3))
                }
            }
        }
        .handleEvents(receiveOutput: { _ in XCTAssertTrue(Thread.isMainThread) })
        .receive(on: DispatchQueue.main)
        .handleEvents(receiveOutput: { _ in XCTAssertTrue(Thread.isMainThread) })
        .receive(on: DispatchQueue.global(qos: .userInteractive))
        .handleEvents(receiveOutput: { _ in XCTAssertFalse(Thread.isMainThread) })
        .subscribe(on: DispatchQueue.main)
        .sink(receiveValue: { [weak self] _ in
            self?.expectation.fulfill()
        })
        .store(in: &self.disposeBag)

        waitForExpectations(timeout: 3)
    }

    func test2() throws {
        Deferred {
            Future<Int, Never> { promise in
                DispatchQueue.global(qos: .userInteractive).async {
                    promise(Result.success(3))
                }
            }
        }
        .handleEvents(receiveOutput: { _ in XCTAssertFalse(Thread.isMainThread) })
        .receive(on: DispatchQueue.main)
        .handleEvents(receiveOutput: { _ in XCTAssertTrue(Thread.isMainThread) })
        .receive(on: DispatchQueue.global(qos: .userInteractive))
        .handleEvents(receiveOutput: { _ in XCTAssertFalse(Thread.isMainThread) })
        .sink(receiveValue: { [weak self] _ in
            self?.expectation.fulfill()
        })
        .store(in: &self.disposeBag)

        waitForExpectations(timeout: 3)
    }
}
