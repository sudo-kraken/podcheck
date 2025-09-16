#!/usr/bin/env bash

# Pushbullet notification template for podcheck v2
# Requires: PUSHBULLET_URL, PUSHBULLET_TOKEN

if [[ -z "${PUSHBULLET_URL:-}" ]] || [[ -z "${PUSHBULLET_TOKEN:-}" ]]; then
  echo "Error: PUSHBULLET_URL and PUSHBULLET_TOKEN must be configured"
  return 1
fi

# Check for jq dependency
if ! command -v jq &>/dev/null; then
  echo "Error: jq is required for Pushbullet notifications"
  return 1
fi

# Prepare the Pushbullet message
if [[ -n "${NOTIFICATION_MESSAGE:-}" ]]; then
  # Create JSON payload using jq
  json_payload=$(jq -n \
    --arg title "${NOTIFICATION_TITLE:-Podcheck Notification}" \
    --arg body "${NOTIFICATION_MESSAGE}" \
    '{body: $body, title: $title, type: "note"}')
  
  # Send to Pushbullet
  if echo "$json_payload" | curl -s -o /dev/null --show-error --fail -X POST \
          -H "Access-Token: ${PUSHBULLET_TOKEN}" \
          -H "Content-Type: application/json" \
          "${PUSHBULLET_URL}" \
          -d @- \
          ${CurlArgs:-} &>/dev/null; then
    return 0
  else
    echo "Failed to send Pushbullet notification"
    return 1
  fi
else
  echo "No notification message provided"
  return 1
fi
