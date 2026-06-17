#!/usr/bin/env bash

# Discord notification template for podcheck v2
# Requires: DISCORD_WEBHOOK_URL

if [[ -z "${DISCORD_WEBHOOK_URL:-}" ]]; then
  echo "Error: DISCORD_WEBHOOK_URL not configured"
  return 1
fi

if ! command -v jq &>/dev/null; then
  echo "Error: jq is required for Discord notifications"
  return 1
fi

# Prepare the Discord message
if [[ -n "${NOTIFICATION_MESSAGE:-}" ]]; then
  # Create Discord webhook payload
  discord_payload=$(jq -n \
    --arg content "${NOTIFICATION_MESSAGE}" \
    --arg title "${NOTIFICATION_TITLE:-Podcheck Notification}" \
    --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)" \
    '{
      content: $content,
      username: "Podcheck",
      embeds: [
        {
          title: $title,
          description: $content,
          color: 3447003,
          timestamp: $timestamp
        }
      ]
    }')

  # Send to Discord
  if curl -H "Content-Type: application/json" \
          -d "$discord_payload" \
          "${DISCORD_WEBHOOK_URL}" \
          ${CurlArgs:-} &>/dev/null; then
    return 0
  else
    echo "Failed to send Discord notification"
    return 1
  fi
else
  echo "No notification message provided"
  return 1
fi

