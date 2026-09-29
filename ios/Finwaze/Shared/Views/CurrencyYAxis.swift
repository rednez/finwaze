import Charts
import SwiftUI

extension View {
    /// A chart's value axis with grid lines and short amounts in `currencyCode`: `₴1.2K`.
    func currencyYAxis(currencyCode: String) -> some View {
        chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel {
                    if let amount = value.as(Double.self) {
                        Text(verbatim: Decimal(amount).formattedCompactAmount(currencyCode: currencyCode))
                    }
                }
            }
        }
    }
}
