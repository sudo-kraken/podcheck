#!/usr/bin/env bash
# Home Assistant Notification Script for Podcheck
# Based on dockcheck notify_HA.sh
# Requires: HA_URL, HA_TOKEN
# Optional: HA_WEBHOOK_ID (default: automation)

# Check if required variables are set
if [[ -z "${HA_URL:-}" ]] || [[ -z "${HA_TOKEN:-}" ]]; then
    echo "Error: HA_URL and HA_TOKEN must be set in podcheck.config"
    return 1
fi

if ! command -v jq &>/dev/null; then
    echo "Error: jq is required for Home Assistant notifications"
    return 1
fi

# Default webhook ID if not specified
HA_WEBHOOK_ID="${HA_WEBHOOK_ID:-automation}"

# Construct the webhook URL
WEBHOOK_URL="${HA_URL}/api/webhook/${HA_WEBHOOK_ID}"

# Prepare the JSON payload
JSON_PAYLOAD=$(jq -n \
    --arg title "${NOTIFICATION_TITLE:-Podcheck Notification}" \
    --arg message "${NOTIFICATION_MESSAGE:-}" \
    --arg timestamp "$(date -Iseconds)" \
    '{
        title: $title,
        message: $message,
        data: {
            source: "podcheck",
            timestamp: $timestamp
        }
    }')

# Send the notification
if curl -s -X POST \
    -H "Authorization: Bearer ${HA_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "${JSON_PAYLOAD}" \
    "${WEBHOOK_URL}" > /dev/null; then
    echo "Home Assistant notification sent successfully"
    return 0
else
    echo "Failed to send Home Assistant notification"
    return 1
fi
