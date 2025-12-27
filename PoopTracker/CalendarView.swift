//
//  CalendarView.swift
//  PoopTracker
//
//  日历视图：显示每日拉屎记录
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedDate = Date()
    @State private var showingRecordSheet = false
    @State private var editingRecord: PoopRecord?
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 月份选择器
                monthPicker
                
                // 日历网格
                calendarGrid
                
                // 选中日期的记录列表
                selectedDateRecords
            }
            .navigationTitle("拉屎记录")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingRecordSheet) {
                RecordEditView(record: editingRecord ?? PoopRecord(date: selectedDate), onSave: { record in
                    if editingRecord != nil {
                        dataManager.updateRecord(record)
                    } else {
                        dataManager.addRecord(record)
                    }
                    editingRecord = nil
                })
            }
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
            
            Text(dateFormatter.string(from: selectedDate))
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
    }
    
    private var calendarGrid: some View {
        let days = getDaysInMonth()
        let firstWeekday = getFirstWeekdayOfMonth()
        
        VStack(spacing: 8) {
            // 星期标题
            HStack(spacing: 0) {
                ForEach(["日", "一", "二", "三", "四", "五", "六"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // 日期网格
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                // 填充空白
                ForEach(0..<firstWeekday, id: \.self) { _ in
                    Color.clear
                        .frame(height: 50)
                }
                
                // 日期
                ForEach(days, id: \.self) { date in
                    DayCell(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isToday: calendar.isDateInToday(date),
                        dailyRecord: dataManager.getDailyRecord(for: date),
                        onTap: {
                            selectedDate = date
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
    
    private var selectedDateRecords: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
            
            let dayRecords = dataManager.getRecords(for: selectedDate)
            let dayFormatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM月dd日"
                return formatter
            }()
            
            HStack {
                Text(dayFormatter.string(from: selectedDate))
                    .font(.headline)
                    .padding()
                
                Spacer()
                
                Button(action: {
                    editingRecord = nil
                    showingRecordSheet = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .padding()
                }
            }
            
            if dayRecords.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("今天还没有记录")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                List {
                    ForEach(dayRecords) { record in
                        RecordRow(record: record)
                            .onTapGesture {
                                editingRecord = record
                                showingRecordSheet = true
                            }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            dataManager.deleteRecord(dayRecords[index])
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
    
    private func getDaysInMonth() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate) else {
            return []
        }
        
        var days: [Date] = []
        var currentDate = monthInterval.start
        
        while currentDate < monthInterval.end {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return days
    }
    
    private func getFirstWeekdayOfMonth() -> Int {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate) else {
            return 0
        }
        return calendar.component(.weekday, from: monthInterval.start) - 1
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
    }
}

// 日期单元格
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let dailyRecord: DailyRecord?
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                    .foregroundColor(isSelected ? .white : (isToday ? .blue : .primary))
                
                if let record = dailyRecord {
                    HStack(spacing: 2) {
                        Text(record.averageSize.emoji)
                            .font(.caption2)
                        Text("\(record.totalCount)")
                            .font(.caption2)
                            .fontWeight(.semibold)
                    }
                }
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 记录行
struct RecordRow: View {
    let record: PoopRecord
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var body: some View {
        HStack {
            Text(record.size.emoji)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(record.size.rawValue)
                    .font(.headline)
                
                if !record.notes.isEmpty {
                    Text(record.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            Text(timeFormatter.string(from: record.date))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

