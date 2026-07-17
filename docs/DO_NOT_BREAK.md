# DO_NOT_BREAK

## 外部依赖优先与禁止功能兜底（Vitemis 强制规则）

本项目继承 `/Users/vita/Vitemis/docs/DEPENDENCY_POLICY.md`。本节是强制约束，不是建议。

- 当用户指定、仓库已经采用，或经许可证、provenance、安全与平台审查可采用的外部依赖提供同等能力时，必须直接集成该依赖的官方 API 或官方扩展点。
- 不得自行重写同等能力，不得新增替代 adapter、shim、compatibility layer、wrapper、proxy、facade、协议翻译层、parallel backend、preview backend、shadow implementation 或“先兜底、以后再换”的实现。
- 本地代码只允许保留官方 API 必需的最薄生命周期、类型、权限、配置和 bundle 接线；不得重新实现、解释、扩展或替代依赖的核心能力。
- exact 依赖因版本、构建、签名、许可证、平台、安全或官方 API 限制无法接入时，必须停止该能力、明确失败、报告 blocker 并请求用户决定；不得静默降级、切换 legacy/另一 provider/backend、使用 cache/mock/简化路径或继续交付不完整替代实现。
- 现有 fallback、adapter 或重复实现不构成先例，后续不得扩展。安全 fail-closed 与明确要求的旧数据解码/迁移不是功能兜底，但必须保持最窄范围，不能演化成备用产品实现。
- 只有用户针对 exact 依赖、exact 范围和退出条件作出的新明文决定才能例外。

最后自查日期：2026-07-04

本文件记录修改 Kikaria 时不得破坏的工程约束。未来 Codex 修改前必须先读本文件，再读对应源码。

## Git 禁区

- 未经用户明文要求具体 Git 操作，不 add、不 commit、不 push、不创建 PR；编辑、整理、修复、验证或准备工作都不等于提交请求。
- 若用户要求提交，只提交当前 Git root 中与本任务相关的文件；不得递归进入、暂存、提交或推送子仓库、submodule、nested Git repo 或依赖 checkout。
- 不执行破坏性 Git 操作，不强制 push，不删除用户未提交文件。

## 不得破坏的用户数据格式

- Markdown 导入格式：
  - 每个知识点用单独一行 `---` 分隔。
  - 标题必须以 `#` 开头。
  - `tags:` 支持英文逗号和中文逗号。
  - `hint:` 必须在 `content:` 前。
  - hint 和 content 都不能为空。
- `KnowledgePoint` 编解码兼容：
  - `reinforcementCount > 0` 是重点集锦真实状态。
  - `isReinforced` 是兼容字段，编码时应反映 `reinforcementCount > 0`。
  - 旧数据只有 `isReinforced == true` 时应迁移为 `reinforcementCount = 1`。
  - `lastReinforcedAt` 在 count 为 0 时应清空。
- `PresetStudyState` 字段不能随意改名或删除：
  - `knowledgePoints`
  - `markdownText`
  - `selectedTags`
  - `dailyReviewRecords`
  - `activityRecords`
  - `dailyGoal`
  - `countdownStartDate`
  - `countdownEndDate`
  - `notificationsEnabled`
  - `notificationTime`
  - `dangerPercent`
- `KikariaAppState.storageKey` 必须保持 `kikaria.appStateJSON`，除非写迁移。
- Legacy key 不能无迁移删除：
  - `presetLibraryJSON`
  - `dailyLearningGoal`
  - `hasCompletedOnboarding`
  - legacy `countdownDate`
- `dailyGoal` 范围应 clamp 到 1...100。
- `dangerPercent` 范围应 clamp 到 1...100。

## 不得破坏的文件路径约定

- `Presets/` 是内置 Markdown 资源目录，`KnowledgePreset` 会在 App bundle 的 `Presets` 子目录中查找 `.md`。
- `Kikaria/Assets.xcassets/AppIcon.appiconset/` 是主 App icon 来源。
- `KikariaMac/Assets.xcassets/AppIcon.appiconset/` 是 macOS icon 来源。
- `Kikaria/Kikaria.entitlements` 和 `KikariaWidget/KikariaWidget.entitlements` 必须保持 App Group 对齐。
- `scripts/build.sh` 默认写 `.build/DerivedData`，不要改成污染源码目录的输出路径。
- `.gitignore` 中的 `.build/`、`DerivedData/`、`build/`、`xcuserdata/` 等忽略规则不能随意移除。

## 不得破坏的 API / 路由 / 协议 / 存储结构

- `AppRoute` case 会被 `NavigationStack` 使用，删除或改名会影响页面导航。
- `ReviewMode` 三种模式语义必须保持：
  - normal：普通复习。
  - reinforcement：重点集锦。
  - mastered：已掌握。
- `WidgetSnapshot` App 侧和 Widget 侧字段必须同步。
- Widget storage：
  - App Group ID：`group.com.vita0818.kikaria`
  - snapshot key：`kikaria.widgetSnapshot`
  - 先写/读 App Group，再 fallback standard UserDefaults。
- Widget kind：`KikariaProgressWidget`。
- Widget 支持 families：`.systemSmall`、`.systemMedium`、`.systemLarge`。
- 通知 identifier：`kikaria.studyProgressWarning.<presetID>`。
- LaTeX 只识别 `$...$` 和 `$$...$$`，代码块/反引号内容不应被当作公式。
- v3.1 本地化只允许改展示层字符串：
  - 不要把 `KnowledgePreset.name`、`category`、`markdownText`、`KnowledgePoint.title/tags/hint/content` 或用户存档批量翻译或迁移。
  - 不要让 `KikariaTypography.mixedText` 默认自动翻译任意输入；用户知识点内容会经过该渲染入口。
  - Widget target 有独立 `WidgetLocalization`，新增 Widget 文案时必须同步维护。

## 不得绕过的安全机制

- 文件导入必须继续使用 security-scoped resource 访问。
- iOS 图片导入应通过 `PhotosPicker` 或等价系统授权机制。
- 本地通知必须经过系统授权，不得绕过权限状态。
- 不要加入登录、云同步、远程推送、运行时网络上传或服务器 API，除非用户明确改变产品方向。
- 不要在文档、源码、日志或测试数据中写入密钥、token、证书私钥、账号密码或真实 shared secret。

## 不得随意重构的核心模块

- `Kikaria/ContentView.swift`
  - Review Screen、路由、Preset 管理、状态保存、通知和 Widget 刷新都在此文件中。
  - 拆分前必须先确认状态流和回归范围。
- `Kikaria/KnowledgePoint.swift`
  - Markdown 解析、导出、`KnowledgePoint` 编解码迁移、内置 preset 加载都在这里。
- `Kikaria/StudyTracking.swift`
  - 学习活动和 Widget snapshot App 侧结构在这里。
- `KikariaWidget/KikariaWidget.swift`
  - Widget 数据结构镜像、timeline 和三尺寸布局在这里。
- `Kikaria/KikariaAdaptiveLayout.swift`
  - iPhone/iPad/Mac 自适应布局指标在这里。
- `Kikaria/KikariaMathText.swift` 和 `Kikaria/KikariaMathFormulaView.swift`
  - 长答案、公式渲染、fallback 和横向滚动相关。

## 不得删除或覆盖的资源

- `Presets/*.md` 内置知识点资源。
- `Kikaria/Assets.xcassets/**` 和 `KikariaMac/Assets.xcassets/**`。
- `KikariaNewIcon.png`，当前用途未确认，删除前必须确认。
- `Kikaria.xcodeproj/xcshareddata/xcschemes/*.xcscheme`。
- entitlements、Info.plist、Package.resolved。
- 用户未提交改动和用户本地文件。

## 不得引入的架构倒退

- 不把本地优先状态改成依赖网络、账号或云端。
- 不把 Widget 数据读取改成只依赖 standard UserDefaults。
- 不把重点集锦重复计数降级成 Bool。
- 不让标记已掌握和重点状态互相污染：
  - 标记已掌握会清重点。
  - 移出已掌握不应破坏重点。
  - 重点模式移出重点不应影响已掌握。
- 不给 Review 长答案、hint/content、LaTeX block 加会截断内容的 `lineLimit`。
- 不只验证一个 Widget 尺寸就修改共享 Widget 布局。
- 不硬编码只适配浅色模式的颜色。

## 修改前必须阅读的关键源码位置

- App 启动：`Kikaria/KikariaApp.swift`
- 主 UI/状态：`Kikaria/ContentView.swift`
- Markdown 与 preset：`Kikaria/KnowledgePoint.swift`
- 学习记录/Widget snapshot：`Kikaria/StudyTracking.swift`
- Widget：`KikariaWidget/KikariaWidget.swift`
- macOS 包装：`KikariaMac/KikariaMacRootView.swift`
- 适配布局：`Kikaria/KikariaAdaptiveLayout.swift`
- 数学渲染：`Kikaria/KikariaMathText.swift`、`Kikaria/KikariaMathFormulaView.swift`
- 构建脚本：`scripts/build.sh`
- 工程配置：`Kikaria.xcodeproj/project.pbxproj`

## 回归验证要求

按改动范围选择验证：

- 数据模型或存档：新增/旧数据解码、保存、重启恢复、legacy 迁移。
- Markdown：合法/非法 Markdown、中文逗号 tags、LaTeX 保留、导出再导入。
- Review：三种模式、手势、提示/答案、长答案滚动、重点/已掌握动作、Toast 和学习记录。
- Preset：切换、新建、编辑、删除、至少保留一个 preset。
- Widget：small/medium/large、深浅色、空数据、长文本、App Group fallback。
- 通知：权限、开关、时间、倒数日期、危险线、不达标/达标两种判断。
- macOS：窗口尺寸、侧边栏、快捷键、资料编辑。
- 构建：至少运行 `scripts/build.sh`，除非用户明确要求不构建或环境不允许。
