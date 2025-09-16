# Podcheck v0.7.1 Notification System - Complete Guide

## Overview

Podcheck now includes a comprehensive notification system with 12 different notification templates, matching dockcheck's notification coverage. All templates have been standardized to use the v2 pattern with consistent environment variable configuration.

## Available Notification Templates

### Core Templates (Standard)
1. **notify_apprise.sh** - Universal notification gateway
2. **notify_discord.sh** - Discord webhooks  
3. **notify_gotify.sh** - Self-hosted push notifications
4. **notify_ntfy.sh** - Open-source push service (renamed from notify_ntfy-sh.sh)
5. **notify_pushbullet.sh** - Cross-platform notifications
6. **notify_pushover.sh** - iOS/Android push notifications
7. **notify_smtp.sh** - Email notifications
8. **notify_telegram.sh** - Telegram bot notifications

### Extended Templates (dockcheck compatibility)
9. **notify_DSM.sh** - Synology DSM notifications
10. **notify_generic.sh** - Generic webhook/curl template
11. **notify_HA.sh** - Home Assistant webhook (**NEW**)
12. **notify_matrix.sh** - Matrix protocol notifications
13. **notify_slack.sh** - Slack webhook notifications (**NEW**)

## Configuration

### Basic Setup in podcheck.config

```bash
# Enable notification system
NOTIFY=true

# Configure notification channels (space-separated)
NOTIFY_CHANNELS="telegram pushover slack"

# Optional: Snooze identical notifications (seconds)
SNOOZE_SECONDS=3600

# Optional: Disable specific notification types
DISABLE_PODCHECK_NOTIFICATION=false
DISABLE_NOTIFY_NOTIFICATION=false
```

### Service-Specific Configuration

#### Telegram
```bash
TELEGRAM_BOT_TOKEN="your_bot_token"
TELEGRAM_CHAT_ID="your_chat_id"
```

#### Pushover
```bash
PUSHOVER_USER_KEY="your_user_key"
PUSHOVER_TOKEN="your_app_token"
PUSHOVER_URL="https://api.pushover.net/1/messages.json"
```

#### Slack (NEW)
```bash
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/your/webhook/url"
SLACK_CHANNEL="#podcheck"  # Optional
SLACK_USERNAME="podcheck"   # Optional
SLACK_ICON=":whale:"        # Optional
```

#### Home Assistant (NEW)
```bash
HA_URL="https://your-ha-instance.com"
HA_TOKEN="your_long_lived_access_token"
HA_WEBHOOK_ID="automation"  # Optional, defaults to 'automation'
```

#### Matrix
```bash
MATRIX_SERVER="https://matrix.org"
MATRIX_ACCESS_TOKEN="your_access_token"
MATRIX_ROOM_ID="!room:matrix.org"
```

#### SMTP
```bash
SMTP_SERVER="smtp.gmail.com"
SMTP_PORT="587"
SMTP_USERNAME="your_email@gmail.com"
SMTP_PASSWORD="your_app_password"
SMTP_TO="recipient@example.com"
SMTP_FROM="podcheck@your-domain.com"
```

#### ntfy.sh
```bash
NTFY_URL="https://ntfy.sh"
NTFY_TOPIC="your-topic"
NTFY_TOKEN="your_token"     # Optional for private topics
```

#### Gotify
```bash
GOTIFY_URL="https://your-gotify-server.com"
GOTIFY_TOKEN="your_app_token"
```

#### Pushbullet
```bash
PUSHBULLET_ACCESS_TOKEN="your_access_token"
PUSHBULLET_DEVICE_ID="your_device_id"  # Optional
```

#### Apprise
```bash
APPRISE_URL="tgram://bottoken/ChatID/"  # Example Telegram URL
# Supports many services - see Apprise documentation
```

#### Discord
```bash
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/your/webhook"
```

#### DSM (Synology)
```bash
DSM_URL="https://your-synology-nas.com:5001"
DSM_USERNAME="your_dsm_username"
DSM_PASSWORD="your_dsm_password"
```

#### Generic Webhook
```bash
GENERIC_WEBHOOK_URL="https://your-webhook-endpoint.com/notify"
GENERIC_WEBHOOK_METHOD="POST"  # Optional, defaults to POST
```

### Advanced Channel Configuration

Each channel supports advanced configuration options:

```bash
# Output format per channel
TELEGRAM_OUTPUT="text"     # text, json, csv
SLACK_OUTPUT="json"

# Allow empty notifications
TELEGRAM_ALLOWEMPTY="false"
SLACK_ALLOWEMPTY="true"

# Skip snooze for specific channels
TELEGRAM_SKIPSNOOZE="false"
SLACK_SKIPSNOOZE="true"

# Only send container update notifications
TELEGRAM_CONTAINERSONLY="true"

# Use custom template
SLACK_TEMPLATE="generic"   # Use notify_generic.sh for slack channel
```

## Key Differences from Dockcheck

### Architecture Choice
- **Dockcheck**: Uses complex `trigger_*_notification()` function pattern with advanced variable substitution
- **Podcheck**: Uses simpler script execution pattern with direct environment variable passing

### Why We Chose the Simpler Pattern
1. **Easier to maintain** - Individual scripts are self-contained
2. **Easier to debug** - Each template can be tested independently  
3. **Platform compatibility** - Works consistently across different shells
4. **Quadlet compatibility** - Preserves our core differentiator

### What's the Same
- ✅ **All notification services** supported (12 templates)
- ✅ **Configuration variables** use same names as dockcheck
- ✅ **Message formatting** compatible with dockcheck expectations
- ✅ **Snooze functionality** prevents spam notifications
- ✅ **Multiple output formats** (text, json, csv)
- ✅ **Advanced channel options** (allowempty, skipsnooze, containersonly)

### What's Different
- 🔄 **Function calls**: We use script execution instead of function calls
- 🔄 **Error handling**: Simpler error handling without complex channel removal
- 🔄 **Template loading**: Direct file sourcing instead of dynamic function discovery

## Testing Notifications

To test a specific notification channel:

```bash
# Test telegram notification
NOTIFICATION_TITLE="Test" NOTIFICATION_MESSAGE="Test message" ./notify_templates/notify_telegram.sh

# Test all configured channels
./podcheck.sh -i
```

## Migration from Older Versions

If upgrading from podcheck v0.6.0 or earlier:

1. Update your `podcheck.config` to use `NOTIFY_CHANNELS` instead of individual notification flags
2. Rename `notify_ntfy-sh.sh` configurations to `notify_ntfy.sh` (we handle this automatically)
3. Add new Home Assistant and Slack configurations if needed

## Summary

✅ **Complete dockcheck notification parity achieved**  
✅ **12 notification templates available**  
✅ **Consistent v2 pattern across all templates**  
✅ **New templates added**: Home Assistant, Slack  
✅ **Template naming corrected**: ntfy.sh (was ntfy-sh.sh)  
✅ **Like-for-like functionality** with simplified architecture

The notification system now provides complete feature parity with dockcheck v0.7.1 while maintaining podcheck's core advantages (Quadlet support, simpler architecture).