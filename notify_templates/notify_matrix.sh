#!/usr/bin/env bash

# Matrix notification template for podcheck v2
# Requires: MATRIX_SERVER_URL, MATRIX_ROOM_ID, MATRIX_ACCESS_TOKEN

if [[ -z "${MATRIX_SERVER_URL:-}" ]] || [[ -z "${MATRIX_ROOM_ID:-}" ]] || [[ -z "${MATRIX_ACCESS_TOKEN:-}" ]]; then
  echo "Error: MATRIX_SERVER_URL, MATRIX_ROOM_ID, and MATRIX_ACCESS_TOKEN must be configured"
  return 1
fi

# Prepare the Matrix message
if [[ -n "${NOTIFICATION_MESSAGE:-}" ]]; then
  # Escape special characters for JSON
  matrix_message="${NOTIFICATION_MESSAGE}"
  matrix_message="${matrix_message//\"/\\\"}"
  matrix_message="${matrix_message//$'\n'/\\n}"
  
  # Create Matrix message body
  msg_body="{\"msgtype\":\"m.text\",\"body\":\"${matrix_message}\"}"
  
  # Build Matrix URL
  matrix_url="${MATRIX_SERVER_URL}/_matrix/client/r0/rooms/${MATRIX_ROOM_ID}/send/m.room.message?access_token=${MATRIX_ACCESS_TOKEN}"
  
  # Send to Matrix
  if curl -s -o /dev/null --fail -X POST \
          "${matrix_url}" \
          -H 'Content-Type: application/json' \
          -d "$msg_body" \
          ${CurlArgs:-} &>/dev/null; then
    return 0
  else
    echo "Failed to send Matrix notification"
    return 1
  fi
else
  echo "No notification message provided"
  return 1
fi
