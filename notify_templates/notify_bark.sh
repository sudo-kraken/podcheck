#!/usr/bin/env bash

# Bark notification template for podcheck v2
# Requires: BARK_KEY
# Optional: BARK_SERVER_URL, BARK_SOUND, BARK_GROUP, BARK_ICON_URL

if [[ -z "${BARK_KEY:-}" ]]; then
  echo "Error: BARK_KEY must be configured"
  return 1
fi

if [[ -n "${NOTIFICATION_MESSAGE:-}" ]]; then

  bark_server="${BARK_SERVER_URL:-https://api.day.app}"
  bark_sound="${BARK_SOUND:-hello}"
  bark_group="${BARK_GROUP:-Podcheck}"
  bark_icon="${BARK_ICON_URL:-}"

  bark_title="${NOTIFICATION_SUBJECT:-Podcheck Update}"

  bark_body="## ${bark_title}\n\n---\n\n${NOTIFICATION_MESSAGE}"

  bark_payload=$(jq -n \
    --arg title "$bark_title" \
    --arg body "$bark_body" \
    --arg group "$bark_group" \
    --arg sound "$bark_sound" \
    --arg icon "$bark_icon" \
    '{
      "title": $title,
      "body": $body,
      "group": $group,
      "sound": $sound,
      "icon": $icon
    }')

  bark_url="${bark_server}/${BARK_KEY}"

  if curl -s -o /dev/null --fail -X POST \
          "${bark_url}" \
          -H 'Content-Type: application/json; charset=utf-8' \
          -d "$bark_payload" \
          ${CurlArgs:-} &>/dev/null; then
    return 0
  else
    echo "Failed to send Bark notification"
    return 1
  fi
else
  echo "No notification message provided"
  return 1
fi
