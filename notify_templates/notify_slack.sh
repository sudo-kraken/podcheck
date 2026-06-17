#!/usr/bin/env bash
# Slack Notification Script for Podcheck
# Based on dockcheck notify_slack.sh
# Requires: SLACK_WEBHOOK_URL
# Optional: SLACK_CHANNEL, SLACK_USERNAME, SLACK_ICON

# Check if required variables are set
if [[ -z "${SLACK_WEBHOOK_URL:-}" ]]; then
    echo "Error: SLACK_WEBHOOK_URL must be set in podcheck.config"
    return 1
fi

if ! command -v jq &>/dev/null; then
    echo "Error: jq is required for Slack notifications"
    return 1
fi

# Optional Slack channel (if not using webhook default)
SLACK_CHANNEL="${SLACK_CHANNEL:-}"

# Optional username override
SLACK_USERNAME="${SLACK_USERNAME:-podcheck}"

# Optional emoji icon
SLACK_ICON="${SLACK_ICON:-:whale:}"

# Prepare the JSON payload
JSON_PAYLOAD=$(jq -n \
    --arg username "$SLACK_USERNAME" \
    --arg icon "$SLACK_ICON" \
    --arg title "${NOTIFICATION_TITLE:-Podcheck Notification}" \
    --arg message "${NOTIFICATION_MESSAGE:-}" \
    --arg channel "$SLACK_CHANNEL" \
    --argjson ts "$(date +%s)" \
    '{
        username: $username,
        icon_emoji: $icon,
        text: $title,
        attachments: [
            {
                color: "warning",
                text: $message,
                footer: "podcheck",
                ts: $ts
            }
        ]
    } + (if $channel == "" then {} else {channel: $channel} end)')

# Send the notification
if curl -s -X POST \
    -H "Content-Type: application/json" \
    -d "${JSON_PAYLOAD}" \
    "${SLACK_WEBHOOK_URL}" > /dev/null; then
    echo "Slack notification sent successfully"
    return 0
else
    echo "Failed to send Slack notification"
    return 1
fi
