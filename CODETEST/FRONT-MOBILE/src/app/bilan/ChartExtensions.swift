// ChartExtensions.swift

import SwiftUI
import UIKit

#if canImport(Charts) && os(iOS) && !arch(arm64)
// This is a fallback implementation using Core Graphics for iOS versions before 16
class LineChartView: UIView {
    var data: [ChartDataEntry] = []
    var referenceValue: Double?
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), !data.isEmpty else { return }
        
        let width = rect.width
        let height = rect.height
        let padding: CGFloat = 20
        
        // Calculate min/max values
        let allValues = data.map { $0.value }
        let maxValue = allValues.max() ?? 1
        let minValue = min(allValues.min() ?? 0, 0)
        let range = max(maxValue - minValue, 1)
        
        // Scale factor
        let scaleY = (height - padding * 2) / CGFloat(range)
        let scaleX = (width - padding * 2) / CGFloat(data.count - 1)
        
        // Origin point
        let originY = height - padding - CGFloat(abs(minValue)) * scaleY
        
        // Draw reference line if needed
        if let refValue = referenceValue {
            let y = originY - CGFloat(refValue - minValue) * scaleY
            context.setStrokeColor(UIColor.yellow.cgColor)
            context.setLineWidth(2)
            context.move(to: CGPoint(x: padding, y: y))
            context.addLine(to: CGPoint(x: width - padding, y: y))
            context.strokePath()
        }
        
        // Draw data line
        context.setStrokeColor(UIColor.blue.cgColor)
        context.setLineWidth(2)
        
        for (index, entry) in data.enumerated() {
            let x = padding + CGFloat(index) * scaleX
            let y = originY - CGFloat(entry.value - minValue) * scaleY
            
            if index == 0 {
                context.move(to: CGPoint(x: x, y: y))
            } else {
                context.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        context.strokePath()
    }
}

struct LineChartViewRepresentable: UIViewRepresentable {
    var data: [ChartDataEntry]
    var referenceValue: Double?
    
    func makeUIView(context: Context) -> LineChartView {
        return LineChartView()
    }
    
    func updateUIView(_ uiView: LineChartView, context: Context) {
        uiView.data = data
        uiView.referenceValue = referenceValue
        uiView.setNeedsDisplay()
    }
}

class PieChartView: UIView {
    var data: [PieChartDataEntry] = []
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), !data.isEmpty else { return }
        
        let total = data.reduce(0) { $0 + $1.value }
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 - 20
        let innerRadius = radius * 0.5
        
        var startAngle: CGFloat = 0
        
        let colors: [UIColor] = [.systemBlue, .systemGreen, .systemOrange, .systemPink, .systemPurple, .systemYellow]
        
        for (index, entry) in data.enumerated() {
            let endAngle = startAngle + CGFloat(entry.value / total) * 2 * .pi
            
            // Draw sector
            context.setFillColor(colors[index % colors.count].cgColor)
            context.move(to: center)
            context.addArc(
                center: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: false
            )
            context.closePath()
            context.fillPath()
            
            // Draw inner circle for donut effect
            context.setFillColor(UIColor.white.cgColor)
            context.addArc(
                center: center,
                radius: innerRadius,
                startAngle: 0,
                endAngle: 2 * .pi,
                clockwise: false
            )
            context.fillPath()
            
            startAngle = endAngle
        }
    }
}

struct PieChartViewRepresentable: UIViewRepresentable {
    var data: [PieChartDataEntry]
    
    func makeUIView(context: Context) -> PieChartView {
        return PieChartView()
    }
    
    func updateUIView(_ uiView: PieChartView, context: Context) {
        uiView.data = data
        uiView.setNeedsDisplay()
    }
}
#endif