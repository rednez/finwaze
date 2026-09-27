import Foundation

protocol CategoriesRepository: Sendable {
    /// User groups; system groups are excluded (`GEN-05`).
    func groups() async throws -> [CategoryGroup]
    /// User categories; system categories are excluded (`GEN-05`).
    func categories() async throws -> [Category]
}
