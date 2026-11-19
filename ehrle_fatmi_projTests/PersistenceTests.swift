//
//  PersistenceTests.swift
//  ehrle_fatmi_projTests
//
//  Vérifie la pile Core Data en mémoire.
//

import CoreData
import XCTest
@testable import ehrle_fatmi_proj

final class PersistenceTests: XCTestCase {

    func testInMemoryStoreStartsEmpty() throws {
        let controller = PersistenceController(inMemory: true)
        let count = try controller.container.viewContext.count(for: Item.fetchRequest())
        XCTAssertEqual(count, 0)
    }

    func testSaveAndFetchItem() throws {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        let date = Date(timeIntervalSince1970: 1_000_000)

        let item = Item(context: context)
        item.timestamp = date
        try context.save()

        let items = try context.fetch(Item.fetchRequest())
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.timestamp, date)
    }

    func testDeleteItem() throws {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        let item = Item(context: context)
        item.timestamp = Date()
        try context.save()

        context.delete(item)
        try context.save()

        XCTAssertEqual(try context.count(for: Item.fetchRequest()), 0)
    }

    @MainActor
    func testPreviewControllerContainsTenItems() throws {
        let context = PersistenceController.preview.container.viewContext
        XCTAssertEqual(try context.count(for: Item.fetchRequest()), 10)
    }
}
