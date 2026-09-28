import SwiftUI

/// The signed-in app: the four primary sections in the tab bar (`NAV-01`) and "More" with the secondary ones
/// (`NAV-02`), so the tab bar always shows the section on screen.
struct MainTabView: View {
    @State private var navigation = MainNavigation()
    /// Analytics' filters, kept for the session: Analytics is pushed and gone after "Back" (`ANL-01`).
    @State private var analyticsFilter = AnalyticsFilter()

    var body: some View {
        @Bindable var navigation = navigation
        TabView(selection: $navigation.selection) {
            ForEach(AppSection.primary, id: \.self) { section in
                Tab(section.tabTitle, systemImage: section.systemImage, value: MainTab.section(section)) {
                    SectionView(section: section)
                }
            }

            Tab("section.more", systemImage: "ellipsis", value: MainTab.more) {
                TabStack(path: $navigation.morePath) {
                    MoreView()
                }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .environment(navigation)
        .environment(analyticsFilter)
    }
}

#Preview {
    MainTabView()
        .environment(AppViewModel.preview)
}
