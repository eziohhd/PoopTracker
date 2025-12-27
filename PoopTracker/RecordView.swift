//
//  RecordView.swift
//  PoopTracker
//
//  快速记录界面
//

import SwiftUI

struct RecordView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedDate = Date()
    @State private var selectedSize: PoopSize = .medium
    @State private var notes: String = ""
    @State private var showingSuccessAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("日期时间")) {
                    DatePicker("选择日期", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(header: Text("大小")) {
                    Picker("大小", selection: $selectedSize) {
                        ForEach(PoopSize.allCases, id: \.self) { size in
                            HStack {
                                Text(size.emoji)
                                Text(size.rawValue)
                            }
                            .tag(size)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("备注（可选）")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                Section {
                    Button(action: saveRecord) {
                        HStack {
                            Spacer()
                            Text("保存记录")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(false)
                }
            }
            .navigationTitle("添加记录")
            .alert("记录已保存", isPresented: $showingSuccessAlert) {
                Button("确定", role: .cancel) {
                    resetForm()
                }
            } message: {
                Text("您的拉屎记录已成功保存")
            }
        }
    }
    
    private func saveRecord() {
        let record = PoopRecord(
            date: selectedDate,
            size: selectedSize,
            notes: notes
        )
        dataManager.addRecord(record)
        showingSuccessAlert = true
    }
    
    private func resetForm() {
        selectedDate = Date()
        selectedSize = .medium
        notes = ""
    }
}

// 记录编辑视图（用于从日历视图编辑）
struct RecordEditView: View {
    @Environment(\.dismiss) var dismiss
    let record: PoopRecord
    let onSave: (PoopRecord) -> Void
    
    @State private var selectedDate: Date
    @State private var selectedSize: PoopSize
    @State private var notes: String
    
    init(record: PoopRecord, onSave: @escaping (PoopRecord) -> Void) {
        self.record = record
        self.onSave = onSave
        _selectedDate = State(initialValue: record.date)
        _selectedSize = State(initialValue: record.size)
        _notes = State(initialValue: record.notes)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("日期时间")) {
                    DatePicker("选择日期", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(header: Text("大小")) {
                    Picker("大小", selection: $selectedSize) {
                        ForEach(PoopSize.allCases, id: \.self) { size in
                            HStack {
                                Text(size.emoji)
                                Text(size.rawValue)
                            }
                            .tag(size)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("备注（可选）")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                Section {
                    Button(action: save) {
                        HStack {
                            Spacer()
                            Text("保存")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("编辑记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func save() {
        var updatedRecord = record
        updatedRecord.date = selectedDate
        updatedRecord.size = selectedSize
        updatedRecord.notes = notes
        onSave(updatedRecord)
        dismiss()
    }
}

