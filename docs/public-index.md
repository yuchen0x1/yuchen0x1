# 公开索引维护说明

本仓库的 README 是人工编辑的作品集，不应由机器人直接覆盖。`scripts/sync-public-index.py` 只读取 GitHub 公开仓库元数据并保存带日期的 JSON 快照，用来发现迁移、归档、语言和维护状态变化。

## 数据范围

- 个人账号：`yuchen0x1` 的公开仓库，包括本主页仓库本身。
- 组织归档：`Indifference-Project` 下明确追踪的 `Qzone-Archive`、`Codex-Remote-Bridge` 和 `themes`。
- 不读取仓库源码、Issue 内容、私有仓库或访问令牌之外的凭据。

## 使用方式

```powershell
$env:GITHUB_TOKEN = (gh auth token)
python scripts/sync-public-index.py
pwsh -NoProfile -File scripts/validate-readme.ps1 -CheckLinks
```

快照用于审阅证据，不会自动修改 `README.md`、`repo-descriptions.md` 或横幅。发布前应人工确认项目描述、平台范围与 Release 链接，再提交同步变更。

两个快照脚本均支持 `--output-dir <目录>`，默认仍为 `docs`；临时验证可以指定新目录，避免覆盖同一天已提交的快照。Actions 在临时目录生成并仅上传本次结果，保留在仓库中的日期快照不会混入 artifact。

个人和组织仓库列表均读取完整分页；组织只请求公开仓库。明确追踪的组织仓库缺失或不再公开时，脚本会在写入前报错，保留之前的审阅证据。

校验脚本会核对 README 与索引中的仓库数量、主要语言和归档状态，同时检查横幅可见数字与无障碍说明；快照与文案不一致时，先查公开证据，再人工修订文案。
