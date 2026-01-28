//
//  InputMethodManager.swift
//  Typist
//
//  输入法管理器 - 使用 Carbon API 操作系统输入法
//

import Carbon
import Foundation

/// 输入法数据模型
struct InputSource: Identifiable, Hashable {
    let id: String   // 输入法唯一标识符，如 "com.apple.keylayout.ABC"
    let name: String // 输入法显示名称，如 "ABC"
}

/// 输入法管理器（单例）
/// 负责获取系统可用输入法列表、当前输入法、切换输入法
final class InputMethodManager {
    static let shared = InputMethodManager()

    private init() {}

    /// 获取系统中所有可选择的键盘输入法
    /// - Returns: 输入法列表
    func getAvailableInputSources() -> [InputSource] {
        var sources: [InputSource] = []

        // 筛选条件：键盘输入法 + 可选择
        let conditions = [
            kTISPropertyInputSourceCategory: kTISCategoryKeyboardInputSource,
            kTISPropertyInputSourceIsSelectCapable: true
        ] as CFDictionary

        guard let sourceList = TISCreateInputSourceList(conditions, false)?.takeRetainedValue() as? [TISInputSource] else {
            return sources
        }

        for source in sourceList {
            if let idRef = TISGetInputSourceProperty(source, kTISPropertyInputSourceID),
               let nameRef = TISGetInputSourceProperty(source, kTISPropertyLocalizedName) {
                let id = Unmanaged<CFString>.fromOpaque(idRef).takeUnretainedValue() as String
                let name = Unmanaged<CFString>.fromOpaque(nameRef).takeUnretainedValue() as String
                sources.append(InputSource(id: id, name: name))
            }
        }

        return sources
    }

    /// 获取当前激活的输入法 ID
    /// - Returns: 输入法 ID，获取失败返回 nil
    func getCurrentInputSource() -> String? {
        guard let source = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue(),
              let idRef = TISGetInputSourceProperty(source, kTISPropertyInputSourceID) else {
            return nil
        }
        return Unmanaged<CFString>.fromOpaque(idRef).takeUnretainedValue() as String
    }

    /// 切换到指定输入法
    /// - Parameter id: 目标输入法 ID
    func switchToInputSource(id: String) {
        let conditions = [kTISPropertyInputSourceID: id] as CFDictionary

        guard let sourceList = TISCreateInputSourceList(conditions, false)?.takeRetainedValue() as? [TISInputSource],
              let source = sourceList.first else {
            return
        }

        TISSelectInputSource(source)
    }
}
