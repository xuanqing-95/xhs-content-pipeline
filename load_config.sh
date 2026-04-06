#!/bin/bash
# 从 config.yaml 加载配置
CONFIG_FILE="$(dirname "$0")/config.yaml"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "错误：config.yaml 不存在，请复制 config.example.yaml 为 config.yaml 并配置"
  exit 1
fi

# 解析 YAML（简单实现）
get_config() {
  local key="$1"
  grep "^${key}:" "$CONFIG_FILE" | cut -d'"' -f2
}

# 输出配置（供其他脚本 source）
export XHS_APP_TOKEN=$(get_config "app_token")
export XHS_CHAT_ID=$(get_config "chat_id")
export XHS_IMAGE_FOLDER=$(get_config "image_folder_token")
export XHS_TOPIC_TABLE=$(get_config "topic_table_id")
export XHS_ANALYSIS_TABLE=$(get_config "analysis_table_id")
export XHS_CONTENT_TABLE=$(get_config "content_table_id")
