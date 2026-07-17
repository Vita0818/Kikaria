# ARCHITECTURE

## 外部依赖优先与禁止功能兜底（Vitemis 强制规则）

本项目继承 `/Users/vita/Vitemis/docs/DEPENDENCY_POLICY.md`。本节是强制约束，不是建议。

- 当用户指定、仓库已经采用，或经许可证、provenance、安全与平台审查可采用的外部依赖提供同等能力时，必须直接集成该依赖的官方 API 或官方扩展点。
- 不得自行重写同等能力，不得新增替代 adapter、shim、compatibility layer、wrapper、proxy、facade、协议翻译层、parallel backend、preview backend、shadow implementation 或“先兜底、以后再换”的实现。
- 本地代码只允许保留官方 API 必需的最薄生命周期、类型、权限、配置和 bundle 接线；不得重新实现、解释、扩展或替代依赖的核心能力。
- exact 依赖因版本、构建、签名、许可证、平台、安全或官方 API 限制无法接入时，必须停止该能力、明确失败、报告 blocker 并请求用户决定；不得静默降级、切换 legacy/另一 provider/backend、使用 cache/mock/简化路径或继续交付不完整替代实现。
- 现有 fallback、adapter 或重复实现不构成先例，后续不得扩展。安全 fail-closed 与明确要求的旧数据解码/迁移不是功能兜底，但必须保持最窄范围，不能演化成备用产品实现。
- 只有用户针对 exact 依赖、exact 范围和退出条件作出的新明文决定才能例外。

最后自查日期：2026-07-04

## 总体架构

Kikaria 是本地优先的 SwiftUI 学习/背诵 App。当前工程包含：

- 主 iOS App target：`Kikaria`
- Widget Extension target：`KikariaWidget`
- macOS App target：`KikariaMac`
- macOS 单元测试和 UI 测试 target

运行时没有发现服务器、账号、远程同步或业务网络请求。数据主要保存在 `UserDefaults.standard` 的 Codable JSON 中；Widget 通过 App Group `UserDefaults` 和 standard `UserDefaults` 的双写/双读机制拿到学习概览。

SwiftPM 依赖当前只有 `SwiftMath`，用于本地 LaTeX 渲染。它是构建期依赖，不是运行时网络服务。

## 模块边界

- App 入口层：`KikariaApp.swift` 和 `KikariaMacApp.swift` 负责启动 SwiftUI scene。
- 主 UI/状态层：`ContentView.swift` 持有大部分 `@State`、导航路由、页面组合、设置、Preset 管理、复习流程、通知调度和持久化。
- 数据模型层：`KnowledgePoint.swift`、`StudyTracking.swift` 定义知识点、预设、学习活动、Widget snapshot 等 Codable 数据。
- 数学渲染层：`KikariaLatexParser.swift`、`LatexToken.swift`、`KikariaMathText.swift`、`KikariaMathFormulaView.swift` 负责识别 `$...$` / `$$...$$` 并用 SwiftMath 渲染，失败时 fallback。
- 自适应 UI 支撑层：`KikariaAdaptiveLayout.swift`、`KikariaTypography.swift` 提供尺寸指标、字体混排和 App/macOS 侧轻量本地化文案映射。
- Widget 层：`KikariaWidget.swift` 复制 Widget snapshot 数据结构并独立渲染三种 Widget family。
- macOS 包装层：`KikariaMacRootView.swift` 复用 `ContentView()`，只额外处理窗口 chrome。

## 主要数据模型

- `KnowledgePoint`
  - 字段包括 `id`、`title`、`tags`、`hint`、`content`、`isReinforced`、`reinforcementCount`、`lastReinforcedAt`、`isMastered`、`createdAt`、`updatedAt`。
  - `reinforcementCount > 0` 才是重点集锦真实语义，`isReinforced` 是兼容编码字段。

- `KnowledgePreset`
  - 字段包括 `id`、`name`、`subtitle`、`description`、`category`、`markdownText`、`isBuiltIn`。
  - 内置 preset 来自 App bundle 的 `Presets/*.md`。
  - `builtInSeedVersion = 4` 同时被 `KikariaAppState.currentSchemaVersion` 使用。

- `PresetStudyState`
  - 每个 preset 的独立学习状态。
  - 保存知识点、Markdown 文本、选中标签、每日复习计数、活动记录、每日目标、倒数日期、本地通知开关、通知时间和危险线百分比。

- `KikariaAppState`
  - 全局存档结构，`storageKey = "kikaria.appStateJSON"`。
  - 保存 presets、presetStates、currentPresetID、userProfile、首次设置/引导状态。

- `StudyActivityRecord`
  - 记录查看提示、查看答案、加入/移出重点、加入/移出已掌握等行为。

- `WidgetSnapshot`
  - App 侧定义在 `StudyTracking.swift`，Widget 侧在 `KikariaWidget.swift` 有私有镜像结构。
  - 字段包括当前预设名、今日新增掌握、总掌握、每日目标、倒数天数、今日查看答案/提示、随机知识点预览、更新时间。

## 关键业务链路

### 启动与状态恢复

1. `KikariaApp` 设置通知 delegate，然后加载 `ContentView()`。
2. `ContentView.onAppear` 调用 `loadInitialPresetStateIfNeeded()`。
3. `loadAppState()` 优先读取 `UserDefaults.standard` 的 `kikaria.appStateJSON`。
4. 若新存档解码失败，尝试 legacy `presetLibraryJSON` 和 legacy `hasCompletedOnboarding`。
5. 若没有可用存档，回退到 `KnowledgePreset.all` 并为每个 preset 解析 Markdown 生成初始状态。
6. `restorePresetState()` 将当前 preset 的状态恢复到 `ContentView` 的 `@State`，随后调度通知并刷新 Widget snapshot。

### Preset 与 Markdown 导入

1. 内置 preset 通过 `Bundle.main.urls(forResourcesWithExtension: "md", subdirectory: "Presets")` 读取。
2. 自定义 preset 可通过 `.md` / `.txt` file importer 或粘贴 Markdown 创建。
3. `KnowledgePoint.parseMarkdown()` 按单独一行 `---` 分块；每块必须有 `#` 标题、`hint:`、`content:`，tags 行可用英文或中文逗号分隔。
4. 编辑知识点后通过 `KnowledgePoint.markdownText(from:)` 重新生成该 preset 的 Markdown 文本。
5. 删除知识点会同步删除对应 `dailyReviewRecords` 和 `activityRecords`，并过滤失效 tag。

### 复习与学习记录

1. `ScopeSelectionView` 维护 `selectedTags`；未选标签时普通复习使用全部知识点。
2. `ReviewView` 根据 `ReviewMode` 计算匹配知识点：
   - normal：全部或选中 tag。
   - reinforcement：`reinforcementCount > 0`。
   - mastered：`isMastered == true`。
3. Review queue 会 shuffle，并在切换知识点时重置提示/答案展示状态。
4. `revealHint()` 记录 `.viewedHint`。
5. `revealContent()` 记录 `.reviewedAnswer` 并更新 `dailyReviewRecords`。
6. 加入重点调用 `KnowledgePoint.addReinforcement()`；标记已掌握会清空重点状态；相关动作都记录 `StudyActivityRecord`。
7. `ContentView` 通过 `onChange` 延迟保存当前 preset 状态，必要时刷新 Widget。

### Widget 数据流

1. App 侧 `updateWidgetSnapshot()` 生成 `WidgetSnapshot`。
2. `WidgetDataStore.save(_:)` 写入 App Group `UserDefaults(suiteName: "group.com.vita0818.kikaria")` 和 `UserDefaults.standard`，key 为 `kikaria.widgetSnapshot`。
3. 写入后调用 `WidgetCenter.shared.reloadAllTimelines()`。
4. Widget 侧优先读 App Group，失败后读 standard，仍失败则展示 placeholder。
5. Widget timeline 每 30 分钟刷新一次，支持 `systemSmall`、`systemMedium`、`systemLarge`。

### 本地通知

1. 通知由 `KikariaNotificationManager` 管理。
2. 每个 preset 使用 identifier：`kikaria.studyProgressWarning.<presetID>`。
3. 开启通知时请求本地通知权限。
4. `evaluateStudyProgressWarning()` 根据知识点总数、已掌握数量、倒数开始/结束日期、危险线百分比判断是否安排提醒。
5. 当前实现是本地通知，不是远程推送。

### 数学公式渲染

1. `KikariaLatexParser` 识别 inline `$...$` 和 block `$$...$$`。
2. 代码块和行内反引号内容不会被当作数学公式。
3. `KikariaMathFormulaView` 用 SwiftMath 渲染；渲染失败时展示可读 fallback 或原始源码。
4. Markdown 导入、编辑和导出保留原始 LaTeX 源码。

### v3.1 本地化文案

1. App/macOS 侧通过 `KikariaLocalization` 判断 `Locale.preferredLanguages.first`：首选语言为中文时保留中文，其它语言使用英文短文案。
2. `KikariaLocalization` 位于 `KikariaTypography.swift`，只作为展示层 helper 使用；默认 `mixedText` 不自动翻译输入，避免误翻用户知识点、标签、答案或用户自定义 preset 名称。
3. 内置 preset 的英文名通过展示层映射生成，`KnowledgePreset.name`、`category`、`markdownText` 和用户存档不做迁移或重写。
4. Widget Extension target 不编译 App 侧 helper，因此 `KikariaWidget.swift` 内有独立 `WidgetLocalization`。新增 Widget 文案时必须同步维护。
5. 当前没有引入 `.strings`、string catalog、新三方库或运行时网络依赖。

## UI 与业务逻辑分层

当前分层偏轻量：很多业务逻辑、页面、状态保存和路由都集中在 `ContentView.swift`。独立文件主要承接模型、布局、字体、数学渲染和 Widget snapshot 数据。未来拆分时必须先补测试或做小步迁移，因为 `ContentView.swift` 内的状态链路高度耦合。

## 平台边界

- iOS：使用 `PhotosPicker`、`UIPasteboard`、UIKit bridge、WidgetKit、本地通知、file importer security-scoped resource。
- macOS：通过 `#if os(macOS)` 使用 AppKit、`NSPasteboard`、NSViewRepresentable 和窗口 chrome 配置。Mac App 不新建独立业务 UI，而是复用主 `ContentView()`。
- Widget：运行在 iOS extension 环境，独立定义数据镜像和布局，不能直接依赖 App 内部 `ContentView` 状态。

## 安全、权限和文件访问

- 文件导入使用 `startAccessingSecurityScopedResource()` / `stopAccessingSecurityScopedResource()`。
- iOS 头像使用 `PhotosPicker` 读取图片并压缩到最长边 512 后保存为 Data；macOS 编辑资料页头像导入当前仍是 TODO。
- 通知必须先请求系统授权。
- App 和 Widget 通过 App Group 共享非敏感学习概览数据。
- 未发现登录、账号、token、服务器 API 或云同步。

## 当前架构风险或不确定点

- `ContentView.swift` 超过一万行，是最大维护风险。
- 测试基本为空，Markdown 解析、存档迁移、Widget snapshot、通知判断和 Review 手势缺少自动化保护。
- `Presets/离散数学_BACKUP.md` 位于会被 bundle 扫描的目录中，可能成为用户可见内置预设；是否符合预期需要确认。
- README/SPEC 仍描述 v0.1 简化范围，与当前 Widget、macOS、通知、个人资料、SwiftMath 依赖等实现不完全同步。
- Widget 侧复制了 `WidgetSnapshot` 结构，App/Widget 字段变更必须双端同步。
- macOS 头像导入在源码中标注 TODO，当前按钮没有实际导入逻辑。
