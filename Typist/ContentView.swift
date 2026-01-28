//
//  ContentView.swift
//  Typist
//
//  主界面 - 菜单栏弹出窗口的 SwiftUI 视图
//

import SwiftUI
import AppKit

// MARK: - 主视图

struct ContentView: View {
    @EnvironmentObject var appObserver: AppObserver
    @EnvironmentObject var settingsManager: SettingsManager

    @State private var selectedApp: String = ""
    @State private var selectedInputSource: String = ""
    @State private var hoveredRule: String?
    @State private var isRulesExpanded: Bool = true

    private let inputMethodManager = InputMethodManager.shared

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    statusSection
                    Divider()
                    addRuleSection
                    Divider()
                    rulesSection
                }
                .padding(16)
            }
            Divider()
            footerView
        }
        .frame(width: 320)
        .background(.background)
        .onChange(of: selectedApp) { newValue in
            selectedInputSource = settingsManager.getInputMethod(for: newValue) ?? ""
        }
    }

    // MARK: - 头部

    private var headerView: some View {
        HStack {
            Image(systemName: "keyboard.fill")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("自动切换输入法")
                .font(.headline)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    // MARK: - 当前状态

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("当前状态", systemImage: "info.circle.fill")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                StatusItem(icon: "app.fill", title: "应用",
                           value: appObserver.currentApp.isEmpty ? "无" : appObserver.currentApp)
                Divider().frame(height: 30)
                StatusItem(icon: "character.cursor.ibeam", title: "输入法",
                           value: currentInputSourceName)
            }
            .padding(12)
            .background(.quaternary.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    // MARK: - 添加规则

    private var addRuleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("添加规则", systemImage: "plus.circle.fill")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Picker(selection: $selectedApp) {
                    Text("选择应用...").tag("")
                    ForEach(appObserver.getRunningApps(), id: \.bundleId) { app in
                        Text(app.name).tag(app.bundleId)
                    }
                } label: {
                    Text("应用").frame(width: 50, alignment: .leading)
                }

                Picker(selection: $selectedInputSource) {
                    Text("选择输入法...").tag("")
                    ForEach(inputMethodManager.getAvailableInputSources()) { source in
                        Text(source.name).tag(source.id)
                    }
                } label: {
                    Text("输入法").frame(width: 50, alignment: .leading)
                }
            }

            Button(action: saveRule) {
                Text("添加规则").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
            .disabled(selectedApp.isEmpty || selectedInputSource.isEmpty)
        }
    }

    // MARK: - 规则列表（可折叠）

    private var rulesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 折叠头部
            HStack {
                Label("已配置规则", systemImage: "list.bullet")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(settingsManager.mappings.count)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.quaternary)
                    .clipShape(Capsule())
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .rotationEffect(.degrees(isRulesExpanded ? 90 : 0))
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isRulesExpanded.toggle()
                }
            }

            // 规则内容
            if isRulesExpanded {
                VStack(spacing: 4) {
                    if settingsManager.mappings.isEmpty {
                        emptyRulesView
                    } else {
                        ForEach(Array(settingsManager.mappings.keys.sorted()), id: \.self) { bundleId in
                            if let inputId = settingsManager.mappings[bundleId] {
                                RuleRow(
                                    bundleId: bundleId,
                                    appName: appName(for: bundleId),
                                    inputName: inputSourceName(for: inputId),
                                    isHovered: hoveredRule == bundleId,
                                    onDelete: { deleteRule(bundleId: bundleId) }
                                )
                                .onHover { hoveredRule = $0 ? bundleId : nil }
                            }
                        }
                    }
                }
                .clipped()
                .transition(.opacity)
            }
        }
    }

    private var emptyRulesView: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "tray")
                    .font(.largeTitle)
                    .foregroundStyle(.tertiary)
                Text("暂无规则")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 20)
            Spacer()
        }
    }

    // MARK: - 底部

    private var footerView: some View {
        HStack {
            Button(action: { NSApplication.shared.terminate(nil) }) {
                Label("退出", systemImage: "power")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            Spacer()
            Label("\(settingsManager.switchCount) 次切换", systemImage: "arrow.triangle.2.circlepath")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    // MARK: - Actions

    private func saveRule() {
        guard !selectedApp.isEmpty, !selectedInputSource.isEmpty else { return }
        withAnimation(.easeOut(duration: 0.2)) {
            settingsManager.setInputMethod(for: selectedApp, inputSourceId: selectedInputSource)
        }
        selectedApp = ""
        selectedInputSource = ""
    }

    private func deleteRule(bundleId: String) {
        withAnimation(.easeOut(duration: 0.2)) {
            settingsManager.setInputMethod(for: bundleId, inputSourceId: nil)
        }
    }

    // MARK: - Helpers

    private var currentInputSourceName: String {
        if let id = inputMethodManager.getCurrentInputSource() {
            return inputSourceName(for: id)
        }
        return "未知"
    }

    private func inputSourceName(for id: String) -> String {
        inputMethodManager.getAvailableInputSources()
            .first { $0.id == id }?.name ?? id.components(separatedBy: ".").last ?? id
    }

    private func appName(for bundleId: String) -> String {
        appObserver.getRunningApps()
            .first { $0.bundleId == bundleId }?.name ?? bundleId.components(separatedBy: ".").last ?? bundleId
    }
}

// MARK: - 子视图

/// 状态项
struct StatusItem: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: icon)
                .font(.caption)
                .foregroundStyle(.tertiary)
            Text(value)
                .font(.subheadline.weight(.medium))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// 规则行
struct RuleRow: View {
    let bundleId: String
    let appName: String
    let inputName: String
    let isHovered: Bool
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            AppIconView(bundleId: bundleId)
                .frame(width: 24, height: 24)
            Text(appName)
                .font(.subheadline)
                .lineLimit(1)
            Image(systemName: "arrow.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
            Text(inputName)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
            .opacity(isHovered ? 1 : 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(isHovered ? Color.primary.opacity(0.05) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

/// 应用图标
struct AppIconView: View {
    let bundleId: String

    var body: some View {
        if let icon = getAppIcon() {
            Image(nsImage: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Image(systemName: "app.fill")
                .foregroundStyle(.blue)
        }
    }

    private func getAppIcon() -> NSImage? {
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) else {
            return nil
        }
        return NSWorkspace.shared.icon(forFile: appURL.path)
    }
}
