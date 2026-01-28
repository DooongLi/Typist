//
//  SettingsManager.swift
//  Typist
//
//  配置管理器 - 存储和管理应用与输入法的映射关系
//

import Foundation

/// 配置管理器（单例）
/// 使用 UserDefaults 持久化存储应用-输入法映射
final class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    private let storageKey = "AppInputMethodMappings"
    private let countKey = "SwitchCount"

    /// 应用-输入法映射表 [bundleId: inputSourceId]
    @Published var mappings: [String: String] = [:]
    /// 切换次数统计
    @Published var switchCount: Int = 0

    init() {
        loadMappings()
        switchCount = UserDefaults.standard.integer(forKey: countKey)
    }

    /// 从 UserDefaults 加载配置
    private func loadMappings() {
        if let saved = UserDefaults.standard.dictionary(forKey: storageKey) as? [String: String] {
            mappings = saved
        }
    }

    /// 保存配置到 UserDefaults
    private func saveMappings() {
        UserDefaults.standard.set(mappings, forKey: storageKey)
    }

    /// 设置或删除应用的输入法映射
    /// - Parameters:
    ///   - bundleId: 应用 Bundle ID
    ///   - inputSourceId: 输入法 ID，传 nil 表示删除映射
    func setInputMethod(for bundleId: String, inputSourceId: String?) {
        if let id = inputSourceId {
            mappings[bundleId] = id
        } else {
            mappings.removeValue(forKey: bundleId)
        }
        saveMappings()
    }

    /// 获取应用对应的输入法 ID
    /// - Parameter bundleId: 应用 Bundle ID
    /// - Returns: 输入法 ID，未配置返回 nil
    func getInputMethod(for bundleId: String) -> String? {
        mappings[bundleId]
    }

    /// 根据配置切换应用对应的输入法
    /// - Parameter bundleId: 应用 Bundle ID
    func switchInputMethodForApp(bundleId: String) {
        guard let inputSourceId = mappings[bundleId] else { return }
        InputMethodManager.shared.switchToInputSource(id: inputSourceId)
        switchCount += 1
        UserDefaults.standard.set(switchCount, forKey: countKey)
    }
}
