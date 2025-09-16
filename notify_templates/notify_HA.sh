#!/usr/bin/env bash
# Home Assistant Notification Script for Podcheck
# Based on dockcheck notify_HA.sh
# Sends notifications via Home Assistant webhook

# Check if required variables are set
if [[ -z "${HA_URL:-}" ]] || [[ -z "${HA_TOKEN:-}" ]]; then
    echo "Error: HA_URL and HA_TOKEN must be set in podcheck.config"
    exit 1
fi

# Default webhook ID if not specified
HA_WEBHOOK_ID="${HA_WEBHOOK_ID:-automation}"

# Construct the webhook URL
WEBHOOK_URL="${HA_URL}/api/webhook/${HA_WEBHOOK_ID}"

# Prepare the JSON payload
JSON_PAYLOAD=$(cat <<EOF
{
    "title": "${NOTIFICATION_TITLE}",
    "message": "${NOTIFICATION_MESSAGE}",
    "data": {
        "source": "podcheck",
        "timestamp": "$(date -Iseconds)"
    }
}
EOF
)

# Send the notification
if curl -s -X POST \
    -H "Authorization: Bearer ${HA_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "${JSON_PAYLOAD}" \
    "${WEBHOOK_URL}" > /dev/null; then
    echo "Home Assistant notification sent successfully"
else
    echo "Failed to send Home Assistant notification"
    exit 1
fi