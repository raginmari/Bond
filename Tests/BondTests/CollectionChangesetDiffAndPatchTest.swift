//
//  Diffing.swift
//  Bond-iOS
//
//  Created by Srdan Rasic on 05/04/2018.
//  Copyright © 2018 Swift Bond. All rights reserved.
//

import XCTest
@testable import Bond

extension CollectionChangeset.Operation where Collection.Index == Int, Collection.Element == Int {

    static func randomOperation(collectionSize: Int) -> CollectionChangeset<Collection>.Operation {
        let element = Int.random(in: 11..<100)
        guard collectionSize > 1 else {
            return .insert(element, at: 0)
        }
        switch [0, 1, 2, 3].randomElement() {
        case 0:
            let at = Int.random(in: 0..<(collectionSize + 1))
            return .insert(element, at: at)
        case 1:
            let at = Int.random(in: 0..<collectionSize)
            return .delete(at: at)
        case 2:
            let at = Int.random(in: 0..<collectionSize)
            return .update(at: at, newElement: element)
        case 3:
            let from = Int.random(in: 0..<collectionSize)
            let to = Int.random(in: 0..<collectionSize-1)
            return .move(from: from, to: to)
        default:
            fatalError()
        }
    }
}

class CollectionChangesetDiffAndPatchTest: XCTestCase {

    func testRandom() {
        measure {
            for _ in 0..<1000 {
                oneRandomTest()
            }
        }
    }

    func oneRandomTest() {
        let initialCollection = Array(0..<4)
        var collection = initialCollection
        var operations: [CollectionChangeset<[Int]>.Operation] = []

        for _ in 0..<Int.random(in: 2...12) {
            let operation = CollectionChangeset<[Int]>.Operation.randomOperation(collectionSize: collection.count)
            collection.apply(operation)
            operations.append(operation)
        }

        execTest(operations: operations, initialCollection: initialCollection)
    }

    func execTest(operations: [CollectionChangeset<[Int]>.Operation], initialCollection: [Int]) {
        var collection = initialCollection

        for operation in operations {
            collection.apply(operation)
        }

        let diff = CollectionChangeset<[Int]>.Diff(from: operations)
        let patch = diff.generatePatch(to: collection)

        var testCollection = initialCollection
        for operation in patch {
            testCollection.apply(operation)
        }

        XCTAssertEqual(collection, testCollection, "Operations: \(operations), Diff: \(diff), Patch: \(patch)")
    }
}
