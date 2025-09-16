#!/usr/bin/env bash
# Slack Notification Script for Podcheck
# Based on dockcheck notify_slack.sh
# Requires: SLACK_WEBHOOK_URL
# Optional: SLACK_CHANNEL, SLACK_USERNAME, SLACK_ICON

# Check if required variables are set
if [[ -z "${SLACK_WEBHOOK_URL:-}" ]]; then
    echo "Error: SLACK_WEBHOOK_URL must be set in podcheck.config"
    exit 1
fi

# Optional Slack channel (if not using webhook default)
SLACK_CHANNEL_ARG=""
if [[ -n "${SLACK_CHANNEL:-}" ]]; then
    SLACK_CHANNEL_ARG=", \"channel\": \"${SLACK_CHANNEL}\""
fi

# Optional username override
SLACK_USERNAME="${SLACK_USERNAME:-podcheck}"

# Optional emoji icon
SLACK_ICON="${SLACK_ICON:-:whale:}"

# Prepare the JSON payload
JSON_PAYLOAD=$(cat <<EOF
{
    "username": "${SLACK_USERNAME}",
    "icon_emoji": "${SLACK_ICON}",
    "text": "${NOTIFICATION_TITLE}",
    "attachments": [
        {
            "color": "warning",
            "text": "${NOTIFICATION_MESSAGE}",
            "footer": "podcheck",
            "ts": $(date +%s)
        }
    ]${SLACK_CHANNEL_ARG}
}
EOF
)

# Send the notification
if curl -s -X POST \
    -H "Content-Type: application/json" \
    -d "${JSON_PAYLOAD}" \
    "${SLACK_WEBHOOK_URL}" > /dev/null; then
    echo "Slack notification sent successfully"
else
    echo "Failed to send Slack notification"
    exit 1
fi