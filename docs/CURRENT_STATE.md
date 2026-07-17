# CURRENT_STATE

最后自查日期：2026-07-04

## 当前工作区状态摘要

2026-07-04 v3.1 开始时执行结果：

- `pwd`：`/Users/vita/Vitemis/Vela/Kikaria`
- `git rev-parse --show-toplevel`：`/Users/vita/Vitemis/Vela/Kikaria`
- `git status --short`：工作区已有未提交改动，包含 `.gitignore`、`AGENTS.md` 和若干跨 agent 文档；v3.1 本轮未回退或覆盖这些既有改动。

## 当前项目已实现能力

根据源码和工程配置，当前已实现：

- 本地 SwiftUI iOS App。
- macOS App target，复用主 `ContentView()` 并配置桌面窗口。
- Widget Extension，支持 small、medium、large 三种 Widget family。
- 内置 Markdown preset，从 `Presets/*.md` 加载。
- 自定义 preset 创建、文件导入、编辑、删除。
- Markdown 知识点解析和导出，支持标题、tags、hint、content、`---` 分隔。
- LaTeX inline/block 识别与本地 SwiftMath 渲染。
- 标签范围选择、普通复习、重点复习、已掌握复习。
- 查看提示、查看答案、加入/移出重点、加入/移出已掌握。
- `reinforcementCount` 记录重复加入重点次数。
- 今日概览、复习历史、每日目标、倒数日期。
- 按 preset 独立保存学习状态。
- 本地通知进度预警。
- 首次引导、首次个人资料设置、iOS 头像选择和压缩保存。
- Widget snapshot 双写 App Group 和 standard UserDefaults。
- 深浅色适配和 iPhone/iPad/Mac 自适应布局。
- v3.1 英文适配：App/macOS 复用 `KikariaLocalization` 按设备首选语言在中文和英文 UI 文案间切换；Widget Extension 使用独立轻量 helper 做相同选择。当前适配范围是 UI/通知/Widget/Markdown 指南文案，不翻译用户知识点内容或已有存档。

## 当前未完成能力

以下只根据源码可见事实记录：

- `KikariaMacTests` 和 `KikariaMacUITests` 基本是模板，未覆盖核心业务。
- 未发现主 iOS App 专属业务测试。
- macOS 编辑资料页头像更换按钮处有 TODO，当前未接入 NSOpenPanel。
- 未发现 CI 配置、SwiftLint 配置或格式化配置。
- README/SPEC 未同步当前完整能力范围。

## 当前已知 bug / 风险

- `ContentView.swift` 承载过多 UI、状态和业务逻辑，局部修改容易牵动保存、Widget、通知或 Review 行为。
- `Presets/离散数学_BACKUP.md` 位于资源目录，当前加载逻辑会枚举 `Presets` 下所有 `.md` 文件；是否应作为内置预设暴露需要确认。
- App/Widget 双端各自定义 `WidgetSnapshot`，字段变更需要同步维护。
- App 与 Widget 的英文文案目前是源码内手写映射，不是 `.strings` / string catalog；新增 UI 文案需要同步补充映射，尤其 Widget target 不会自动共享 App helper。
- 内置 Markdown preset 的学习内容仍保持原始中文资源；英文设备下只适配 UI 和内置 preset 的展示名，不翻译知识点正文。
- `KnowledgePoint.reinforcementCount`、legacy `isReinforced`、`PresetStudyState` 迁移和 `KikariaAppState.storageKey` 是用户数据兼容关键点。
- SwiftMath 是当前构建依赖；README/SPEC 中“无第三方库”的旧约束与当前工程不一致。
- 2026-07-04 v3.1 已运行 `git diff --check`、`scripts/build.sh` 和 `xcodebuild -project Kikaria.xcodeproj -scheme KikariaMac -configuration Debug -destination 'platform=macOS' -derivedDataPath .build/DerivedDataMac build`；未实际打开 App 或 Widget 做人工 UI 走查。

## 当前优先级建议

- 优先补 Markdown 解析、`KnowledgePoint` 编解码迁移、`PresetStudyState`、Widget snapshot 的单元测试。
- 确认 `Presets/离散数学_BACKUP.md` 是否应继续被 bundle 扫描。
- 更新 README/SPEC 或明确它们只代表早期 v0.1 目标。
- 若要重构 `ContentView.swift`，先围绕 Review、Preset 保存、Widget、通知建立回归验证。

## 文档可信度说明

本轮文档基于以下证据：

- `rg --files`、`find`、`sed`、`plutil` 对源码、资源、plist、脚本和工程文件的读取。
- `xcodebuild -list -project Kikaria.xcodeproj` 对 targets、schemes 和 SwiftPM 依赖的确认。
- `Package.resolved`、`project.pbxproj`、entitlements、Info.plist、scheme 文件的只读检查。

2026-07-04 v3.1 已运行 iOS/Widget 构建和 macOS wrapper 构建。未实际打开 App、未在 Simulator 中切换系统语言、未触发真实通知送达，因此运行时 UI 截断和通知实际触达仍需人工验证。

## 源码与旧文档冲突记录

- `CODEX_CONTEXT.md` 记录当前路径为 `/Users/vita/Project/Kikaria`，本轮实际 Git root 为 `/Users/vita/Vitemis/Vela/Kikaria`。
- `README.md` 和 `SPEC.md` 描述 v0.1 为“无第三方库”，但当前工程通过 SwiftPM 引入 `SwiftMath` 1.7.3。
- `README.md` 和 `SPEC.md` 描述的是早期 iOS、本地、简单复习目标；当前源码已包含 Widget、macOS target、通知、个人资料、多预设、LaTeX 渲染和学习历史。
- `CODEX_CONTEXT.md` 仍有较多有效工程红线，但未来 Codex 应先读 `AGENTS.md` 和 `docs/`，再把 `CODEX_CONTEXT.md` 作为历史参考。
