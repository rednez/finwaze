import Foundation

/// The "Groups & categories" screen's data (`CAT-01…10`). Creating groups and categories stays in
/// `CategoriesRepository`, shared with the category picker.
protocol GroupsRepository: Sendable {
    /// The user's groups with their categories and transaction counts; system records excluded (`GEN-05`).
    func groups() async throws -> [GroupWithCategories]
    /// Renames a group and sets or clears its colour (`CAT-05`, `CAT-10`); `false` when it no longer exists.
    func updateGroup(id: Int64, name: String, color: String?) async throws -> Bool
    /// Deletes a group without categories (`CAT-06`).
    func deleteGroup(id: Int64) async throws
    /// Renames a category and sets or clears its colour (`CAT-08`, `CAT-10`); `false` when it no longer exists.
    func updateCategory(id: Int64, name: String, color: String?) async throws -> Bool
    /// Deletes a category without transactions (`CAT-09`).
    func deleteCategory(id: Int64) async throws
}
