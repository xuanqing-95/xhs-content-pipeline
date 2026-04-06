# 表格字段定义

## 选题库（tblBBoGrB5W6DfB4）

### 读取筛选

```json
{
  "conjunction": "and",
  "conditions": [
    {"field_name": "选题状态", "operator": "is", "value": ["待选"]}
  ]
}
```

### 状态流转

```
待选 → 已推送（Step 1 推送后）→ 已使用（Step 2 用户选中后）
```

### 完整字段清单

写入选题库时必须填充以下字段：

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| 选题标题 | Text | 内容标题 | 道家秘传5招！三分钟快速恢复精气神！ |
| 分类标签 | Text | 内容分类 | 养生疗愈 |
| 来源平台 | SingleSelect | X/小红书/公众号等 | X |
| 原始链接 | Text | 原文链接 | https://twitter.com/i/status/xxx |
| 内容摘要 | Text | 30-50字摘要 | 道家秘传5招快速恢复精气神... |
| 推荐度 | SingleSelect | ⭐ 数量 | ⭐⭐⭐⭐⭐ |
| 适合平台 | MultiSelect | 适合发布平台 | 小红书 |
| 爆款分析 | Text | 为什么会火 | 实操性强+具体方法+易执行 |
| 创作方向建议 | Text | 建议创作方向 | 可做成系列：道家养生功法 |
| 来源博主 | Text | 内容发布者 | 健康指南 |
| 博主ID | Text | 博主唯一ID | 1693066388162916352 |
| 全文内容 | Text | 完整文本 | （完整推文内容） |
| 浏览量 | Text | 阅读/播放量 | 76865 |
| 点赞数 | Text | 点赞数 | 815 |
| 评论数 | Text | 评论数 | 4 |
| 转发数 | Text | 转发/分享数 | 210 |
| 发布时间 | DateTime | 毫秒时间戳 | 1733203629000 |
| 采集时间 | DateTime | 毫秒时间戳 | 1774688163000 |
| 选题状态 | SingleSelect | 待选/已推送/已使用 | 待选 |

### 数据解析注意

飞书返回的 `选题标题` 字段是数组格式：
```
fields["选题标题"][0].text  → 实际标题文本
```

---

## 选题分析表（tblQ8BCiybOzQa2z）

Step 2 写入。

| 字段 | 类型 |
|------|------|
| 选题标题 | Text |
| 选题方向 | Text |
| 目标人群 | Text |
| 爆款潜力评分 | SingleSelect（⭐ ~ ⭐⭐⭐⭐⭐） |
| 创作难度 | SingleSelect（简单/中等/困难） |
| 原文标题 | Text |
| 内容摘要 | Text |
| 来源平台 | Text |
| 原文链接_超链 | Text |

---

## 小红书内容生成库（tblcdl9yD51wZHVt）

Step 5 写入。

### 注意事项

- URL 字段格式：`{"link": "url", "text": "描述", "type": "url"}`
- 正文中英文双引号 `"` 替换为中文 `""`（否则 JSON 解析失败）

---

## 飞书上传 Workaround

`feishu_drive_file` upload 的 `folder_token` 参数不生效。

**正确流程：**
1. upload 到根目录（不传 folder_token）
2. 从返回结果获取 file_token
3. 用 `feishu_drive_file` move 到目标文件夹
4. upload 后立即 move，不要延迟
