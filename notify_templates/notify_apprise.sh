#!/usr/bin/env bash

# Apprise notification template for podcheck v2
# Supports both CLI and API modes
# Requires: APPRISE_PAYLOAD (for CLI mode) OR APPRISE_URL (for API mode)
# Optional: APPRISE_KEY (for API mode)

# Prepare the Apprise message
if [[ -n "${NOTIFICATION_MESSAGE:-}" ]]; then
  title="${NOTIFICATION_TITLE:-Podcheck Notification}"
  message="${NOTIFICATION_MESSAGE}"
  
  # Check if using CLI mode (APPRISE_PAYLOAD) or API mode (APPRISE_URL)
  if [[ -n "${APPRISE_PAYLOAD:-}" ]]; then
    # CLI mode - requires apprise command
    if ! command -v apprise &>/dev/null; then
      echo "Error: apprise command not found for CLI mode"
      return 1
    fi
    
    # Use apprise CLI with configured services
    if apprise -t "$title" -b "$message" ${APPRISE_PAYLOAD} &>/dev/null; then
      return 0
    else
      echo "Failed to send Apprise CLI notification"
      return 1
    fi
    
  elif [[ -n "${APPRISE_URL:-}" ]]; then
    # API mode - use curl to POST to Apprise API
    if curl -X POST \
            -F "title=$title" \
            -F "body=$message" \
            -F "tags=all" \
            "${APPRISE_URL}" \
            ${CurlArgs:-} &>/dev/null; then
      return 0
    else
      echo "Failed to send Apprise API notification"
      return 1
    fi
    
  else
    echo "Error: Either APPRISE_PAYLOAD (for CLI) or APPRISE_URL (for API) must be configured"
    return 1
  fi
else
  echo "No notification message provided"
  return 1
fi
