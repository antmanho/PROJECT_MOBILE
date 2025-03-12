import SwiftUI

// For properly formatting percentages
extension FormatStyle where Self == FloatingPointFormatStyle<Double>.Percent {
    static var percent: Self {
        .percent.scale(100)
    }
}