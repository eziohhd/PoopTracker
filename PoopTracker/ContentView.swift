//
//  ContentView.swift
//  PoopTracker
//
//  主界面
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CalendarView()
                .tabItem {
                    Label("日历", systemImage: "calendar")
                }
                .tag(0)
            
            RecordView()
                .tabItem {
                    Label("记录", systemImage: "plus.circle")
                }
                .tag(1)
            
            MonthlySummaryView()
                .tabItem {
                    Label("统计", systemImage: "chart.bar")
                }
                .tag(2)
        }
    }
}

