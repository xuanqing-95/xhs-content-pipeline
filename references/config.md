# 配置中心

所有 ID、Token、链接集中在此文件。迁移时只改这里。

> ⚠️ **首次使用说明**
> 
> 此文件为静态默认配置（fallback）。推荐直接触发「推选题」或发送 `+init`，
> 让初始化向导自动引导配置，完成后自动生成 `memory/xhs-pipeline-config.json`。
> 
> 如需手动配置，将下方占位符替换为你的真实值即可。

## 飞书多维表格

| 配置项 | 值 |
|--------|-----|
| app_token | `YOUR_APP_TOKEN` |
| 表格链接 | https://YOUR_FEISHU_DOMAIN/base/YOUR_APP_TOKEN |

### 数据表

| 数据表 | table_id | 用途 |
|--------|----------|------|
| 选题库 | `YOUR_TOPICS_TABLE_ID` | Step 1 取数据 |
| 选题分析 | `YOUR_ANALYSIS_TABLE_ID` | Step 2 写入分析 |
| 内容生成库 | `YOUR_CONTENT_TABLE_ID` | Step 5 写入成品 |

## 飞书资源

| 资源 | ID/Token |
|------|----------|
| 飞书群 | `YOUR_CHAT_ID` |
| 配图文件夹 | `YOUR_FOLDER_TOKEN` |
| 文件夹链接 | https://YOUR_FEISHU_DOMAIN/drive/folder/YOUR_FOLDER_TOKEN |

## 消息发送

所有群聊消息使用 `message` 工具：
- `channel`: feishu
- `target`: YOUR_CHAT_ID
