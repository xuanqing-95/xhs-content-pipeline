---
name: xhs-content-pipeline
description: |
  小红书内容自动化流水线。6步完成：选题→分析→文案→配图→归档→草稿。
  触发词：推选题、开始选题、今天推什么、小红书流程、发选题、开始写、推内容、今天写什么。
  「小红书仿写」+链接 → 抓取→自动分析→直接生成内容，无需确认方向。
  用户回复选题编号（1/2/3）或方向编号 → 继续流程。
  首次使用自动进入初始化向导。「初始化小红书表格」或 +init → 自动建表。
  「记录发布」+链接 → 存入内容生成库待追踪。「同步数据」 → 批量抓取已发布笔记最新数据。
  「回填数据」+标题关键词 → 手动更新发布数据。「复盘」/「数据分析」 → 运行复盘分析。
version: 4.1.0
---

# 小红书内容自动化流水线

## 引用文件

| 文件 | 用途 | 何时加载 |
|------|------|----------|
| `references/config.md` | 默认 ID/Token（fallback） | 无动态配置时 |
| `references/tables.md` | 表格字段定义 + 爆款评级规则 | 写入表格前 / 建表时 |
| `references/brand.md` | 品牌风格 + 配图 prompt 模板 | 生成配图前 |
| `references/sensitive-words.md` | 敏感词替换规则 | 生成文案后 |
| `references/workflows.md` | 各模式详细流程 | 执行对应模式前 |

### 配置优先级

```
1. memory/xhs-pipeline-config.json（优先）
2. references/config.md（fallback）
```

每次流程开始前检查 `memory/xhs-pipeline-config.json`，不存在则进入**初始化向导**。

---

## 消息路由

收到飞书消息时（群聊和私聊均支持）：

```
0. session_id：群聊 → chat_id，私聊 → sender open_id
1. 读 memory/xhs-state-{session_id}.json
2. if state.active && 未超时(2h) → 按 state.step 继续流程
3. elif 含「初始化小红书表格」或 +init → 执行 +init 建表
4. elif 含「记录发布」+ URL → 执行记录发布模式
5. elif 含「同步数据」→ 执行数据同步模式
6. elif 含「回填数据」→ 执行数据回填模式
7. elif 含「复盘」或「数据分析」→ 执行复盘分析模式
8. elif 含「仿写」+ URL → 执行仿写模式
9. elif 含触发词 → 检查配置，无则初始化向导，有则从 Step 1 开始
10. else → 不处理
```

**用户输入解析（有 active 状态时）：**

| step | 预期输入 | 解析 |
|------|----------|------|
| 1 | `1` / `2` / `3` | topics[N-1] |
| 2 | `1/方向1` / `2/方向2` / 任意文字 | 对应方向或自定义 |
| 3-6 | 无需输入 | 自动执行 |

⚠️ 数字 `1/2/3` 在 step 1 和 step 2 含义不同，**必须先读 state.step**。

---

## 状态机

状态文件：`memory/xhs-state-{session_id}.json`（每个会话独立，互不干扰）

```
step 0 → 空闲
step 1 → 已推送选题，等用户回复 1/2/3
step 2 → 已推送分析，等用户回复方向
step 3-6 → 自动连续执行（文案→配图→归档→草稿）
```

状态结构：
```json
{
  "sessionId": "oc_xxx 或 ou_xxx",
  "active": true, "step": 1,
  "topics": [], "topicRecordIds": [],
  "selectedTopic": null, "selectedTopicData": {},
  "selectedDirection": null, "copyText": null,
  "imageTokens": [], "updatedAt": "ISO时间戳", "error": null
}
```

规则：每步前后写状态；step 3→6 不停顿；active=true 且超 2h → 重置为 step 0。

---

## 主流程（Step 1-6）

详见 `references/workflows.md` → 「主流程」章节。

关键要点：
- Step 1：从选题库取 `选题状态 is 待选` 的记录，filter 用 `is` 不用 `isNot`
- Step 2：五维分析 → 生成 2 个方向 → 等用户选
- Step 3-6：文案（含敏感词替换）→ 配图（逐张生成，失败跳过）→ 写入内容生成库 → 推送草稿
- 草稿发出后，写状态 `active=false, step=0`

**飞书数据解析：** `fields["选题标题"][0].text`

---

## 仿写模式

触发：消息含「仿写」+ URL

仿写方向已确定，**跳过所有人工确认，直接到 Step 3**。详见 `references/workflows.md` → 「仿写模式」。

核心规则：**不生成方向 1/2，不在 Step 2 停留等待**，自动分析后直接进入文案生成。

---

## 记录发布模式

触发：「记录发布」+ 小红书笔记 URL

**执行：**
1. 用 `web_fetch` 抓取笔记页面，提取标题、点赞、收藏等公开数据
2. 在**内容生成库**中按标题模糊匹配，找到对应草稿记录
3. 找到 → 更新：发布时间（当前时间）、发布状态→「已发布」、笔记链接、当前公开数据
4. 未找到 → 新建记录，填入抓取到的信息，发布状态→「已发布」
5. 回复确认，告知已记录

---

## 数据同步模式

触发：「同步数据」

**执行：**
1. 从**内容生成库**拉取所有「已发布」记录，筛选有笔记链接的条目
2. 逐条用 `web_fetch` 抓取最新公开数据（点赞/收藏）
   - 每条间隔 1 秒，避免频率过高
   - 单条失败则跳过，继续下一条
3. 对有变化的记录：更新数据字段，按爆款评级规则重新计算 S/A/B/C/D
4. 推送汇总结果：「共同步 N 条，X 条有数据变化」

---

## 数据回填模式

触发：「回填数据」+ 标题关键词

手动输入数据更新，详见 `references/workflows.md` → 「数据回填模式」。

---

## 复盘分析模式

触发：「复盘」/ 「数据分析」/ 「复盘上周」/ 「复盘本月」

拉取已发布数据 → 分析爆款/踩雷规律 → 输出报告 → 存入 `memory/xhs-review-{YYYY-MM}.md`。

详见 `references/workflows.md` → 「复盘分析模式」。

---

## 初始化向导 & +init

详见 `references/workflows.md` → 「初始化向导」和「+init 建表」章节。

---

## 消息发送规则

统一使用 `message` 工具（机器人身份）：
- 有配置的群 chat_id → 发到群
- 无 chat_id 或私聊模式 → 回到当前对话

---

## 硬性约束

1. **禁止用 `feishu_im_user_message`**，统一用 `message` 工具
2. **文案结尾禁止出现「等XX配图」类文字**
3. **Step 3→4→5→6 自动连续执行，不停顿**
4. **选题从选题库取**，不是分析表
5. **配图失败不阻断流程**，跳过继续
6. **仿写模式不在 Step 2 停留**，自动完成分析直接进 Step 3
7. **仿写模式不生成「方向1/方向2」**，只有原文方向
