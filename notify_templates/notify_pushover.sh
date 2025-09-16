#!/usr/bin/env bash

# Pushover notification template for podcheck v2
# Requires: PUSHOVER_URL, PUSHOVER_USER_KEY, PUSHOVER_TOKEN

if [[ -z "${PUSHOVER_URL:-}" ]] || [[ -z "${PUSHOVER_USER_KEY:-}" ]] || [[ -z "${PUSHOVER_TOKEN:-}" ]]; then
  echo "Error: PUSHOVER_URL, PUSHOVER_USER_KEY, and PUSHOVER_TOKEN must be configured"
  return 1
fi

# Prepare the Pushover message
if [[ -n "${NOTIFICATION_MESSAGE:-}" ]]; then
  # Send to Pushover (matching dockcheck format)
  if curl -S -o /dev/null ${CurlArgs:-} -X POST \
          -F "token=${PUSHOVER_TOKEN}" \
          -F "user=${PUSHOVER_USER_KEY}" \
          -F "title=${NOTIFICATION_TITLE:-Podcheck Notification}" \
          -F "message=${NOTIFICATION_MESSAGE}" \
          "${PUSHOVER_URL}"; then
    echo "Pushover notification sent successfully"
    return 0
  else
    echo "Failed to send Pushover notification"
    return 1
  fi
else
  echo "No notification message provided"
  return 1
fi
