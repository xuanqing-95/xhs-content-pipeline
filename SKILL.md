---
name: xhs-content-pipeline
description: |
  小红书内容自动化流水线。6步完成：选题→分析→文案→配图→归档→草稿。
  触发词：推选题、开始选题、今天推什么、小红书流程、发选题、开始写、推内容、今天写什么。
  「小红书仿写」+链接 → 抓取并直接进入分析。
  用户回复选题编号（1/2/3）或方向编号 → 继续流程。
  首次使用自动进入初始化向导。「初始化小红书表格」或 +init → 自动建表。
version: 3.1.0
---

# 小红书内容自动化流水线

## 引用文件

| 文件 | 用途 | 何时加载 |
|------|------|----------|
| `references/config.md` | 默认 ID/Token（本地安装使用） | 无动态配置时的 fallback |
| `references/tables.md` | 表格字段定义 | 写入表格前 / 初始化建表时 |
| `references/brand.md` | 品牌风格 + 配图 prompt 模板 | 生成配图前 |
| `references/sensitive-words.md` | 敏感词替换规则 | 生成文案后 |

### 配置优先级

```
1. memory/xhs-pipeline-config.json（用户动态配置，优先）
2. references/config.md（静态默认配置，fallback）
```

每次流程开始时：
1. 检查 `memory/xhs-pipeline-config.json` 是否存在
2. 存在 → 从中读取 app_token、table_id、群 ID、文件夹 token
3. 不存在 → 进入**初始化向导**（见下方）

---

---

## 初始化向导

**触发条件：** 收到触发词，但 `memory/xhs-pipeline-config.json` 不存在。

**向导流程（一问一答，逐步引导）：**

### 第一步：确认推送目标

询问用户：
```
👋 检测到这是首次使用小红书流水线，需要先做一次初始化配置。

第 1 步：内容要推送到哪里？
  A. 推送到某个飞书群（请告诉我群名称或群 ID）
  B. 在此私聊直接推送就好
```

- 选 A，用户回复群名 → 调用 `feishu_chat(action=search, query=群名)` → 展示候选群列表 → 让用户确认
- 选 A，用户回复 `oc_xxx` → 直接调用 `feishu_chat(action=get, chat_id=xxx)` 验证 → 确认群名
- 选 B → 暂存 `chat_mode=private`，`chat_id` 留空
- 确认后暂存到内存变量（还不写文件）

### 第二步：确认多维表格

询问用户：
```
第 2 步：需要我帮你新建一个多维表格，还是使用已有的？

  A. 帮我新建（推荐，一键完成所有表格和字段配置）
  B. 使用已有的表格（请提供 app_token）
```

**选 A（新建）：** → 执行「自动建表」流程（见下方 +init 命令）

**选 B（已有）：** 
1. 询问 app_token（从表格 URL 里取）
2. 调用 `feishu_bitable_app(action=get, app_token=xxx)` 验证表格是否存在
3. 列出现有数据表，让用户确认或手动映射三张表的 table_id
4. 验证字段是否完整（对比 `references/tables.md`，缺字段则提示）

### 第三步：确认配图文件夹（可选）

询问用户：
```
第 3 步：配图要保存到哪个飞书云空间文件夹？

  A. 帮我新建一个「小红书配图」文件夹
  B. 使用已有文件夹（请提供文件夹 token 或 URL）
  C. 跳过（不保存配图到云空间）
```

- 选 A → 调用 `feishu_drive_file(action=list)` 获取根目录，然后在根目录创建文件夹（⚠️ 飞书 API 不支持直接创建文件夹，告知用户手动创建后提供 token）
- 选 B → 从 URL 提取 folder_token，记录
- 选 C → folder_token 置空

### 写入配置文件

所有信息收集完毕后，写入 `memory/xhs-pipeline-config.json`：

```json
{
  "app_token": "xxx",
  "tables": {
    "topics": "tblXXX",
    "analysis": "tblXXX",
    "content": "tblXXX"
  },
  "chat_id": "oc_xxx",
  "chat_mode": "group",
  "image_folder_token": "xxx",
  "bitable_url": "https://xxx.feishu.cn/base/xxx",
  "initialized_at": "2026-04-07T00:00:00+08:00"
}
```

`chat_mode` 取值：`group`（推到群）或 `private`（回到当前私聊）。选择私聊模式时 `chat_id` 留空。

配置完成后告知用户，然后**自动开始正式流程（从 Step 1）**。

---

## +init 命令（自动建表）

**触发词：** 「初始化小红书表格」/ 「帮我建表」/ `+init`

**执行步骤：**

1. 创建多维表格应用：
   ```
   feishu_bitable_app(action=create, name="小红书内容管理")
   → 获得 app_token
   ```

2. 读取 `references/tables.md` 的字段定义

3. 创建**选题库**数据表（含全部 19 个字段）：
   - 字段类型映射：Text→1, SingleSelect→3, MultiSelect→4, DateTime→5
   - 一次性传入 `table.fields` 数组创建

4. 创建**选题分析**数据表（含 9 个字段）

5. 创建**小红书内容生成库**数据表

6. 将默认创建的空表（通常名为「数据表1」）重命名或删除

7. 把生成的 app_token + 三个 table_id 写入 `memory/xhs-pipeline-config.json`

8. 推送结果：
   ```
   ✅ 多维表格已创建完成！
   
   📊 表格链接：https://xxx.feishu.cn/base/xxx
   
   已创建：
   - 选题库（19 个字段）
   - 选题分析（9 个字段）
   - 小红书内容生成库
   
   接下来告诉我推送消息的飞书群名称，完成最后配置 👇
   ```

9. 建表完成后，**继续初始化向导的第一步**（确认飞书群）

---

## 状态机

### Session ID（多实例隔离）

**每条消息收到时，第一步先确定 session_id：**

```
群聊消息：session_id = 群 chat_id（oc_xxx）
私聊消息：session_id = 发送者 open_id（ou_xxx）
```

**状态文件按 session_id 独立存储：**

```
memory/xhs-state-{session_id}.json
```

例如：
- 群聊：`memory/xhs-state-oc_602f35b88d99d65d32d21b4510260e0f.json`
- 私聊：`memory/xhs-state-ou_06514039f558974937472f40ccad0169.json`

这样同一个 skill 可以同时服务多个群和多个私聊，互不干扰。

### 状态流转

```
step 0  → 空闲，等待触发词或仿写链接
step 1  → 已推送选题，等待用户回复 1/2/3
step 2  → 已推送分析，等待用户回复 方向1/方向2/自定义
step 3  → 生成文案（自动）
step 4  → 生成配图（自动）
step 5  → 写入表格（自动）
step 6  → 推送草稿（自动）→ 完成后回到 step 0
```

**状态文件结构：**
```json
{
  "sessionId": "oc_xxx 或 ou_xxx",
  "active": true,
  "step": 1,
  "topics": ["标题1", "标题2", "标题3"],
  "topicRecordIds": ["recXXX", "recYYY", "recZZZ"],
  "selectedTopic": null,
  "selectedTopicData": {},
  "selectedDirection": null,
  "copyText": null,
  "imageTokens": [],
  "updatedAt": "2026-04-07T03:00:00+08:00",
  "error": null
}
```

**核心规则：**
1. 每步执行前后都写状态文件（`memory/xhs-state-{session_id}.json`）
2. step 3→4→5→6 自动连续执行，不停顿
3. step 1 和 step 2 需要等待用户回复
4. `active=true` 且 `updatedAt` 超过 2 小时 → 自动重置为 step 0（防僵死）

---

## 消息路由

收到飞书消息时（**群聊和私聊均支持**），按以下顺序判断：

```
0. 确定 session_id：群聊 → chat_id，私聊 → sender open_id
1. 读 memory/xhs-state-{session_id}.json
2. if state.active && 未超时:
     → 按 state.step 解析用户输入，继续流程
3. elif 消息含「初始化小红书表格」或 +init:
     → 执行 +init 自动建表流程
4. elif 消息含「仿写」+链接:
     → 检查配置 → 未配置则先走初始化向导
     → 抓取链接 → 写入选题库 → 跳到 step 2
5. elif 消息含触发词:
     → 检查 memory/xhs-pipeline-config.json 是否存在
     → 不存在 → 进入初始化向导
     → 存在 → 从 step 1 开始正式流程
6. else:
     → 不处理（无关消息）
```

⚠️ **多实例并发说明：** 私聊和不同群聊使用各自独立的状态文件，流程互不干扰。管理员私聊触发的流程和群里正在进行的流程可以同时存在。

**用户输入解析：**

| step | 预期输入 | 解析 |
|------|----------|------|
| 1 | `1` / `2` / `3` | topics[N-1] |
| 2 | `1` / `方向1` / `2` / `方向2` / 任意文字 | 对应方向或自定义 |
| 3-6 | 无需输入 | 自动执行 |

⚠️ 数字 `1/2/3` 在 step 1 和 step 2 含义不同，**必须先读 state.step**。

---

## 流程详解

### Step 1：推送选题

1. 读 `references/config.md` 获取配置
2. 从**选题库**取数据（filter: `选题状态 is 待选`）
   - ⚠️ 用 `is`，不要用 `isNot`（否则捞到无状态的旧记录）
   - 优先今天采集的 → 优先「适合平台」含小红书的 → 按推荐度降序
   - 内容摘要为空或 `-` 的降权
3. 取前 3 个，推送到群（用 `message` 工具）
4. 消息末尾附选题库链接
5. 将 3 个选题状态更新为「已推送」
6. 写状态：`step=1, topics=[...], topicRecordIds=[...]`

**飞书数据解析注意：** `选题标题` 字段返回数组格式，取 `fields["选题标题"][0].text`。

### Step 2：选题分析

1. 用户选择后，将选中选题状态更新为「已使用」
2. 用五维框架分析（见下方模板），生成 2 个方向
3. 写入**选题分析表**
4. 推送分析结果到群，末尾写「请回复 方向1 或 方向2」
5. 写状态：`step=2, selectedTopic=..., selectedDirection=null`
6. **等待用户回复方向后才能进 step 3**

**五维分析模板：**
```
选题：{title}
内容摘要：{summary}

| 维度 | 评分 | 依据 |
|------|------|------|
| 普遍痛点 | X/5 | 切中多少人的恐惧/焦虑 |
| 群体共鸣 | X/5 | 引发情绪共振+发声参与 |
| 身份认同 | X/5 | 命中哪个群体的标签 |
| 热点赋能 | X/5 | 能否借用当前热点 |
| 新知价值 | X/5 | 提供什么新东西 |

总分：X/25，潜力等级：S(20+)/A(15-19)/B(10-14)/C(5-9)/D(<5)

方向1：[角度]，适合[人群]，预计[效果]
方向2：[角度]，适合[人群]，预计[效果]
```

**写入选题分析表字段映射：**

| 字段 | 值来源 |
|------|--------|
| 选题标题 | selectedTopic |
| 选题方向 | 用户选择的方向 |
| 目标人群 | 分析结果提取 |
| 爆款潜力评分 | 五维总分映射（20+→⭐⭐⭐⭐⭐ / 15-19→⭐⭐⭐⭐ / 10-14→⭐⭐⭐ / 5-9→⭐⭐ / <5→⭐） |
| 创作难度 | 简单/中等/困难 |
| 原文标题 | 选题库原始标题 |
| 内容摘要 | 选题库摘要 |
| 来源平台 | 选题库来源 |
| 原文链接_超链 | 选题库链接 |

### Step 3：生成文案

**前置条件：** `state.selectedDirection` 不为 null。

1. 生成小红书文案（标题 + 正文 + 标签）
2. 读 `references/sensitive-words.md`，执行敏感词替换
3. 推送到群
4. 写状态 → **立即执行 Step 4**

### Step 4：生成配图

1. 读 `references/brand.md` 获取风格和 prompt 模板
2. 用 `image_generate` 工具生成 4 张配图（aspectRatio: `3:4`）
   - 逐张生成，不并行
   - 单张失败则跳过，继续下一张
3. 成功的图片上传到飞书云空间目标文件夹（见 config.md）
   - 上传流程：upload → move 到目标文件夹（folder_token 参数不生效的 workaround）
4. 推送配图结果到群
5. **全部失败也不停，推送「配图生成失败，请手动补充」→ 继续 Step 5**

### Step 5：写入内容生成库

1. 读 `references/tables.md` 获取字段格式
2. 写入**小红书内容生成库**
   - URL 字段格式：`{"link": "url", "text": "描述", "type": "url"}`
   - 正文内容中英文双引号 `"` 替换为中文 `""`
3. 写入失败 → 跳过，继续 Step 6

### Step 6：推送草稿

推送完整草稿到群：

```
📝 小红书完整草稿（可直接发布）

标题：xxx

正文：
（完整正文，保留 emoji 和段落）

标签：#标签1 #标签2 #标签3

配图：
P1（描述）：飞书链接
P2（描述）：飞书链接
...
（无配图则省略此部分）

📊 内容生成库：[查看表格](链接)
```

完成后写状态：`active=false, step=0`，清空所有临时字段。

---

## 仿写模式

触发：消息含「小红书仿写」或「仿写」+ URL

1. **检查配置**：读 `memory/xhs-pipeline-config.json`
   - 不存在 → 先暂存仿写意图和 URL 到内存变量，进入初始化向导
   - 初始化完成后自动继续执行仿写流程
   - 存在 → 直接执行下方步骤
2. 用 `web_fetch` 抓取链接内容
3. 提取标题、正文、博主信息、互动数据
4. 写入选题库（所有字段，见 `references/tables.md`）
5. 写状态：`step=2, selectedTopic=刚入库的标题`
6. 直接执行 Step 2（跳过 Step 1）

---

## 消息发送规则

根据触发来源决定回复方式：

| 触发来源 | 发送工具 | 参数 |
|----------|----------|------|
| 飞书群聊 | `message` 工具（机器人身份） | `target`: 群 chat_id，从配置或触发消息上下文读取 |
| 飞书私聊 | `message` 工具（机器人身份） | `target`: 当前私聊用户 open_id |
| 初始化向导中 | `message` 工具 | 回复到当前对话（群或私聊），不需要预设 target |

**判断规则：**
```
如果 memory/xhs-pipeline-config.json 中有 chat_id（群 ID）:
  → 后续所有流程推送到该群
  → 初始化向导对话本身回到触发来源（私聊 or 群）
如果配置中无 chat_id 或配置为私聊模式:
  → 所有消息回到触发来源
```

**私聊模式下的初始化向导调整：**
- 第一步「确认飞书群」改为可选：
  ```
  您希望内容推送到哪里？
  A. 推送到某个飞书群（请告诉我群名称）
  B. 直接在这里私聊推送（内容发到此对话）
  ```
- 选 B → chat_id 留空，所有流程消息回到当前私聊

---

## 硬性约束

1. **禁止使用 `feishu_im_user_message` 发消息**，统一用 `message` 工具
2. **文案结尾禁止出现「等XX配图」类文字**
3. **Step 3→4→5→6 必须自动连续执行**
4. **选题从选题库取**，不是选题分析库
5. **配图失败不阻断流程**，跳过继续
