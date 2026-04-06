# 小红书内容流水线

OpenClaw Skill — 小红书内容自动化：选题→分析→文案→配图→归档→发布草稿。

## 安装

```bash
# 复制到 skills 目录
cp -r xhs-content-pipeline ~/.openclaw/skills/
```

## 配置

1. 编辑 `references/config.md`，填入你的飞书多维表格和群聊 ID
2. 确保飞书多维表格已建好三张数据表（字段定义见 `references/tables.md`）
3. （可选）配置定时任务：

```bash
openclaw cron add --name "xhs-daily-topic" \
  --cron "0 8 * * *" \
  --message "执行小红书每日选题推送" \
  --channel feishu \
  --to <你的open_id>
```

## 触发方式

在飞书群中发送：
- 「推选题」「开始选题」「今天推什么」「小红书流程」
- 「小红书仿写」+ 链接 → 自动抓取并分析

## 流程

```
Step 1  推选题    → 从选题库筛选 3 个推送到群
Step 2  选题分析  → 五维评分 + 2 个创作方向
Step 3  生成文案  → 小红书风格文案
Step 4  生成配图  → 4 张品牌风格配图
Step 5  写入表格  → 归档到内容生成库
Step 6  推送草稿  → 完整草稿，可直接发布
```

## 文件结构

```
xhs-content-pipeline/
├── SKILL.md                      # 主技能文件
├── README.md                     # 本文件
└── references/
    ├── config.md                 # 集中配置（ID/Token/链接）
    ├── tables.md                 # 表格字段定义
    ├── brand.md                  # 品牌风格 + 配图 prompt 模板
    └── sensitive-words.md        # 敏感词替换规则
```

## 注意事项

- 配图生成失败可跳过，不阻断流程
- 状态文件：`memory/xhs-pipeline-state.json`
- 迁移到新环境只需修改 `references/config.md`
