# Typist (自动切换输入法)

一款 macOS 菜单栏应用，根据当前激活的应用自动切换到预设的输入法。

## 功能特性

- 监听应用切换事件，自动切换输入法
- 为每个应用单独配置默认输入法
- 菜单栏常驻，轻量无打扰
- 原生 SwiftUI 界面，支持深色模式
- 配置持久化存储

## 系统要求

- macOS 13.0 (Ventura) 或更高版本
- Xcode 15.0 或更高版本（用于编译）

## 安装方式

### 方式一：直接使用

将 `Typist.app` 复制到 `/Applications` 目录：

```bash
cp -R Typist.app /Applications/
```

### 方式二：从源码编译

1. 克隆项目
2. 使用 Xcode 打开项目：
```bash
open Typist.xcodeproj
```

3. 或使用命令行编译：
```bash
xcodebuild -project Typist.xcodeproj \
           -scheme Typist \
           -configuration Release \
           build
```

## 使用方法

1. 启动应用后，菜单栏会出现键盘图标
2. 点击图标打开配置界面
3. 在「添加规则」中选择应用和对应的输入法
4. 点击「添加规则」保存配置
5. 切换到已配置的应用时，输入法会自动切换

## 项目结构

```
├── Typist.xcodeproj        # Xcode 项目文件
├── Typist.app              # 编译后的应用
└── Typist/
    ├── TypistApp.swift             # 应用入口
    ├── InputMethodManager.swift    # 输入法管理（Carbon API）
    ├── AppObserver.swift           # 应用切换监听（NSWorkspace）
    ├── SettingsManager.swift       # 配置持久化（UserDefaults）
    ├── ContentView.swift           # SwiftUI 界面
    ├── Info.plist                  # 应用配置
    └── Assets.xcassets/            # 应用图标资源
```

## 核心技术

| 模块 | 技术 | 说明 |
|------|------|------|
| 界面 | SwiftUI + MenuBarExtra | macOS 13+ 原生菜单栏 API |
| 输入法 | Carbon (TIS*) | 系统输入法切换 API |
| 监听 | NSWorkspace | 应用激活通知 |
| 存储 | UserDefaults | 轻量配置持久化 |

## 开机自启动

系统偏好设置 → 通用 → 登录项 → 添加 `Typist`

## 许可证

MIT License
