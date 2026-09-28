import Foundation

/// An amount with its name, to show as a sector of a ring — e.g. a category's budget or a group's expenses.
nonisolated struct NamedAmount: Equatable, Sendable {
    let name: String
    let amount: Decimal
}

/// A sector of a ring (`DASH-05`, `ACC-05`).
nonisolated struct ChartSlice: Identifiable, Equatable, Sendable {
    /// Position in the ring, largest first; picks the colour.
    let id: Int
    /// `nil` for "Other categories".
    let name: String?
    let amount: Decimal

    var isOther: Bool { name == nil }
}

/// A ring's sectors and total (`DASH-05`, `ACC-05`).
nonisolated struct SliceSummary: Equatable, Sendable {
    /// With more items than this, the smallest are joined into "Other categories", like the web.
    static let maxSlices = 7

    let slices: [ChartSlice]
    let total: Decimal

    /// Largest first; beyond `maxSlices` items, the six largest and "Other categories" with the rest.
    init(_ items: [NamedAmount]) {
        let sorted = items.sorted { ($0.amount, $1.name) > ($1.amount, $0.name) }
        total = sorted.reduce(0) { $0 + $1.amount }

        let shown = sorted.count <= Self.maxSlices ? sorted : Array(sorted.prefix(Self.maxSlices - 1))
        var slices = shown.enumerated().map { index, item in
            ChartSlice(id: index, name: item.name, amount: item.amount)
        }
        if shown.count < sorted.count {
            let rest = sorted.dropFirst(shown.count).reduce(0) { $0 + $1.amount }
            slices.append(ChartSlice(id: slices.count, name: nil, amount: rest))
        }
        self.slices = slices
    }

    /// The slice's part of the total, 0…1; 0 when the total is.
    func share(of slice: ChartSlice) -> Decimal {
        total == 0 ? 0 : slice.amount / total
    }
}
