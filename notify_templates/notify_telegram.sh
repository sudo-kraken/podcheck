#!/usr/bin/env bash

# Telegram notification template for podcheck v2
# Requires: TELEGRAM_TOKEN, TELEGRAM_CHAT_ID
# Optional: TELEGRAM_TOPIC_ID (for forum groups)

if [[ -z "${TELEGRAM_TOKEN:-}" ]] || [[ -z "${TELEGRAM_CHAT_ID:-}" ]]; then
  echo "Error: TELEGRAM_TOKEN and TELEGRAM_CHAT_ID must be configured"
  return 1
fi

# Prepare the Telegram message
if [[ -n "${NOTIFICATION_MESSAGE:-}" ]]; then
  # Escape special characters for JSON
  telegram_message="${NOTIFICATION_MESSAGE}"
  telegram_message="${telegram_message//\"/\\\"}"
  telegram_message="${telegram_message//$'\n'/\\n}"
  
  # Build Telegram URL
  telegram_url="https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage"
  
  # Create payload
  telegram_data="{\"chat_id\":\"${TELEGRAM_CHAT_ID}\",\"text\":\"${telegram_message}\""
  
  # Add topic ID if specified
  if [[ -n "${TELEGRAM_TOPIC_ID:-}" && "${TELEGRAM_TOPIC_ID}" != "0" ]]; then
    telegram_data="${telegram_data},\"message_thread_id\":\"${TELEGRAM_TOPIC_ID}\""
  fi
  
  telegram_data="${telegram_data},\"disable_notification\": false}"
  
  # Send to Telegram
  if curl -s -o /dev/null --fail -X POST \
          "${telegram_url}" \
          -H 'Content-Type: application/json' \
          -d "$telegram_data" \
          ${CurlArgs:-} &>/dev/null; then
    return 0
  else
    echo "Failed to send Telegram notification"
    return 1
  fi
else
  echo "No notification message provided"
  return 1
fi
