# Kikaria Codex 工作入口

## 外部依赖优先与禁止功能兜底（Vitemis 强制规则）

本项目继承 `/Users/vita/Vitemis/docs/DEPENDENCY_POLICY.md`。本节是强制约束，不是建议。

- 当用户指定、仓库已经采用，或经许可证、provenance、安全与平台审查可采用的外部依赖提供同等能力时，必须直接集成该依赖的官方 API 或官方扩展点。
- 不得自行重写同等能力，不得新增替代 adapter、shim、compatibility layer、wrapper、proxy、facade、协议翻译层、parallel backend、preview backend、shadow implementation 或“先兜底、以后再换”的实现。
- 本地代码只允许保留官方 API 必需的最薄生命周期、类型、权限、配置和 bundle 接线；不得重新实现、解释、扩展或替代依赖的核心能力。
- exact 依赖因版本、构建、签名、许可证、平台、安全或官方 API 限制无法接入时，必须停止该能力、明确失败、报告 blocker 并请求用户决定；不得静默降级、切换 legacy/另一 provider/backend、使用 cache/mock/简化路径或继续交付不完整替代实现。
- 现有 fallback、adapter 或重复实现不构成先例，后续不得扩展。安全 fail-closed 与明确要求的旧数据解码/迁移不是功能兜底，但必须保持最窄范围，不能演化成备用产品实现。
- 只有用户针对 exact 依赖、exact 范围和退出条件作出的新明文决定才能例外。

本文件是未来 Codex 接手 Kikaria 时的入口。任何修改前先确认当前源码状态，再决定是否动手；如果文档与源码冲突，以源码为准，并在最终报告中指出冲突。

## 必读顺序

每轮开始、任何修改前必须按顺序阅读：

1. `docs/CURRENT_STATE.md`
2. `docs/PROJECT_MAP.md`
3. `docs/ARCHITECTURE.md`
4. `docs/DO_NOT_BREAK.md`
5. `docs/TESTING.md`
6. `docs/NEXT_TARGET.md`（如果存在）

旧文件 `CODEX_CONTEXT.md` 只能作为历史参考。若它与源码或 `docs/` 文档冲突，以当前源码和工程配置为准。

## 工作目录检查

项目根目录应为：

```sh
/Users/vita/Vitemis/Vela/Kikaria
```

开始修改前先执行：

```sh
pwd
git rev-parse --show-toplevel
git status --short
```

若 `pwd` 或 Git root 不是上述项目根目录，停止修改并汇报问题。若工作区已有改动，先判断是否与任务相关；不要回退、覆盖或删除用户已有改动。

## 修改边界

- 只改与用户任务直接相关的文件。
- 文档任务只允许改 `AGENTS.md` 和 `docs/` 下的说明文档。
- 业务源码、Xcode 工程、构建脚本、测试源码、资源文件、entitlements、signing 配置，只有在用户明确要求对应开发任务时才能改。
- 修改 `Kikaria/ContentView.swift` 前必须先定位相关 view、state 和 persistence 链路；该文件承载大量 UI、路由、状态保存和通知逻辑。
- 修改 Widget、通知、Preset、Markdown 解析、存档结构前，必须先阅读 `docs/DO_NOT_BREAK.md` 中对应约束。

## 禁止事项

- 不执行破坏性 Git 操作：`git reset --hard`、`git clean -fd`、`git checkout .`、强制 push、删除未提交文件。
- 未经用户明文要求具体 Git 操作，不 add、不 commit、不 push、不创建 PR；编辑、整理、修复、验证或准备工作都不等于提交请求。
- 若用户要求提交，只提交当前 Git root 中与本任务相关的文件；不得递归进入、暂存、提交或推送子仓库、submodule、nested Git repo 或依赖 checkout。
- 不引入账号、远程服务、云同步、运行时网络依赖或新的第三方库，除非用户明确改变项目方向。
- 不写入密钥、token、证书私钥、账号密码、真实 shared secret 或个人隐私信息。
- 不随意修改 `DEVELOPMENT_TEAM`、bundle id、entitlements、App Group、scheme、App Icon、资源打包路径。
- 不把 `KnowledgePoint.reinforcementCount` 退回为单一 Bool 语义。
- 不让长答案、LaTeX block、Widget 三尺寸布局或 Review Screen 手势退化。

## 项目理解要求

未来 Codex 必须通过实际源码和配置确认项目状态，不能只根据文件名猜测。重点确认：

- Xcode targets、schemes、SwiftPM 依赖和 deployment target。
- iOS App、macOS wrapper、Widget Extension、测试 target 的边界。
- `KnowledgePoint`、`KnowledgePreset`、`PresetStudyState`、`KikariaAppState`、`WidgetSnapshot` 的数据格式。
- Review、Preset 导入/编辑、Widget snapshot、本地通知、UserDefaults 持久化链路。
- 资源目录 `Presets/` 和 asset catalogs 的打包方式。

不确定的模块必须标注 `UNKNOWN` 或 `需要后续确认`，不要编造。

## 文档索引

- `docs/PROJECT_MAP.md`：目录、关键文件、入口、配置、测试和资源地图。
- `docs/ARCHITECTURE.md`：总体架构、数据流、状态流、Widget/通知/数学渲染链路和风险。
- `docs/CURRENT_STATE.md`：当前实现能力、已知风险、旧文档冲突、工作区状态。
- `docs/TESTING.md`：环境、依赖、构建、测试、静态检查和手动验证矩阵。
- `docs/DO_NOT_BREAK.md`：数据格式、路径约定、安全机制、核心模块和回归要求。
- `docs/NEXT_TARGET.md`：临时下一目标记录；目标完成或不再有效后删除。

## 完成标准

代码类任务完成前至少做到：

- 已阅读本文件和 `docs/` 常驻上下文。
- 已确认 `pwd`、Git root、`git status --short`。
- 已说明实际修改文件和未修改的高风险文件。
- 已按风险运行合适的 build/test/lint 或说明未运行原因。
- 已确认没有破坏用户未提交改动。
- 已将本轮完成的持久性改动及时回写到相关项目文档；若无需更新文档，最终报告说明原因。

文档类任务完成前至少做到：

- 已根据当前源码和配置更新文档。
- 已记录源码与旧文档冲突。
- 已运行 `git diff --check` 和必要的只读核对命令。
- 明确说明是否未运行构建/测试。

## 最终报告格式

最终报告至少包含：

1. `MODEL_CHECK_RESULT`
2. `PATH_CHECK_RESULT`
3. `FILES_CHANGED` 或用户指定的文件列表字段
4. `PROJECT_AUDIT_SUMMARY`
5. `VALIDATION_RESULT`
6. `UNCERTAINTIES`
7. `NEXT_RECOMMENDED_ACTION`

若用户指定了更严格的最终报告格式，以用户要求为准。
