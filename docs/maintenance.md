# 主页维护状态

更新于 2026-11-27。本仓库是 GitHub 个人主页 README 与公开项目索引，源文件为 `README.md`、`repo-descriptions.md` 和 `assets/`；没有应用运行时、数据库、安装包或自动更新客户端。Release 标签记录主页与维护脚本的版本。GitHub 托管 Markdown 与 SVG，浏览器在桌面和移动端展示同一份内容。

## 当前基线

| 项目 | 状态 | 依据 |
|---|---|---|
| 公开仓库覆盖 | 37 个索引仓库（34 个个人账号仓库含本主页，3 个组织归档仓库），36 个项目，2 个个人 Fork + 1 个组织归档 Fork | 2026-11-26 GitHub 用户/组织仓库 API 与 `-CheckLinks` 校验 |
| 本地结构校验 | 通过 | `pwsh -NoProfile -File scripts/validate-readme.ps1`（含叙述计数、语言和索引一致性） |
| 在线覆盖校验 | 通过 | `pwsh -NoProfile -File scripts/validate-readme.ps1 -CheckLinks`（含组织迁移仓库与主要语言） |
| 远程 CI | 通过 | 2026-11-23 定时任务因新仓库 `github-project-health-inspector` 未收录而失败；2026-11-26 索引同步后推送校验通过（37 个仓库、36 个项目） |
| 定期监测 | 已配置 | 每周一 03:17 UTC 检查公开仓库覆盖、状态、语言、索引与横幅；脚本与测试改动也会触发回归校验 |
| 竞品元数据扫描 | 已配置 | 每月 1 日 04:43 UTC 保存 30 个相关公开仓库的元数据为 Actions artifact；只上传本次生成的文件，人工评估后再改动主页 |
| 公开索引快照 | 已更新 | 2026-11-26 快照覆盖个人账号与组织归档仓库；脚本不会覆盖人工文案 |
| Release / 更新客户端 | 静态主页发布 | GitHub Profile README 随默认分支更新；顶部“最新更新”指向最新正式 Release，无需安装或迁移 |
| 依赖 / 漏洞 | 无应用依赖 | 校验使用 Python 标准库、PowerShell 和 GitHub API；2026-11-27 查询 Dependabot 与 secret scanning 均无开放告警，CodeQL 尚未配置 |
| 分支保护 | 未启用 | 2026-11-27 GitHub API 返回 main 未受保护 |
| 许可证 | 未声明 | 本仓库无 LICENSE 文件；新增内容不要假定开放源码许可 |

## 更新步骤

1. 从 GitHub 公开仓库列表和各仓库 README、Release 核对新增、迁移和归档状态。描述只写已公开证实的功能；调试版须注明。
2. 同步 `README.md` 与 `repo-descriptions.md`。调整 `assets/profile-banner.svg` 的仓库、项目、语言与 Fork 数字，同时更新 SVG 的无障碍描述、快照日期和两处“个人账号/本索引”叙述计数。横幅的 Fork 数表示未归档 Fork；个人账号摘要则包含个人账号下的归档 Fork，由在线 API 精确核验。GitHub 图片缓存可能延迟刷新。
3. 核对两个文件的主要语言与状态是否一致；语言以 GitHub 仓库 API 的 `language` 为准，未检测到时写 `未检测到`。
4. 运行 `python -m unittest discover -s tests -p "test_*.py" -v`、`pwsh -NoProfile -File tests/test-validate-readme.ps1` 和 `pwsh -NoProfile -File scripts/validate-readme.ps1 -CheckLinks`。最后一项依赖 GitHub API；无网络或限流时另行运行不带 `-CheckLinks` 的结构校验，并将在线覆盖标为未验证。
5. 提交与推送后检查 Actions 实际结论以及 GitHub 个人主页渲染。每周定时任务失败时按日志补充公开证据后人工修订，不自动覆盖编辑过的项目描述。项目迁移到组织时，将其加入校验脚本追踪清单并在 README 使用组织 URL。

竞品扫描脚本 `python scripts/research-profiles.py` 只读取 GitHub 公开信息并输出 JSON 快照，不复制第三方 README 原文，也不更新主页。公开索引脚本 `python scripts/sync-public-index.py` 只记录个人账号和明确追踪的组织归档仓库。两个脚本都不更新主页，`GITHUB_TOKEN` 仅在进程环境中使用。参考清单与取舍见 `docs/profile-research.md`，索引维护边界见 `docs/public-index.md`。

两个快照脚本支持 `--output-dir`，默认仍写入 `docs`。Actions 使用各自的临时目录，缺少本次快照时直接失败，避免把提交过的历史证据当成本次结果上传。公开索引会读取全部分页；明确追踪的组织仓库缺失时不会写出不完整快照。竞品扫描通过 GitHub 官方 README 端点检查文件存在性，支持大小写及位置差异，不下载 README 正文。

关注版本更新时，可在 GitHub 仓库的 Watch 自定义通知中选择 Releases；是否发送通知由订阅者的 GitHub 设置决定。旧的主页访问入口不变，默认分支更新后直接显示新内容。

清理只针对可确认的 `__pycache__`、本次验证临时文件和已由新结果替代的 Actions artifact。`docs` 内带日期的 JSON 是保留的历史审阅证据，不属于缓存；不清空用户级 Python、浏览器或系统缓存。

GitHub 的定时工作流只在默认分支触发，可能延迟；公开仓库 60 天无活动时可能被停用。可用 `workflow_dispatch` 手动重跑。这里不以 Actions 失败自动改写 README，避免错误元数据进入主页。

## 平台适用性

| 候选 | 结论 | 理由 |
|---|---|---|
| 桌面 Web、移动 Web、响应式 Web | A：继续支持 | GitHub 托管的同一 README 可在浏览器阅读；需在实际 GitHub 页面检查窄屏与 SVG。 |
| Windows 10/11、Linux（Ubuntu/Debian/Fedora/Arch）、macOS Intel/Apple Silicon | C：不单独开发 | 这些系统通过浏览器访问主页，没有可独立移植的业务逻辑。 |
| Android、Android 平板、折叠屏、iOS、iPadOS | C：不单独开发 | 移动浏览器可访问；原生客户端没有额外用户价值。 |
| PWA、Chrome/Edge/Firefox 扩展 | C：不开发 | 主页信息由 GitHub 实时展示，离线安装或浏览器权限无实际用途。 |
| Docker、NAS、私有化、云服务器、CLI | C：不开发 | GitHub 已提供公开托管；仅本地 PowerShell CLI 用于维护校验。 |

## 已知限制与后续工作

- `Codex-Remote-Bridge`、`Qzone-Archive` 和 `themes` 已使用 `Indifference-Project` 组织下的公开归档地址列入历史项目，不计入个人账户仓库数。
- 公开仓库随时变化，文档日期是快照，定期检查只能发现不同步，项目介绍仍需人工判断。
- GitHub 主要语言可能随代码提交变化；校验会直接指出差异，需人工确认后更新索引，而不是让脚本改写文案。
- 横幅图片由 GitHub 的 raw 端点提供；发布后立即打开主页可能因平台缓存仍看到旧数字，刷新或等待后再核对，不保证固定刷新时限。
- GitHub Profile 的第三方项目和发布信息在各自仓库维护。本仓库不会替它们创建跨平台安装包或更新通道。
