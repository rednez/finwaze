/// A tab of the main app: one per primary section (`NAV-01`) and "More" with the secondary ones (`NAV-02`).
enum MainTab: Hashable {
    case section(AppSection)
    case more
}
