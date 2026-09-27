import Foundation
import Testing
@testable import Finwaze

struct GroupsDataTests {
    @Test func mapsViewRowsWithNestedCategories() throws {
        let json = #"""
        [{"id": 2, "name": "Salary", "color": null, "transaction_type": "income", "categories": []},
         {"id": 1, "name": "Food", "color": "#22C55E", "transaction_type": "expense",
          "categories": [{"id": 10, "name": "Groceries", "color": null, "transactions_count": 3}]}]
        """#

        let groups = GroupsMapper.sorted(
            try JSONDecoder().decode([GroupWithCategoriesDto].self, from: Data(json.utf8)).map(GroupsMapper.toGroup)
        )

        #expect(groups.map(\.id) == [1, 2])
        #expect(groups[0].color == "#22C55E")
        #expect(groups[0].categories == [.init(id: 10, name: "Groceries", color: nil, transactionsCount: 3)])
        #expect(groups[1].transactionType == .income)
        #expect(groups[1].categories.isEmpty)
    }

    /// A cleared colour must reach the server as `null`, not be left out (`CAT-10`).
    @Test func updateSendsAClearedColorAsNull() throws {
        let data = try JSONEncoder().encode(NameColorUpdateDto(name: "Food", color: nil))
        let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(json["name"] as? String == "Food")
        #expect(json.keys.contains("color"))
        #expect(json["color"] is NSNull)
    }

    @Test func demoCategoriesAllHaveTransactions() async throws {
        let groups = try await DemoGroupsRepository().groups()

        #expect(groups.map(\.name) == DemoData.groups.map(\.name))
        #expect(groups.flatMap(\.categories).count == DemoData.categories.count)
        #expect(groups.flatMap(\.categories).allSatisfy { !$0.canDelete })
        #expect(groups.first { $0.name == "Food" }?.categories.first { $0.name == "Groceries" }?.transactionsCount == 3)
    }

    @Test func demoWritesChangeNothing() async throws {
        let repository = DemoGroupsRepository()
        let before = try await repository.groups()

        #expect(try await repository.updateGroup(id: 1, name: "Changed", color: nil))
        #expect(try await repository.updateCategory(id: 1, name: "Changed", color: nil))
        try await repository.deleteGroup(id: 1)
        try await repository.deleteCategory(id: 1)

        #expect(try await repository.groups() == before)
    }
}
