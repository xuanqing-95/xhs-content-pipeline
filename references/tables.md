# 表格配置速查

> ⚠️ **重要**：所有配置已迁移到 `config.yaml`，请勿在此文件硬编码！
> - 运行时加载：`~/.openclaw/skills/xhs-content-pipeline/config.yaml`
> - 用户首次使用：复制 `config.example.yaml` 为 `config.yaml` 并填写真实值

## 字段清单（通用参考）

### 选题库字段（采集数据时必填）

| 字段 | 类型 | 说明 |
|------|------|------|
| 选题标题 | Text | 内容标题 |
| 分类标签 | Text | 内容分类 |
| 来源平台 | SingleSelect | X/小红书/公众号等 |
| 原始链接 | Text | 原文链接 |
| 内容摘要 | Text | 30-50字摘要 |
| 推荐度 | SingleSelect | ⭐数量 |
| 适合平台 | MultiSelect | 适合发布平台 |
| 爆款分析 | Text | 为什么会火 |
| 创作方向建议 | Text | 建议创作方向 |
| 来源博主 | Text | 内容发布者 |
| 博主ID | Text | 博主唯一ID |
| 全文内容 | Text | 完整文本 |
| 浏览量 | Text | 阅读/播放量 |
| 点赞数 | Text | 点赞数 |
| 评论数 | Text | 评论数 |
| 转发数 | Text | 转发/分享数 |
| 发布时间 | DateTime | 发布时间（毫秒时间戳） |
| 采集时间 | DateTime | 采集时间（毫秒时间戳） |
| 选题状态 | SingleSelect | 待选/已推送/已使用 |

### 选题分析字段

| 字段 | 类型 | 说明 |
|------|------|------|
| 选题标题 | Text | 选题标题 |
| 选题方向 | Text | 用户选择的方向 |
| 目标人群 | Text | 目标人群 |
| 爆款潜力评分 | SingleSelect | ⭐/⭐⭐/⭐⭐⭐/⭐⭐⭐⭐/⭐⭐⭐⭐⭐ |
| 创作难度 | SingleSelect | 简单/中等/困难 |
| 原文标题 | Text | 原始标题 |
| 内容摘要 | Text | 内容摘要 |
| 来源平台 | Text | 来源平台 |
| 原文链接_超链 | Text | 原文链接 |

### 小红书内容生成库字段

| 字段 | 类型 | 说明 |
|------|------|------|
| 标题 | Text | 小红书标题 |
| 正文 | Text | 正文内容 |
| 标签 | Text | 标签 |
| 配图1-4 | Text | 配图链接（格式：{"link": "url", "text": "描述", "type": "url"}） |
| 选题来源 | Text | 选题标题 |
| 发布时间 | DateTime | 发布时间 |

## 飞书上传注意事项

- `feishu_drive_file` upload 的 folder_token 参数不生效
- **解决方法**：先上传到根目录，再用 move 移动到目标文件夹
- 必须在 upload 后立即 move，否则文件可能丢失
