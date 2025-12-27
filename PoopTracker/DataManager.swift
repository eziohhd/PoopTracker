//
//  DataManager.swift
//  PoopTracker
//
//  数据管理器：负责数据的存储和读取
//

import Foundation
import SwiftUI
import Combine

class DataManager: ObservableObject {
    @Published var records: [PoopRecord] = []
    
    private let saveKey = "PoopRecords"
    
    init() {
        loadRecords()
    }
    
    // 添加记录
    func addRecord(_ record: PoopRecord) {
        records.append(record)
        saveRecords()
    }
    
    // 更新记录
    func updateRecord(_ record: PoopRecord) {
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index] = record
            saveRecords()
        }
    }
    
    // 删除记录
    func deleteRecord(_ record: PoopRecord) {
        records.removeAll { $0.id == record.id }
        saveRecords()
    }
    
    // 获取指定日期的记录
    func getRecords(for date: Date) -> [PoopRecord] {
        let calendar = Calendar.current
        return records.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    // 获取指定日期的每日汇总
    func getDailyRecord(for date: Date) -> DailyRecord? {
        let dayRecords = getRecords(for: date)
        guard !dayRecords.isEmpty else { return nil }
        return DailyRecord(date: date, records: dayRecords)
    }
    
    // 获取指定月份的所有记录
    func getRecords(forMonth month: Date) -> [PoopRecord] {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: month)
        let month = calendar.component(.month, from: month)
        
        return records.filter { record in
            let recordYear = calendar.component(.year, from: record.date)
            let recordMonth = calendar.component(.month, from: record.date)
            return recordYear == year && recordMonth == month
        }
    }
    
    // 获取月度统计
    func getMonthlyStats(for month: Date) -> MonthlyStats {
        let monthRecords = getRecords(forMonth: month)
        let calendar = Calendar.current
        
        var dailyCounts: [Date: Int] = [:]
        var sizeDistribution: [PoopSize: Int] = [.small: 0, .medium: 0, .large: 0]
        
        for record in monthRecords {
            let day = calendar.startOfDay(for: record.date)
            dailyCounts[day, default: 0] += 1
            sizeDistribution[record.size, default: 0] += 1
        }
        
        let totalCount = monthRecords.count
        let daysWithPoop = dailyCounts.keys.count
        let calendarRange = calendar.range(of: .day, in: .month, for: month)!
        let totalDays = calendarRange.count
        
        return MonthlyStats(
            month: month,
            totalCount: totalCount,
            daysWithPoop: daysWithPoop,
            totalDays: totalDays,
            averagePerDay: totalDays > 0 ? Double(totalCount) / Double(totalDays) : 0,
            sizeDistribution: sizeDistribution
        )
    }
    
    // 保存数据
    private func saveRecords() {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    // 加载数据
    private func loadRecords() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([PoopRecord].self, from: data) {
            records = decoded
        }
    }
}

// 月度统计数据
struct MonthlyStats {
    let month: Date
    let totalCount: Int
    let daysWithPoop: Int
    let totalDays: Int
    let averagePerDay: Double
    let sizeDistribution: [PoopSize: Int]
}

