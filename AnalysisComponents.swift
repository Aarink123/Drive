//
//  PerformanceBreakdownView.swift
//  DriveQuest
//
//  Created by Aarin Karamchandani on 6/18/25.
//


import SwiftUI

// MARK: - Performance Breakdown Components

struct PerformanceBreakdownView: View {
    let breakdown: PerformanceBreakdown
    @State private var animate = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance Breakdown")
                .font(.title2).fontWeight(.bold).foregroundColor(.white)
            
            HStack(alignment: .bottom, spacing: 12) {
                BarView(value: breakdown.control, label: "Control", color: .green, animate: animate)
                BarView(value: breakdown.speed, label: "Speed", color: .orange, animate: animate)
                BarView(value: breakdown.aware, label: "Aware", color: .blue, animate: animate)
                BarView(value: breakdown.follow, label: "Follow", color: .cyan, animate: animate)
                BarView(value: breakdown.smooth, label: "Smooth", color: .red, animate: animate)
            }
            .frame(height: 200)
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(16)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) {
                    animate = true
                }
            }
        }
    }
}

struct BarView: View {
    let value: Int
    let label: String
    let color: Color
    let animate: Bool
    
    var body: some View {
        VStack {
            Text("\(value)")
                .font(.caption).fontWeight(.bold)
                .foregroundColor(.white)
                .opacity(animate ? 1.0 : 0.0)
            
            VStack {
                Spacer()
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .frame(height: animate ? CGFloat(value) * 1.5 : 0)
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}


// MARK: - Maneuver Analysis Components

struct ManeuverAnalysisListView: View {
    let analyses: [ManeuverAnalysis]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Maneuver Analysis")
                .font(.title2).fontWeight(.bold).foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(analyses) { analysis in
                    ManeuverAnalysisRow(analysis: analysis)
                }
            }
        }
    }
}

struct ManeuverAnalysisRow: View {
    let analysis: ManeuverAnalysis
    
    var gradeColor: Color {
        switch analysis.grade.prefix(1) {
        case "A": return .green
        case "B": return .yellow
        case "C": return .orange
        default: return .red
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: analysis.icon)
                .font(.title2)
                .foregroundColor(gradeColor)
                .frame(width: 35)

            VStack(alignment: .leading) {
                Text(analysis.name)
                    .font(.headline)
                Text(analysis.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .foregroundColor(.white)
            
            Spacer()
            
            Text(analysis.grade)
                .font(.title2).fontWeight(.bold)
                .foregroundColor(gradeColor)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}