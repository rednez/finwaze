import SwiftUI

/// The signed-in app: the five primary sections in the tab bar (`NAV-01`). Secondary sections open from
/// the "More" menu of any section (`NAV-02`), so the tab bar never folds a primary section into "More".
struct MainTabView: View {
    @State private var selection: AppSection = .dashboard

    var body: some View {
        TabView(selection: $selection) {
            ForEach(AppSection.primary, id: \.self) { section in
                Tab(section.tabTitle, systemImage: section.systemImage, value: section) {
                    SectionView(section: section)
                }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}

#Preview {
    MainTabView()
        .environment(AppViewModel.preview)
}
