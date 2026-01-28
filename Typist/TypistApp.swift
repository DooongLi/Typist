//
//  TypistApp.swift
//  Typist
//
//  自动切换输入法 - 主入口
//  根据当前激活的应用自动切换到预设的输入法
//

import SwiftUI

@main
struct TypistApp: App {
    /// 应用切换观察者
    @StateObject private var appObserver = AppObserver()

    var body: some Scene {
        // 菜单栏应用，显示键盘图标
        MenuBarExtra("Typist", systemImage: "keyboard") {
            ContentView()
                .environmentObject(appObserver)
                .environmentObject(SettingsManager.shared)
        }
        .menuBarExtraStyle(.window)
    }
}
