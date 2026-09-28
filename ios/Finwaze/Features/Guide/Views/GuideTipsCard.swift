import SwiftUI

/// An article's "Best practices": a card with a checked row per tip.
struct GuideTipsCard: View {
    let tips: [LocalizedStringResource]
    let color: Color

    var body: some View {
        ContentCard(title: "guide.tipsLabel") {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(tips, id: \.key) { tip in
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(color)
                            .accessibilityHidden(true)
                        Text(tip)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}

#Preview {
    GuideTipsCard(tips: GuideTopic.budget.tips, color: GuideTopic.budget.color)
        .padding()
        .background(Color(.systemGroupedBackground))
}
