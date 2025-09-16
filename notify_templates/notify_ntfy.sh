#!/usr/bin/env bash

# ntfy.sh notification template for podcheck v2
# Requires: NTFY_DOMAIN, NTFY_TOPIC_NAME
# Optional: NTFY_AUTH (user:password or :token format)

if [[ -z "${NTFY_DOMAIN:-}" ]] || [[ -z "${NTFY_TOPIC_NAME:-}" ]]; then
  echo "Error: NTFY_DOMAIN and NTFY_TOPIC_NAME must be configured"
  return 1
fi

# Prepare the ntfy message
if [[ -n "${NOTIFICATION_MESSAGE:-}" ]]; then
  # Build ntfy URL
  ntfy_url="${NTFY_DOMAIN}/${NTFY_TOPIC_NAME}"
  
  # Prepare curl arguments
  curl_args=(-s -o /dev/null --show-error --fail)
  curl_args+=(-H "Title: ${NOTIFICATION_TITLE:-Podcheck Notification}")
  curl_args+=(-d "${NOTIFICATION_MESSAGE}")
  
  # Add authentication if provided
  if [[ -n "${NTFY_AUTH:-}" ]]; then
    if [[ "${NTFY_AUTH}" == :* ]]; then
      # Token authentication
      curl_args+=(-H "Authorization: Bearer ${NTFY_AUTH:1}")
    else
      # User:password authentication
      curl_args+=(-u "${NTFY_AUTH}")
    fi
  fi
  
  # Send to ntfy
  if curl "${curl_args[@]}" "${ntfy_url}" ${CurlArgs:-} &>/dev/null; then
    return 0
  else
    echo "Failed to send ntfy notification"
    return 1
  fi
else
  echo "No notification message provided"
  return 1
fi
