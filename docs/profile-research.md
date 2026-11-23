# GitHub Profile 生态调研与取舍

2026-11-23 复核。2026-11-18 快照仍保留作为历史证据；本次另外核对了 GitHub 公开 API 返回的 33 个个人账号仓库、`Indifference-Project` 组织的 3 个迁移归档仓库，以及各项目当前 README、Release 和许可证。快照记录 Star、Fork、最后提交、最新 Release、许可证、语言、README 是否存在、根目录和开放 Issue 数及最新标题；这些值会变化，空值表示接口未返回。README 只用于阅读，不在快照中复制第三方原文。列表按搜索结果排序，Star 排序不能代替质量判断。

## 本轮事实更正

- `themes`、`Qzone-Archive`、`Codex-Remote-Bridge` 已迁移到 [Indifference-Project](https://github.com/Indifference-Project)，其中 `themes` 为已归档 Fork；个人账号 URL 会重定向或返回 404，不能继续当作个人仓库计数。
- 个人账号当前公开仓库为 33 个（含本主页），主页项目表为 32 个；加上 3 个组织归档项目后，索引覆盖 36 个公开仓库、35 个项目。
- `LUMORA-Camera` 当前公开稳定版为 v2.1.7，README 明确区分正式签名 APK 与历史调试签名版本；主页不再把它写成“调试签名测试版”。
- `Base64-encode-encoding` 的当前 README 明确是 Windows x64 桌面版及跨平台命令行版，不是独立 Web / PWA 产品；主页描述已按这一边界收紧。
- `Doomsday-Survival-Guide`、`JukeboxRoom`、`GitHub-Achievement-Hub` 和 `Short-Video-Analysis` 的平台描述以各自 README 的实际交付矩阵为准，不把源码、开发构建或待验证设备写成已发布产品。

## UI 生态复核与取舍

本仓库没有 Web 应用运行时，GitHub 只渲染 Markdown、原生 HTML 表格和本地 SVG。因此本轮没有为了“接入组件库”而引入 React、Tailwind 或第三方动态卡片；继续维护黑金设计 Token、原生表格和可审计的本地 SVG，能减少外部请求、供应链风险和窄屏渲染漂移。

截至 2026-11-23，实际核对了以下维护中的生态项目公开元数据：

| 生态 | 公开证据（截至本轮） | 对本仓库的取舍 |
|---|---|---|
| [shadcn/ui](https://github.com/shadcn-ui/ui) | MIT，约 128k Stars，持续提交；以可复制的 Tailwind/Radix 组件源码为核心 | 适合应用仓库，不适合 GitHub Profile 的静态 Markdown；不引入 |
| [Radix Primitives](https://github.com/radix-ui/primitives) / [Radix Themes](https://github.com/radix-ui/themes) | Radix 生态强调无障碍原语与主题；本账号的 `themes` Fork 已迁移并归档 | 记录迁移事实，不复制 Fork 代码或把归档 Fork 当作活跃产品 |
| [Tailwind CSS](https://github.com/tailwindlabs/tailwindcss) | MIT，约 98k Stars，持续维护 | 没有构建链和 CSS 运行时，不增加依赖 |
| [Motion](https://github.com/motiondivision/motion) | MIT，约 35k Stars，提供 React/原生动画能力 | SVG 横幅已有轻量动画；不为个人主页增加脚本动效 |
| [Lucide](https://github.com/lucide-icons/lucide) | 图标库，约 26k Stars；线性图标风格统一 | Profile 只保留 3 个本地 SVG 装饰资产，避免外部图标请求 |
| [GitHub Readme Stats](https://github.com/anuraghazra/github-readme-stats) / [lowlighter/metrics](https://github.com/lowlighter/metrics) | 动态统计卡片生态成熟，但依赖第三方服务或 Actions 生成 | 不添加会随请求失败、缓存或账号权限变化的动态卡片 |
| [simple-icons](https://github.com/simple-icons/simple-icons) | CC0 品牌 SVG 集合，约 26k Stars | 当前文字技术栈比堆徽章更易核实，暂不增加品牌图标墙 |

结论：本轮 UI 升级落在现有 SVG 横幅、信息层级、表格宽度和链接可审计性，而不是引入不适合当前媒介的组件依赖。后续若作品集 Web 应用需要复用视觉 Token，优先评估 Radix + Tailwind；那属于独立应用的技术选型，不应反向改造 Profile README。

| 仓库 | 关系 | 本次可用的参考点与取舍 |
|---|---|---|
| [abhisheknaiidu/awesome-github-profile-readme](https://github.com/abhisheknaiidu/awesome-github-profile-readme) | 展示参考 | 主页实例目录；继续保持本项目自己的视觉与文案。 |
| [Ileriayo/markdown-badges](https://github.com/Ileriayo/markdown-badges) | 素材参考 | 技术徽章目录；当前主页已有文字技术栈，无需堆叠徽章。 |
| [alexandresanlim/Badges4-README.md-Profile](https://github.com/alexandresanlim/Badges4-README.md-Profile) | 素材参考 | 更多徽章形式；不引入新的外部图片依赖。 |
| [rzashakeri/beautify-github-profile](https://github.com/rzashakeri/beautify-github-profile) | 展示参考 | 分类和素材索引；其根目录未发现 README.md，需从项目文件进一步核对后才采用。 |
| [ryo-ma/github-profile-trophy](https://github.com/ryo-ma/github-profile-trophy) | 动态组件 | 展示成就；本项目以项目发现为中心，不添加随请求变化的第三方卡片。 |
| [Platane/snk](https://github.com/Platane/snk) | 动画参考 | Actions 生成 SVG 的模式；动画对项目发现价值低。 |
| [vn7n24fzkq/github-profile-summary-cards](https://github.com/vn7n24fzkq/github-profile-summary-cards) | 数据展示 | 可生成摘要卡片；当前静态指标更易核实，继续人工审定。 |
| [Anmol-Baranwal/Cool-GIFs-For-GitHub](https://github.com/Anmol-Baranwal/Cool-GIFs-For-GitHub) | 素材参考 | GIF 目录；增加加载和动效，暂不使用。 |
| [yoshi389111/github-profile-3d-contrib](https://github.com/yoshi389111/github-profile-3d-contrib) | 动画参考 | 贡献图生成流程；与主页项目目录目标不同。 |
| [leviarista/github-profile-header-generator](https://github.com/leviarista/github-profile-header-generator) | 视觉工具 | 生成横幅；本仓库已有可编辑 SVG 横幅和数字校验。 |
| [elangosundar/awesome-README-templates](https://github.com/elangosundar/awesome-README-templates) | 展示参考 | 模板目录；最近提交较旧，不作为维护流程依据。 |
| [VishwaGauravIn/github-profile-readme-maker](https://github.com/VishwaGauravIn/github-profile-readme-maker) | 生成器 | 页面生成方式；GPL-3.0 项目，不复制代码或素材。 |
| [czl9707/gh-space-shooter](https://github.com/czl9707/gh-space-shooter) | 动画参考 | 贡献图游戏；不适合本主页。 |
| [x0rzavi/github-readme-terminal](https://github.com/x0rzavi/github-readme-terminal) | 视觉工具 | 终端动图；可读性收益有限。 |
| [YuheshPandian/ICONIC](https://github.com/YuheshPandian/ICONIC) | 图标参考 | 技能图标目录；不替换既有品牌 SVG。 |
| [vinimlo/galaxy-profile](https://github.com/vinimlo/galaxy-profile) | 生成器 | 星系主题和自动生成；GPL-3.0，不移植代码。 |
| [MartinHeinz/MartinHeinz](https://github.com/MartinHeinz/MartinHeinz) | 主页实例 | 个人简介与博客入口的安排；本项目继续突出项目清单。 |
| [KasRoudra/KasRoudra](https://github.com/KasRoudra/KasRoudra) | 主页实例 | 简明介绍方式；无需引入额外服务。 |
| [Igorcbraz/GitAscii](https://github.com/Igorcbraz/GitAscii) | 生成器 | 浏览器编辑与 SVG 导出；GPL-3.0，不移植代码。 |
| [haidang666/awesome-tool-for-readme-profile](https://github.com/haidang666/awesome-tool-for-readme-profile) | 工具目录 | 集中列举卡片、徽章和 Actions；可用于后续复核方案。 |
| [whiteSHADOW1234/TypingSVG](https://github.com/whiteSHADOW1234/TypingSVG) | 动态组件 | 多行打字 SVG；本项目无需动态标题。 |
| [zumrudu-anka/zumrudu-anka](https://github.com/zumrudu-anka/zumrudu-anka) | 主页实例 | 联系与技术信息展示；保留当前精简入口。 |
| [gitranks/gitranks-ui](https://github.com/gitranks/gitranks-ui) | 数据参考 | 排名及分析徽章；不把排名当作项目质量结论。 |
| [ouuan/ouuan](https://github.com/ouuan/ouuan) | 主页实例 | 自动维护的个人仓库内容；人工审定仍是本项目文案来源。 |
| [Raymo111/Raymo111](https://github.com/Raymo111/Raymo111) | 主页实例 | 标注人工更新日期；本项目已有快照日期。 |
| [roypriyanshu02/awesome-github-profile-readme](https://github.com/roypriyanshu02/awesome-github-profile-readme) | 展示参考 | 个人主页目录；适合后续定期查看布局趋势。 |
| [blackcater/blackcater](https://github.com/blackcater/blackcater) | 自动化参考 | 配置驱动的 README 生成；本项目选择校验加人工编辑，保护精确描述。 |
| [pedrocatalao/github-cool-readme](https://github.com/pedrocatalao/github-cool-readme) | 自动化参考 | 定时 Actions 发布独立 SVG；本项目借鉴定时检查，不增加图片发布分支。 |
| [Aveek-Saha/GitHub-Profile-Badges](https://github.com/Aveek-Saha/GitHub-Profile-Badges) | 素材参考 | 高对比度徽章目录；如增加图标应先评估可访问性。 |
| [Coordinate-Cat/Coordinate-Cat](https://github.com/Coordinate-Cat/Coordinate-Cat) | 主页实例 | 多组件式主页；本项目保持较低的外部依赖。 |

## 本项目差距与实施

当前项目的主要差距是数据漂移，不是缺少视觉组件：2026-11-18 基线中，在线仓库覆盖校验失败，README 和辅助索引不同步，旧归档链接已失效。已同步 34 个公开仓库、33 个项目和 3 个 Fork；让校验比较两个索引，并配置定时检查与人工报告入口。借鉴了定时 Actions 的可追踪性，没有导入第三方代码或资产。参考项目许可证见 JSON 快照；本仓库未声明许可证，不据此推断可复制权限。

## 30 项升级候选

以下候选依据本仓库基线、GitHub 官方 Profile/Actions 文档及上表项目的功能类型筛选；「后续评估」不表示已经实现。

| # | 具体候选与用户价值 | 取舍 |
|---|---|---|
| 01 | 新仓库覆盖校验，避免主页漏项 | 已实施 |
| 02 | 辅助索引与 README 同步校验，避免描述分叉 | 已实施 |
| 03 | Fork 状态校验，避免标注错误 | 已有并继续使用 |
| 04 | 横幅仓库数校验，避免图文不一致 | 已有并更新 |
| 05 | 横幅语言数校验，加入 Kotlin 后同步 | 已有并更新 |
| 06 | 新增项目纳入分类，便于访问 | 已实施 |
| 07 | 清理返回 404 的项目链接，避免失效入口 | 已实施 |
| 08 | 调试签名 APK 显著标注，避免误作正式版 | 已实施 |
| 09 | 每周在线检查，及时发现公开仓库变动 | 已配置，待首次运行 |
| 10 | 手动触发在线检查，便于紧急复核 | 已配置 |
| 11 | 资料问题 Issue 模板，收集公开证据 | 已实施 |
| 12 | PR 证据清单，减少未经核实的描述 | 已实施 |
| 13 | 维护状态记录，区分通过与待验证 | 已实施 |
| 14 | 每月竞品元数据快照，观察设计与维护变化 | 已配置，待首次运行 |
| 15 | 对迁移到组织的旧项目建立独立历史区 | 后续评估：先确认公开地址 |
| 16 | 对单项目 Release 链接做 HTTP 健康检查 | 后续评估：处理无 Release 的仓库 |
| 17 | 记录每项描述的来源日期 | 后续评估：维护成本较高 |
| 18 | 将项目类别做成机器可读清单 | 后续评估：需避免双数据源 |
| 19 | 自动比较 GitHub 主要语言与标注 | 后续评估：语言统计可能随提交变化 |
| 20 | 报告新增仓库候选分类 | 后续评估：人工确认定位 |
| 21 | 检查 SVG 文本对比度 | 后续评估：需先测真实渲染 |
| 22 | 窄屏阅读检查 | 后续评估：需实际移动视口验收 |
| 23 | 对减少动效偏好检查横幅表现 | 后续评估：需浏览器验收 |
| 24 | 项目描述长度预算 | 后续评估：避免单行过长 |
| 25 | 搜索引擎可读的纯文本项目摘要 | 后续评估：避免重复维护 |
| 26 | 每个项目的公开许可证状态标识 | 后续评估：许可证变更需监测 |
| 27 | 发布信息缺失时隐藏「最新发行」入口 | 后续评估：需按仓库动态判断 |
| 28 | README 与作品集站点互链核对 | 后续评估：跨仓库维护 |
| 29 | 项目变更历史日志 | 后续评估：Git 历史已提供基本追溯 |
| 30 | 自动生成整页 README | 暂不实施：会覆盖人工核实的文案与视觉 |

本次 30 项是可行性清单，未进行每个竞品源码内部、所有文档及 UI 的逐项深度审查。未来大版本前应从与目标功能最相关的仓库继续做深度核查。GitHub 的 `updatedAt` 可因非代码事件变化，判断活跃程度以最后提交及 Release 为主；不把仅有 Star 变化写成近期功能更新。
