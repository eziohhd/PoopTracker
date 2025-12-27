//
//  MonthlySummaryView.swift
//  PoopTracker
//
//  月度总结视图
//

import SwiftUI

struct MonthlySummaryView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedMonth = Date()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 月份选择器
                    monthPicker
                    
                    // 统计卡片
                    if let stats = getStats() {
                        statsCards(stats: stats)
                        
                        // 大小分布
                        sizeDistribution(stats: stats)
                        
                        // 每日趋势
                        dailyTrend(stats: stats)
                    } else {
                        emptyState
                    }
                }
                .padding()
            }
            .navigationTitle("月度统计")
        }
    }
    
    private var monthPicker: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Text(dateFormatter.string(from: selectedMonth))
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func statsCards(stats: MonthlyStats) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                StatCard(
                    title: "总次数",
                    value: "\(stats.totalCount)",
                    icon: "number.circle.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "有记录天数",
                    value: "\(stats.daysWithPoop)",
                    icon: "calendar.circle.fill",
                    color: .green
                )
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "平均每天",
                    value: String(format: "%.1f", stats.averagePerDay),
                    icon: "chart.line.uptrend.xyaxis.circle.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "记录率",
                    value: String(format: "%.0f%%", Double(stats.daysWithPoop) / Double(stats.totalDays) * 100),
                    icon: "percent.circle.fill",
                    color: .purple
                )
            }
        }
    }
    
    private func sizeDistribution(stats: MonthlyStats) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("大小分布")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                ForEach(PoopSize.allCases, id: \.self) { size in
                    let count = stats.sizeDistribution[size] ?? 0
                    let percentage = stats.totalCount > 0 ? Double(count) / Double(stats.totalCount) * 100 : 0
                    
                    HStack {
                        Text(size.emoji)
                            .font(.title3)
                        
                        Text(size.rawValue)
                            .font(.subheadline)
                            .frame(width: 40, alignment: .leading)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color(.systemGray5))
                                    .frame(height: 20)
                                
                                Rectangle()
                                    .fill(sizeColor(size))
                                    .frame(width: geometry.size.width * CGFloat(percentage / 100), height: 20)
                            }
                        }
                        .frame(height: 20)
                        
                        Text("\(count)次")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 50, alignment: .trailing)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private func dailyTrend(stats: MonthlyStats) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("每日趋势")
                .font(.headline)
                .padding(.horizontal)
            
            let monthRecords = dataManager.getRecords(forMonth: selectedMonth)
            let calendar = Calendar.current
            var dailyCounts: [Int: Int] = [:]
            
            for record in monthRecords {
                let day = calendar.component(.day, from: record.date)
                dailyCounts[day, default: 0] += 1
            }
            
            let maxCount = dailyCounts.values.max() ?? 1
            
            VStack(spacing: 4) {
                ForEach(1...calendar.range(of: .day, in: .month, for: selectedMonth)?.count ?? 30, id: \.self) { day in
                    let count = dailyCounts[day] ?? 0
                    let height = maxCount > 0 ? CGFloat(count) / CGFloat(maxCount) : 0
                    
                    HStack(alignment: .bottom, spacing: 4) {
                        Text("\(day)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(width: 30, alignment: .trailing)
                        
                        Rectangle()
                            .fill(count > 0 ? Color.blue : Color(.systemGray5))
                            .frame(width: 20, height: max(4, height * 100))
                            .cornerRadius(2)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("本月还没有记录")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private func getStats() -> MonthlyStats? {
        let stats = dataManager.getMonthlyStats(for: selectedMonth)
        return stats.totalCount > 0 ? stats : nil
    }
    
    private func sizeColor(_ size: PoopSize) -> Color {
        switch size {
        case .small: return .green
        case .medium: return .orange
        case .large: return .red
        }
    }
    
    private func previousMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
}

// 统计卡片
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

