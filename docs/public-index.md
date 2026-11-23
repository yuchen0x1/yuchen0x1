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
