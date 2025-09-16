#!/usr/bin/env bash

# SMTP notification template for podcheck v2
# Requires: SMTP_MAIL_FROM, SMTP_MAIL_TO
# Optional: SMTP_SUBJECT_TAG

if [[ -z "${SMTP_MAIL_FROM:-}" ]] || [[ -z "${SMTP_MAIL_TO:-}" ]]; then
  echo "Error: SMTP_MAIL_FROM and SMTP_MAIL_TO must be configured"
  return 1
fi

# Check for msmtp or ssmtp
MSMTP=$(which msmtp 2>/dev/null)
SSMTP=$(which ssmtp 2>/dev/null)

if [[ -n "$MSMTP" ]]; then
  MailPkg="$MSMTP"
elif [[ -n "$SSMTP" ]]; then
  MailPkg="$SSMTP"
else
  echo "Error: No msmtp or ssmtp binary found in PATH"
  return 1
fi

# Prepare the email
if [[ -n "${NOTIFICATION_MESSAGE:-}" ]]; then
  # Get hostname
  if [[ -s "/etc/hostname" ]]; then
    FromHost=$(cat /etc/hostname)
  elif command -v hostname &>/dev/null; then
    FromHost=$(hostname)
  else
    FromHost="podcheck-host"
  fi
  
  # Set subject tag
  subject_tag="${SMTP_SUBJECT_TAG:-podcheck}"
  subject="[${subject_tag}] ${NOTIFICATION_TITLE:-Notification} on ${FromHost}"
  
  # Send email
  if "$MailPkg" "${SMTP_MAIL_TO}" << __EOF
From: "${FromHost}" <${SMTP_MAIL_FROM}>
Date: $(date -R)
To: <${SMTP_MAIL_TO}>
Subject: ${subject}
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

${NOTIFICATION_MESSAGE}

__EOF
  then
    return 0
  else
    echo "Failed to send SMTP notification"
    return 1
  fi
else
  echo "No notification message provided"
  return 1
fi
