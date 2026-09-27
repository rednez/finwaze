import Foundation
import Testing
@testable import Finwaze

@MainActor
struct CategoryPickerViewModelTests {
    private let car = CategoryGroup(id: 3, name: "Car", transactionType: .expense, color: nil)
    private let fuel = Finwaze.Category(id: 5, name: "Fuel", groupID: 3, color: nil)
    private let cafe = Finwaze.Category(id: 6, name: "Café", groupID: 1, color: nil)

    private func makeViewModel(type: TransactionType) async throws -> CategoryPickerViewModel {
        let referenceData = try await makeReferenceData(
            FakeReferenceDataRepository(
                groups: [FakeReferenceDataRepository.food, FakeReferenceDataRepository.salary, car],
                categories: [FakeReferenceDataRepository.groceries, FakeReferenceDataRepository.paycheck, fuel, cafe]
            )
        )
        return CategoryPickerViewModel(type: type, referenceData: referenceData)
    }

    @Test func showsOnlyGroupsOfTheFormType() async throws {
        #expect(try await makeViewModel(type: .expense).groups == [FakeReferenceDataRepository.food, car])
        #expect(try await makeViewModel(type: .income).groups == [FakeReferenceDataRepository.salary])
    }

    @Test func listsCategoriesOfAGroup() async throws {
        let viewModel = try await makeViewModel(type: .expense)

        #expect(viewModel.categories(in: FakeReferenceDataRepository.food) == [FakeReferenceDataRepository.groceries, cafe])
    }

    @Test func searchesAcrossGroupsIgnoringCaseAndDiacritics() async throws {
        let viewModel = try await makeViewModel(type: .expense)

        viewModel.query = "CAFE"
        #expect(viewModel.searchResults.map(\.category) == [cafe])
        #expect(viewModel.searchResults.first?.group == FakeReferenceDataRepository.food)

        viewModel.query = "e"
        #expect(viewModel.searchResults.map(\.category) == [FakeReferenceDataRepository.groceries, fuel, cafe])
    }

    @Test func searchSkipsCategoriesOfTheOtherType() async throws {
        let viewModel = try await makeViewModel(type: .expense)

        viewModel.query = "pay"

        #expect(viewModel.searchResults.isEmpty)
    }

    @Test func noQueryNoResults() async throws {
        let viewModel = try await makeViewModel(type: .expense)

        viewModel.query = "  "

        #expect(viewModel.searchResults.isEmpty)
    }
}

@MainActor
struct NamePromptViewModelTests {
    @Test(arguments: [
        ("", NamePromptViewModel.NameIssue?.some(.required)),
        ("   ", .some(.required)),
        (String(repeating: "a", count: 25), nil),
        (" \(String(repeating: "a", count: 25)) ", nil),
        (String(repeating: "a", count: 26), .some(.tooLong)),
    ])
    func nameIsRequiredAndAtMostTwentyFiveCharacters(_ name: String, issue: NamePromptViewModel.NameIssue?) async {
        var created: [String] = []
        let viewModel = NamePromptViewModel { name, _ in created.append(name) }
        viewModel.name = name

        let succeeded = await viewModel.submit()

        #expect(viewModel.nameIssue == issue)
        #expect(succeeded == (issue == nil))
        #expect(created == (issue == nil ? [name.trimmingCharacters(in: .whitespaces)] : []))
    }

    @Test func hidesErrorUntilSubmit() {
        #expect(NamePromptViewModel { _, _ in }.nameIssue == nil)
    }

    @Test func sendsChosenColorOrNone() async {
        var created: [(name: String, color: String?)] = []
        let viewModel = NamePromptViewModel { created.append(($0, $1)) }
        viewModel.name = "Travel"
        #expect(viewModel.color == nil)

        #expect(await viewModel.submit())
        viewModel.color = ColorPalette.colors[16]
        #expect(await viewModel.submit())

        #expect(created.map(\.color) == [nil, "#38BDF8"])
    }

    @Test func failureKeepsTheName() async {
        let viewModel = NamePromptViewModel { _, _ in throw FakeCreateError() }
        viewModel.name = "Travel"

        #expect(await viewModel.submit() == false)

        #expect(viewModel.failure == "duplicate key value")
        #expect(viewModel.name == "Travel")
        #expect(!viewModel.isSubmitting)
    }
}

struct ColorPaletteTests {
    /// The same 24 colours as the web palette, each a valid `#RRGGBB`.
    @Test func hasTwentyFourDistinctColors() {
        #expect(ColorPalette.colors.count == 24)
        #expect(Set(ColorPalette.colors).count == 24)
        #expect(ColorPalette.colors.allSatisfy { $0.wholeMatch(of: /#[0-9A-F]{6}/) != nil })
    }

    @Test func encodesColorOnlyWhenSet() throws {
        let withColor = try JSONEncoder().encode(NewGroupDto(name: "Travel", transactionType: .expense, color: "#38BDF8"))
        let withoutColor = try JSONEncoder().encode(NewCategoryDto(name: "Hotels", groupID: 1, color: nil))

        #expect(String(decoding: withColor, as: UTF8.self).contains(##""color":"#38BDF8""##))
        #expect(!String(decoding: withoutColor, as: UTF8.self).contains("color"))
    }
}
