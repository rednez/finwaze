import Foundation

/// The guide's navigation path: empty on its first screen, the open article on top of it. Going to a neighbouring
/// article replaces the open one, so "Back" always leads to all articles rather than through every article read.
struct GuideNavigation: Equatable {
    var path: [GuideTopic]

    /// The guide's first screen, or `initialTopic`'s article on top of it (`GUIDE-03`).
    init(initialTopic: GuideTopic? = nil) {
        path = initialTopic.map { [$0] } ?? []
    }

    /// The previous or next article, in place of the open one.
    mutating func show(_ topic: GuideTopic) {
        if path.isEmpty {
            path = [topic]
        } else {
            path[path.count - 1] = topic
        }
    }

    /// "All guides": back to the first screen.
    mutating func showAll() {
        path.removeAll()
    }
}
