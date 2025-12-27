//
//  PoopRecord.swift
//  PoopTracker
//
//  数据模型：记录拉屎信息
//

import Foundation

// 拉屎大小枚举
enum PoopSize: String, CaseIterable, Codable {
    case small = "小"
    case medium = "中"
    case large = "大"
    
    var emoji: String {
        switch self {
        case .small: return "💩"
        case .medium: return "💩💩"
        case .large: return "💩💩💩"
        }
    }
}

// 单次拉屎记录
struct PoopRecord: Identifiable, Codable {
    var id: UUID
    var date: Date
    var size: PoopSize
    var notes: String
    
    init(id: UUID = UUID(), date: Date = Date(), size: PoopSize = .medium, notes: String = "") {
        self.id = id
        self.date = date
        self.size = size
        self.notes = notes
    }
}

// 每日汇总记录
struct DailyRecord: Identifiable {
    var id: Date { date }
    var date: Date
    var records: [PoopRecord]
    var totalCount: Int { records.count }
    var averageSize: PoopSize {
        if records.isEmpty { return .medium }
        let sizes = records.map { $0.size }
        let largeCount = sizes.filter { $0 == .large }.count
        let mediumCount = sizes.filter { $0 == .medium }.count
        let smallCount = sizes.filter { $0 == .small }.count
        
        if largeCount >= mediumCount && largeCount >= smallCount { return .large }
        if mediumCount >= smallCount { return .medium }
        return .small
    }
}

