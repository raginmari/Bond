//
//  PositionDependentCollectionChangeset+Array2D.swift
//  Bond-iOS
//
//  Created by Srdan Rasic on 27/09/2018.
//  Copyright © 2018 Swift Bond. All rights reserved.
//

import Foundation
import ReactiveKit

public typealias Array2D<Section, Item> = TreeArray<Array2DElement<Section, Item>>

public protocol Array2DElementProtocol {
    associatedtype Section
    associatedtype Item
    var section: Section? { get }
    var item: Item? { get }
    init(section: Section)
    init(item: Item)
    var asSectionedData: Array2DElement<Section, Item> { get }
}

public enum Array2DElement<Section, Item>: Array2DElementProtocol {
    case section(Section)
    case item(Item)

    public init(item: Item) {
        self = .item(item)
    }

    public init(section: Section) {
        self = .section(section)
    }

    public var section: Section? {
        if case .section(let section) = self {
            return section
        } else {
            return nil
        }
    }

    public var item: Item? {
        if case .item(let item) = self {
            return item
        } else {
            return nil
        }
    }

    public var asSectionedData: Array2DElement<Section, Item> {
        return self
    }
}

extension ChangesetContainerProtocol where Changeset: TreeChangesetProtocol, Changeset.Collection: TreeArrayProtocol, Changeset.Collection.ChildValue: Array2DElementProtocol {

    public typealias Section = Collection.ChildValue.Section
    public typealias Item = Collection.ChildValue.Item
    public typealias SectionedData = Changeset.Collection.ChildValue

    public subscript(itemAt indexPath: IndexPath) -> Item {
        get {
            return collection.asTreeArray[indexPath].value.item!
        }
        set {
            descriptiveUpdate { (collection) -> [Operation] in
                collection.asTreeArray[indexPath].value = SectionedData(item: newValue)
                return [.update(at: indexPath, newElement: collection[indexPath])]
            }
        }
    }

    public subscript(sectionAt index: Int) -> Section {
        get {
            return collection.asTreeArray[[index]].value.section!
        }
        set {
            descriptiveUpdate { (collection) -> [Operation] in
                collection.asTreeArray[[index]].value = SectionedData(section: newValue)
                return [.update(at: [index], newElement: collection[[index]])]
            }
        }
    }

    /// Append new section at the end of the 2D array.
    public func appendSection(_ section: Section) {
        append(TreeNode(SectionedData(section: section)))
    }

    /// Append `item` to the section `section` of the array.
    public func appendItem(_ item: Item, toSectionAt sectionIndex: Int) {
        insert(item: item, at: [sectionIndex, collection[[sectionIndex]].children.count])
    }

    /// Insert section at `index` with `items`.
    public func insert(section: Section, at index: Int)  {
        insert(TreeNode(SectionedData(section: section)), at: [index])
    }

    /// Insert `item` at `indexPath`.
    public func insert(item: Item, at indexPath: IndexPath)  {
        insert(TreeNode(SectionedData(item: item)), at: indexPath)
    }
//
//    /// Insert `items` at index path `indexPath`.
//    public func insert(contentsOf items: [Collection.Item], at indexPath: IndexPath) {
//        insert(contentsOf: items.map { .item($0) }, at: indexPath)
//    }

    /// Move the section at index `fromIndex` to index `toIndex`.
    public func moveSection(from fromIndex: Int, to toIndex: Int) {
        move(from: [fromIndex], to: [toIndex])
    }

    /// Move the item at `fromIndexPath` to `toIndexPath`.
    public func moveItem(from fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        move(from: fromIndexPath, to: toIndexPath)
    }

    /// Remove and return the section at `index`.
    @discardableResult
    public func removeSection(at index: Int) -> Section {
        return remove(at: [index]).value.section!
    }

    /// Remove and return the item at `indexPath`.
    @discardableResult
    public func removeItem(at indexPath: IndexPath) -> Item {
        return remove(at: indexPath).value.item!
    }

    /// Remove all items from the array. Keep empty sections.
    public func removeAllItems() {
        descriptiveUpdate { (collection) -> [Operation] in
            let indices = collection.asTreeArray.indices.map { $0 }.filter { $0.count == 2 }
            for index in indices {
                collection.asTreeArray[index].removeAll()
            }
            return indices.reversed().map { .delete(at: $0) }
        }
    }

    /// Remove all items and sections from the array.
    public func removeAllItemsAndSections() {
        removeAll()
    }
}
