import SwiftUI

/// The "More" tab's first screen: the secondary sections, each opened in this tab (`NAV-02`).
struct MoreView: View {
    var body: some View {
        List(AppSection.secondary, id: \.self) { section in
            NavigationLink(value: section) {
                Label(section.title, systemImage: section.systemImage)
            }
        }
        .navigationTitle("section.more")
        .sectionToolbar(for: nil)
    }
}

#Preview {
    NavigationStack {
        MoreView()
    }
    .environment(AppViewModel.preview)
}
