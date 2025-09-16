#!/usr/bin/env bash

# Generic notification template for podcheck v2
# This is a simple example that just prints to console
# You can modify this to integrate with any custom notification system

# Prepare the generic notification
if [[ -n "${NOTIFICATION_MESSAGE:-}" ]]; then
  # Get hostname
  if [[ -s "/etc/hostname" ]]; then
    FromHost=$(cat /etc/hostname)
  elif command -v hostname &>/dev/null; then
    FromHost=$(hostname)
  else
    FromHost="podcheck-host"
  fi
  
  # Output the notification (customize this section for your needs)
  echo "=== Generic Notification ==="
  echo "Host: $FromHost"
  echo "Title: ${NOTIFICATION_TITLE:-Podcheck Notification}"
  echo "Message:"
  echo "${NOTIFICATION_MESSAGE}"
  echo "=========================="
  
  # Add your custom notification logic here
  # Examples:
  # - Write to a file: echo "${NOTIFICATION_MESSAGE}" > /path/to/notifications.log
  # - Call a webhook: curl -X POST -d "${NOTIFICATION_MESSAGE}" https://your-webhook-url
  # - Send to syslog: logger -t podcheck "${NOTIFICATION_MESSAGE}"
  
  return 0
else
  echo "No notification message provided"
  return 1
fi
