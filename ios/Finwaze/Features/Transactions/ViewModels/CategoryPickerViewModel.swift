import Foundation
import Observation

/// Picks a group and category in one field (`TX-11`): the groups of the form's type, their categories, and a search
/// across all of them. New groups and categories are created from here (`TX-12`).
@Observable
final class CategoryPickerViewModel {
    /// A search hit, shown as "category — group".
    struct SearchResult: Identifiable, Equatable {
        let category: Category
        let group: CategoryGroup

        var id: Int64 { category.id }
    }

    let type: TransactionType
    var query = ""

    private let referenceData: ReferenceDataStore

    init(type: TransactionType, referenceData: ReferenceDataStore) {
        self.type = type
        self.referenceData = referenceData
    }

    /// Groups of the form's type only: expense groups for an expense, income groups for an income.
    var groups: [CategoryGroup] {
        referenceData.groups.filter { $0.transactionType == type }
    }

    func categories(in group: CategoryGroup) -> [Category] {
        referenceData.categories.filter { $0.groupID == group.id }
    }

    /// Categories whose name contains the query, ignoring case and diacritics; empty while there is no query.
    var searchResults: [SearchResult] {
        let query = query.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return [] }
        let groupsByID = Dictionary(uniqueKeysWithValues: groups.map { ($0.id, $0) })
        return referenceData.categories.compactMap { category in
            guard let group = groupsByID[category.groupID], category.name.localizedStandardContains(query) else {
                return nil
            }
            return SearchResult(category: category, group: group)
        }
    }

    /// Looks a group up again after reference data reloads, e.g. one just created.
    func group(withID id: Int64) -> CategoryGroup? {
        groups.first { $0.id == id }
    }
}
