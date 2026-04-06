# 小红书内容流水线 - 使用指南

## 快速导入

### 1. 安装 Skill
```bash
# 克隆到 skills 目录
git clone https://github.com/xuanqing-95/xhs-content-pipeline.git ~/.openclaw/skills/xhs-content-pipeline
```

### 2. 配置飞书多维表格
复制配置模板并填入你的飞书信息：
```bash
cp ~/.openclaw/skills/xhs-content-pipeline/config.example.yaml ~/.openclaw/skills/xhs-content-pipeline/config.yaml
```

然后编辑 `config.yaml`，填入：
- 飞书多维表格的 app_token
- 飞书群 ID（用于推送消息）
- 配图上传文件夹 Token
- 三个表格的 table_id

字段要求见 `references/tables.md`

### 3. 配置定时任务（可选）
```bash
openclaw cron add --name "xhs-daily-topic" \
  --cron "0 8 * * *" \
  --message "执行小红书每日选题推送..." \
  --channel feishu \
  --to 你的open_id
```

## 触发方式

在飞书群中发送以下关键词即可触发：
- 「推选题」
- 「开始选题」
- 「今天推什么」
- 「小红书流程」

或发送「小红书仿写」+ 链接，自动抓取内容并分析。

## 6步流程

1. **推选题** → 群里推送3个待选选题
2. **选题分析** → 用户选择后分析选题
3. **生成文案** → AI 生成小红书文案
4. **生成配图** → AI 生成4张配图
5. **写入表格** → 存入飞书表格
6. **推送草稿** → 完成，可直接复制发布

## 安全说明

- 配置文件 `config.yaml` 包含敏感凭证，已加入 `.gitignore`，不会提交到仓库
- 首次使用时必须复制 `config.example.yaml` 并填入自己的飞书信息

## 注意事项

- 整个流程在飞书群中自动执行
- 配图生成失败可跳过，文案继续
- 状态文件：`memory/xhs-pipeline-state.json`
