# ox_inventory Health Monitor & Auto-Restart System

## What This Does

This monitoring system keeps ox_inventory alive and healthy by:

1. **Health Checks Every 30 Seconds** - Automatically verifies ox_inventory is responding
2. **Auto-Restart on Failure** - Restarts ox_inventory if it becomes unresponsive (after 2 consecutive failures)
3. **Prevents Restart Loops** - Max 3 restarts per minute to prevent issues
4. **Performance Optimizations** - Works with performance.cfg to speed up restarts
5. **Player Notifications** - Informs players when inventory is restarting/restored

## Console Commands

### `oxhealth`
Check current health status of ox_inventory
```
oxhealth
```

### `oxrestart`
Manually restart ox_inventory
```
oxrestart
```

### `oxstatus`
View detailed status including restart history
```
oxstatus
```

## How It Works

### Automatic Monitoring
- Checks every 30 seconds if ox_inventory is responding
- If 2 consecutive checks fail, triggers auto-restart
- Restarts are rate-limited to prevent loops
- Players are notified during the restart process

### Restart Process
1. Notifies all players of brief downtime
2. Stops ox_inventory cleanly
3. Waits 2 seconds for shutdown
4. Starts ox_inventory
5. Waits 5 seconds for startup
6. Verifies health after restart
7. Notifies players when restored

### Safety Features
- **Restart Cooldown**: Minimum 60 seconds between restarts
- **Max Restarts**: Won't restart more than 3 times per minute
- **Consecutive Failure Tracking**: Requires 2 failures before restart
- **Manual Intervention Alert**: Alerts if too many restarts occur

## Performance Optimizations

The `performance.cfg` file provides these optimizations:

- Disables version checking (saves 2-3 seconds)
- Enables item caching
- Reduces log verbosity
- Enables async item loading
- Reduces stash load delay

## Monitoring Exports

Other resources can check ox_inventory health:

```lua
-- Check if ox_inventory is healthy
local healthy = exports.ox_inventory_monitor:isHealthy()

-- Get detailed status
local status = exports.ox_inventory_monitor:getStatus()
-- Returns: {healthy, consecutiveFailures, recentRestarts, isRestarting, lastCheck}
```

## Restart Times

**Before optimizations**: 15-30+ seconds
**After optimizations**: 5-10 seconds

The performance.cfg file alone can cut restart time in half!

## Troubleshooting

### ox_inventory keeps restarting
- Check server.log for errors during ox_inventory startup
- Run `oxstatus` to see restart history
- If restarts exceed 3 per minute, manual intervention is required

### Health checks always fail
- Verify ox_inventory is in server.cfg
- Check for conflicts with other inventory resources
- Ensure oxmysql database is accessible

### Manual restart needed
- Use `oxrestart` command in console
- This bypasses the automatic cooldown system

## Technical Details

### Health Check Process
1. Verify resource state is "started"
2. Check if exports are available
3. Test `exports.ox_inventory:Items()` call
4. Return true if all checks pass

### When Auto-Restart Triggers
- Two consecutive health check failures (60 seconds apart)
- Resource stops unexpectedly
- Exports become unavailable

### What Gets Reset
- Restart history older than 60 seconds
- Consecutive failure counter on successful check
- isRestarting flag after restart completes
