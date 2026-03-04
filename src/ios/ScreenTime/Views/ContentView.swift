//
//  ContentView.swift
//  ScreenTime
//
//  Created by AIagent on 2026-03-03.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            UsageView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("使用情况")
                }
                .tag(0)
            
            LimitsView()
                .tabItem {
                    Image(systemName: "hourglass")
                    Text("限额")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("设置")
                }
                .tag(2)
        }
        .accentColor(Color(hex: "#6C5CE7"))
    }
}

struct UsageView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("今日使用")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("4 小时 32 分钟")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Color(hex: "#6C5CE7"))
                
                AppUsageRow(appName: "微信", time: "2 小时", color: "#07C160")
                AppUsageRow(appName: "抖音", time: "1 小时", color: "#000000")
                AppUsageRow(appName: "微博", time: "32 分钟", color: "#E6162D")
                
                Spacer()
            }
            .padding()
            .navigationTitle("使用情况")
        }
    }
}

struct AppUsageRow: View {
    let appName: String
    let time: String
    let color: String
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color(hex: color))
                .frame(width: 40, height: 40)
            
            Text(appName)
                .font(.system(size: 16))
            
            Spacer()
            
            Text(time)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct LimitsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("应用限额")) {
                    LimitRow(appName: "社交媒体", limit: "1 小时", used: "45 分钟")
                    LimitRow(appName: "娱乐", limit: "30 分钟", used: "20 分钟")
                }
            }
            .navigationTitle("限额")
        }
    }
}

struct LimitRow: View {
    let appName: String
    let limit: String
    let used: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(appName)
                    .font(.system(size: 16))
                Text("\(used)/\(limit)")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            ProgressView(value: 0.5)
                .frame(width: 100)
        }
        .padding(.vertical, 8)
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("关于")) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
}
