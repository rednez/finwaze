import SwiftUI

/// Progress as a ring that fills when it appears, like an Activity ring, with the share in the middle.
struct ProgressRing: View {
    /// 0…1; more is drawn as a full ring.
    let fraction: Double
    var tint: Color = .accentColor
    @ScaledMetric(relativeTo: .title) private var size: CGFloat = 64
    @State private var shown = 0.0

    var body: some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.18), lineWidth: size * 0.14)
            Circle()
                .trim(from: 0, to: shown)
                .stroke(tint.gradient, style: StrokeStyle(lineWidth: size * 0.14, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text(verbatim: min(fraction, 9.99).formatted(.percent.precision(.fractionLength(0))))
                .font(.subheadline.weight(.bold))
                .fontDesign(.rounded)
                .monospacedDigit()
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .padding(size * 0.18)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.smooth(duration: 0.9)) { shown = min(max(fraction, 0), 1) }
        }
        .onChange(of: fraction) { _, value in
            withAnimation(.smooth) { shown = min(max(value, 0), 1) }
        }
        .accessibilityElement()
        .accessibilityValue(Text(verbatim: fraction.formatted(.percent.precision(.fractionLength(0)))))
    }
}

#Preview {
    HStack {
        ProgressRing(fraction: 0.58, tint: .green)
        ProgressRing(fraction: 1.2, tint: .red)
    }
}
