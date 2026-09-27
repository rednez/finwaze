import Foundation
import Synchronization
@testable import Finwaze

final class FakeGroupsRepository: GroupsRepository {
    /// One recorded call to `updateGroup` or `updateCategory`.
    struct UpdateCall: Equatable {
        let id: Int64
        let name: String
        let color: String?
    }

    private struct State {
        var groups: [GroupWithCategories] = []
        var loadFails = false
        var writeFails = false
        /// Ids `update…` answers "not found" for.
        var missingIDs: Set<Int64> = []
        var loads = 0
        var updatedGroups: [UpdateCall] = []
        var updatedCategories: [UpdateCall] = []
        var deletedGroupIDs: [Int64] = []
        var deletedCategoryIDs: [Int64] = []
    }

    private let state = Mutex(State())

    var loads: Int { state.withLock { $0.loads } }
    var updatedGroups: [UpdateCall] { state.withLock { $0.updatedGroups } }
    var updatedCategories: [UpdateCall] { state.withLock { $0.updatedCategories } }
    var deletedGroupIDs: [Int64] { state.withLock { $0.deletedGroupIDs } }
    var deletedCategoryIDs: [Int64] { state.withLock { $0.deletedCategoryIDs } }

    func setGroups(_ groups: [GroupWithCategories]) {
        state.withLock { $0.groups = groups }
    }

    func setLoadFails(_ fails: Bool) {
        state.withLock { $0.loadFails = fails }
    }

    func setWriteFails(_ fails: Bool) {
        state.withLock { $0.writeFails = fails }
    }

    /// Simulates the group or category being deleted elsewhere: updating it answers "not found".
    func setMissing(_ id: Int64) {
        state.withLock { _ = $0.missingIDs.insert(id) }
    }

    func groups() async throws -> [GroupWithCategories] {
        try state.withLock { state in
            state.loads += 1
            if state.loadFails { throw FakeLoadError() }
            return state.groups
        }
    }

    func updateGroup(id: Int64, name: String, color: String?) async throws -> Bool {
        try state.withLock { state in
            if state.writeFails { throw FakeCreateError() }
            state.updatedGroups.append(UpdateCall(id: id, name: name, color: color))
            return !state.missingIDs.contains(id)
        }
    }

    func deleteGroup(id: Int64) async throws {
        try state.withLock { state in
            if state.writeFails { throw FakeCreateError() }
            state.deletedGroupIDs.append(id)
        }
    }

    func updateCategory(id: Int64, name: String, color: String?) async throws -> Bool {
        try state.withLock { state in
            if state.writeFails { throw FakeCreateError() }
            state.updatedCategories.append(UpdateCall(id: id, name: name, color: color))
            return !state.missingIDs.contains(id)
        }
    }

    func deleteCategory(id: Int64) async throws {
        try state.withLock { state in
            if state.writeFails { throw FakeCreateError() }
            state.deletedCategoryIDs.append(id)
        }
    }
}
