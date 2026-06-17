#!/usr/bin/env bash

# Telegram notification template for podcheck v2
# Requires: TELEGRAM_TOKEN, TELEGRAM_CHAT_ID
# Optional: TELEGRAM_TOPIC_ID (for forum groups)

if [[ -z "${TELEGRAM_TOKEN:-}" ]] || [[ -z "${TELEGRAM_CHAT_ID:-}" ]]; then
  echo "Error: TELEGRAM_TOKEN and TELEGRAM_CHAT_ID must be configured"
  return 1
fi

if ! command -v jq &>/dev/null; then
  echo "Error: jq is required for Telegram notifications"
  return 1
fi

# Prepare the Telegram message
if [[ -n "${NOTIFICATION_MESSAGE:-}" ]]; then
  # Build Telegram URL
  telegram_url="https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage"

  # Create payload
  telegram_data=$(jq -n \
    --arg chat_id "${TELEGRAM_CHAT_ID}" \
    --arg text "${NOTIFICATION_MESSAGE}" \
    --arg topic "${TELEGRAM_TOPIC_ID:-}" \
    '{
      chat_id: $chat_id,
      text: $text,
      disable_notification: false
    } + (if $topic == "" or $topic == "0" then {} else {message_thread_id: $topic} end)')
  
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
