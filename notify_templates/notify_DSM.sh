#!/usr/bin/env bash

# Synology DSM notification template for podcheck v2
# Uses existing DSM email configuration automatically
# Optional: DSM_SENDMAILTO, DSM_SUBJECTTAG to override defaults

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

# Prepare the DSM email
if [[ -n "${NOTIFICATION_MESSAGE:-}" ]]; then
  # Get hostname
  if [[ -s "/etc/hostname" ]]; then
    FromHost=$(cat /etc/hostname)
  elif command -v hostname &>/dev/null; then
    FromHost=$(hostname)
  else
    FromHost="podcheck-host"
  fi
  
  # DSM configuration file
  CfgFile="/usr/syno/etc/synosmtp.conf"
  
  # Get email settings from DSM config or use provided ones
  if [[ -n "${DSM_SENDMAILTO:-}" ]]; then
    SendMailTo="${DSM_SENDMAILTO}"
  elif [[ -f "$CfgFile" ]]; then
    SendMailTo=$(grep 'eventmail1' "$CfgFile" 2>/dev/null | sed -n 's/.*"\([^"]*\)".*/\1/p')
  else
    echo "Error: DSM_SENDMAILTO not configured and $CfgFile not found"
    return 1
  fi
  
  if [[ -z "$SendMailTo" ]]; then
    echo "Error: Could not determine recipient email address"
    return 1
  fi
  
  # Get subject tag and sender info from DSM config or use provided/defaults
  if [[ -n "${DSM_SUBJECTTAG:-}" ]]; then
    SubjectTag="${DSM_SUBJECTTAG}"
  elif [[ -f "$CfgFile" ]]; then
    SubjectTag=$(grep 'eventsubjectprefix' "$CfgFile" 2>/dev/null | sed -n 's/.*"\([^"]*\)".*/\1/p')
    SubjectTag="${SubjectTag:-[DSM]}"
  else
    SubjectTag="[DSM]"
  fi
  
  if [[ -f "$CfgFile" ]]; then
    SenderName=$(grep 'smtp_from_name' "$CfgFile" 2>/dev/null | sed -n 's/.*"\([^"]*\)".*/\1/p')
    SenderMail=$(grep 'smtp_from_mail' "$CfgFile" 2>/dev/null | sed -n 's/.*"\([^"]*\)".*/\1/p')
    SenderMail=${SenderMail:-$(grep 'eventmail1' "$CfgFile" 2>/dev/null | sed -n 's/.*"\([^"]*\)".*/\1/p')}
  fi
  SenderName="${SenderName:-$FromHost}"
  SenderMail="${SenderMail:-$SendMailTo}"
  
  # Send email
  if "$MailPkg" "$SendMailTo" << __EOF
From: "$SenderName" <$SenderMail>
Date: $(date -R)
To: <$SendMailTo>
Subject: $SubjectTag ${NOTIFICATION_TITLE:-Notification} on $FromHost
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

${NOTIFICATION_MESSAGE}

From $SenderName
__EOF
  then
    # Trigger DSM's container manager update check if available
    if [[ -x "/var/packages/ContainerManager/target/tool/image_upgradable_checker" ]]; then
      /var/packages/ContainerManager/target/tool/image_upgradable_checker &>/dev/null || true
    fi
    return 0
  else
    echo "Failed to send DSM notification"
    return 1
  fi
else
  echo "No notification message provided"
  return 1
fi
