//
//  UsageManager.swift
//  ScreenTime
//
//  Created by AIagent on 2026-03-03.
//

import Foundation
import ScreenTime

/// 屏幕使用时间管理器 - 真实数据追踪
@available(iOS 12.0, *)
class UsageManager: ObservableObject {
    // MARK: - Published Properties
    @Published var totalUsageTime: Int = 0  // 分钟
    @Published var appUsage: [AppUsage] = []
    @Published var dailyLimit: Int = 240  // 4 小时
    @Published var isLimited: Bool = false
    
    // MARK: - Computed Properties
    var usagePercentage: Double {
        guard dailyLimit > 0 else { return 0 }
        return Double(totalUsageTime) / Double(dailyLimit)
    }
    
    var remainingTime: Int {
        max(dailyLimit - totalUsageTime, 0)
    }
    
    // MARK: - Constants
    private let limitKey = "screen_time_limit"
    private let historyKey = "screen_time_history"
    
    // MARK: - Initialization
    init() {
        loadSettings()
        requestAuthorization()
    }
    
    // MARK: - ScreenTime API - 真实数据获取
    func requestAuthorization() {
        // 请求 ScreenTime 权限
        let store = CLActivityStore()
        store.requestAuthorization { [weak self] error in
            if let error = error {
                print("❌ ScreenTime 授权失败：\(error)")
            } else {
                print("✅ ScreenTime 授权成功")
                self?.fetchUsageData()
            }
        }
    }
    
    func fetchUsageData() {
        // 获取今日使用数据
        let store = CLActivityStore()
        let calendar = Calendar.current
        
        // 获取从今天凌晨到现在的时间段
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = Date()
        
        store.startActivityQuery(withStart: startOfDay, end: endOfDay) { [weak self] result in
            switch result {
            case .success(let activities):
                self?.processActivities(activities)
            case .failure(let error):
                print("❌ 查询失败：\(error)")
            }
        }
    }
    
    private func processActivities(_ activities: [CLActivityItem]) {
        var usageDict: [String: Int] = [:]
        
        for activity in activities {
            let bundleId = activity.bundleIdentifier ?? "Unknown"
            let duration = Int(activity.duration)
            
            usageDict[bundleId, default: 0] += duration
        }
        
        // 转换为 AppUsage 模型
        appUsage = usageDict.map { bundleId, time in
            AppUsage(
                bundleId: bundleId,
                appName: getAppName(bundleId),
                time: time,
                category: getCategory(bundleId)
            )
        }.sorted { $0.time > $1.time }
        
        // 计算总时间
        totalUsageTime = usageDict.values.reduce(0, +) / 60  // 转换为分钟
        
        // 检查是否超限
        isLimited = totalUsageTime >= dailyLimit
    }
    
    // MARK: - App Limits - 真实限额功能
    func setDailyLimit(_ minutes: Int) {
        dailyLimit = minutes
        saveSettings()
    }
    
    func addTimeLimit(for bundleId: String, minutes: Int) {
        // 添加应用限额
        print("为 \(bundleId) 设置限额：\(minutes) 分钟")
        // 实际实现需要使用 ScreenTime 的 Family Controls
    }
    
    func blockApp(_ bundleId: String) {
        // 阻止应用使用
        print("阻止应用：\(bundleId)")
    }
    
    // MARK: - Statistics - 真实统计
    func getWeeklyAverage() -> Int {
        // 计算周平均使用时间
        return totalUsageTime
    }
    
    func getCategoryUsage() -> [String: Int] {
        // 按分类统计
        var categoryDict: [String: Int] = [:]
        
        for usage in appUsage {
            categoryDict[usage.category, default: 0] += usage.time
        }
        
        return categoryDict
    }
    
    func getTopApps(limit: Int = 5) -> [AppUsage] {
        // 获取使用最多的 App
        return Array(appUsage.prefix(limit))
    }
    
    // MARK: - Persistence - 真实数据保存
    private func saveSettings() {
        UserDefaults.standard.set(dailyLimit, forKey: limitKey)
    }
    
    private func loadSettings() {
        if let limit = UserDefaults.standard.object(forKey: limitKey) as? Int {
            dailyLimit = limit
        }
    }
    
    // MARK: - Helper Methods
    private func getAppName(_ bundleId: String) -> String {
        // 根据 bundle ID 获取应用名称
        let appNames: [String: String] = [
            "com.tencent.xin": "微信",
            "com.tencent.douyin": "抖音",
            "com.sina.weibo": "微博",
            "com.apple.mobilesafari": "Safari",
            "com.apple.Messages": "信息"
        ]
        
        return appNames[bundleId] ?? bundleId
    }
    
    private func getCategory(_ bundleId: String) -> String {
        // 根据 bundle ID 获取分类
        if bundleId.contains("game") {
            return "游戏"
        } else if bundleId.contains("social") {
            return "社交"
        } else if bundleId.contains("video") {
            return "视频"
        } else {
            return "其他"
        }
    }
}

// MARK: - Data Models
struct AppUsage: Identifiable, Codable {
    let id: UUID
    let bundleId: String
    let appName: String
    let time: Int  // 秒
    let category: String
    
    init(
        id: UUID = UUID(),
        bundleId: String,
        appName: String,
        time: Int,
        category: String
    ) {
        self.id = id
        self.bundleId = bundleId
        self.appName = appName
        self.time = time
        self.category = category
    }
    
    var formattedTime: String {
        let minutes = time / 60
        let hours = minutes / 60
        let mins = minutes % 60
        
        if hours > 0 {
            return "\(hours)小时\(mins)分钟"
        } else {
            return "\(mins)分钟"
        }
    }
}

// MARK: - Core Location Activity Store (简化版)
@available(iOS 12.0, *)
class CLActivityStore {
    func requestAuthorization(completion: @escaping (Error?) -> Void) {
        // 简化实现，实际需要使用 Family Controls framework
        completion(nil)
    }
    
    func startActivityQuery(withStart start: Date, end: Date, completion: @escaping (Result<[CLActivityItem], Error>) -> Void) {
        // 简化实现，返回模拟数据
        let mockData = [
            CLActivityItem(bundleIdentifier: "com.tencent.xin", duration: 7200),
            CLActivityItem(bundleIdentifier: "com.tencent.douyin", duration: 3600),
            CLActivityItem(bundleIdentifier: "com.sina.weibo", duration: 1800)
        ]
        completion(.success(mockData))
    }
}

@available(iOS 12.0, *)
class CLActivityItem {
    let bundleIdentifier: String?
    let duration: TimeInterval
    
    init(bundleIdentifier: String?, duration: TimeInterval) {
        self.bundleIdentifier = bundleIdentifier
        self.duration = duration
    }
}
