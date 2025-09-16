# Migration Guide: v0.6.1 → v0.7.1

## ⚠️ BREAKING CHANGES

**v0.7.1 introduces breaking changes to the notification system. Old configurations will NOT work.**

## What's Changed

### Notification System Rewrite
- **Old**: Single `notify.sh` script with hardcoded logic
- **New**: Modular template system with `podcheck.config` file
- **Impact**: All existing `notify.sh` files must be replaced

### Configuration Requirements
- **Old**: Optional configuration via environment variables
- **New**: **Required** `podcheck.config` file for notifications
- **Impact**: Notifications will not work without proper configuration

## Migration Steps

### Step 1: Backup Your Current Setup
```bash
# If you have an existing notify.sh file
cp notify.sh notify.sh.backup

# If you have environment variables set, note them down
env | grep -E "(PUSHOVER|TELEGRAM|NTFY|SMTP)" > old_config.txt
```

### Step 2: Update Podcheck
```bash
# Pull the latest version
git pull origin main

# Or download the latest release
```

### Step 3: Create Configuration File
```bash
# Copy the template
cp podcheck.config ~/.config/podcheck.config

# Or place it in the same directory as podcheck.sh
cp podcheck.config ./podcheck.config
```

### Step 4: Configure Your Notifications

Edit `~/.config/podcheck.config` and:

1. **Enable your notification channels**:
   ```bash
   NOTIFY_CHANNELS="pushover telegram"  # Add your services
   ```

2. **Add your credentials** (uncomment and fill in):
   ```bash
   # For Pushover:
   PUSHOVER_URL="https://api.pushover.net/1/messages.json"
   PUSHOVER_USER_KEY="your_user_key"
   PUSHOVER_TOKEN="your_app_token"
   
   # For Telegram:
   TELEGRAM_TOKEN="your_bot_token"
   TELEGRAM_CHAT_ID="your_chat_id"
   ```

### Step 5: Test Your Setup
```bash
# Test notifications
./podcheck.sh -i

# You should see: "Notification sent successfully"
```

### Step 6: Clean Up Old Files
```bash
# Remove old notification file (if you have one)
rm notify.sh

# Remove backup once you're satisfied
rm notify.sh.backup old_config.txt
```

## New Features Available

### 13 Notification Services
- Pushover, Telegram, ntfy.sh, SMTP, Matrix, Pushbullet
- Apprise, Discord, Gotify, Slack, Home Assistant
- Synology DSM, Generic (custom)

### Advanced Options
- Multiple channels per service type
- Snooze functionality
- Output formats (text, json, csv)
- Per-channel customization

### Enhanced Compatibility
- Complete parity with dockcheck v0.7.1 features
- Preserved Quadlet container support
- Cross-platform compatibility

## Troubleshooting

### "No notification channels configured"
- Check that `NOTIFY_CHANNELS` is set in your config file
- Ensure the config file is in the right location

### "Error: [SERVICE] must be configured"
- Check that you've uncommented and filled in the required variables
- Verify your credentials are correct

### Old notify.sh file interfering
- Remove any old `notify.sh` files from your podcheck directory
- The system will automatically use the new template system

## Need Help?

1. Check the `NOTIFICATION_GUIDE.md` for detailed setup instructions
2. Review the `podcheck.config` file for all available options
3. Test individual templates: `./notify_templates/notify_pushover.sh`

## Rollback Instructions

If you need to temporarily rollback to v0.6.1:

```bash
# Checkout the previous version
git checkout v0.6.1

# Or restore your backup
cp notify.sh.backup notify.sh
```

**Note**: We recommend migrating to v0.7.1 as it provides much better functionality and maintainability.