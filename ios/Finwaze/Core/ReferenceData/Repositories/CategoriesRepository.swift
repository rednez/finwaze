import Foundation

protocol CategoriesRepository: Sendable {
    /// User groups; system groups are excluded (`GEN-05`).
    func groups() async throws -> [CategoryGroup]
    /// User categories; system categories are excluded (`GEN-05`).
    func categories() async throws -> [Category]
    /// Creates a group of `type` — expense or income, fixed from then on — with an optional palette colour
    /// (`TX-12`, `CAT-10`).
    func createGroup(name: String, type: TransactionType, color: String?) async throws -> CategoryGroup
    /// Creates a category in the group with an optional palette colour (`TX-12`, `CAT-10`).
    func createCategory(name: String, groupID: Int64, color: String?) async throws -> Category
}
