//
//  AppObserver.swift
//  Typist
//
//  应用切换观察者 - 监听前台应用变化并触发输入法切换
//

import AppKit
import Combine

/// 应用切换观察者
/// 监听 NSWorkspace 的应用激活通知，自动切换输入法
final class AppObserver: ObservableObject {
    /// 当前前台应用名称
    @Published var currentApp: String = ""
    /// 当前前台应用 Bundle ID
    @Published var currentAppBundleId: String = ""

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupObserver()
        updateCurrentApp()
    }

    /// 设置应用切换监听
    private func setupObserver() {
        NSWorkspace.shared.notificationCenter
            .publisher(for: NSWorkspace.didActivateApplicationNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                self?.handleAppActivation(notification)
            }
            .store(in: &cancellables)
    }

    /// 处理应用激活事件
    /// - Parameter notification: 系统通知
    private func handleAppActivation(_ notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else {
            return
        }

        let bundleId = app.bundleIdentifier ?? ""
        let appName = app.localizedName ?? ""

        currentApp = appName
        currentAppBundleId = bundleId

        // 根据配置切换输入法
        if !bundleId.isEmpty {
            SettingsManager.shared.switchInputMethodForApp(bundleId: bundleId)
        }
    }

    /// 更新当前前台应用信息
    private func updateCurrentApp() {
        if let app = NSWorkspace.shared.frontmostApplication {
            currentApp = app.localizedName ?? ""
            currentAppBundleId = app.bundleIdentifier ?? ""
        }
    }

    /// 获取当前运行中的常规应用列表（排除后台服务）
    /// - Returns: 应用名称和 Bundle ID 的元组数组，按名称排序
    func getRunningApps() -> [(name: String, bundleId: String)] {
        NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular }
            .compactMap { app in
                guard let name = app.localizedName, let bundleId = app.bundleIdentifier else {
                    return nil
                }
                return (name: name, bundleId: bundleId)
            }
            .sorted { $0.name < $1.name }
    }
}
