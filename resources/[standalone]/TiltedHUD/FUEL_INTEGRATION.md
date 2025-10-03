# BigDaddy-Fuel Integration Guide

The TiltedHUD now includes **native BigDaddy-Fuel integration** with a fuel gauge that matches the design aesthetic of the health/armor/stamina bars.

## ✅ Auto-Integration

**No additional setup required!** TiltedHUD automatically connects to BigDaddy-Fuel and displays fuel levels when you enter a vehicle.

The integration uses:
1. **Entity State Bags** (`Entity(vehicle).state.fuel`)
2. **Decorators** (fallback: `_FUEL_LEVEL`)
3. **Real-time updates** via state bag change handlers

## Features

- **5-segment fuel bar** with gradient fill (orange/yellow)
- **Low fuel warning** (turns red and pulses when fuel ≤ 25%)
- **Smooth animations** (fade in/out, segment fill/drain)
- **Auto-show/hide** when entering/exiting vehicles
- **Percentage display** next to the fuel icon
- **Tilted perspective** matching the rest of the HUD

## Visual Design

- **Icon**: ⛽ (fuel pump emoji - can be replaced with image)
- **Color**: Orange-yellow gradient (#ffaa44 to #ffcc66)
- **Low Fuel**: Red gradient (#ff4444 to #ff6666) with pulsing animation
- **Positioning**: Below stamina bar in bottom-left HUD container
- **Segments**: 5 bars, each representing 20% fuel

## Testing the Integration

### Debug Commands

Use these commands to test the fuel display:

```
/checkfuel   - Check current vehicle's fuel data (state bag & decor)
/setfuel 75  - Manually set fuel display to 75% (for testing UI)
/hidefuel    - Hide the fuel display
```

## Usage in Client-Side Scripts (Advanced)

### Manual Fuel Update (if needed)

```lua
-- Update fuel level manually (0-100)
SendNUIMessage({
    type = 'updateFuel',
    fuel = GetVehicleFuelLevel(vehicle) -- or your fuel system's value
})
```

### Show Fuel When Entering Vehicle

```lua
CreateThread(function()
    local wasInVehicle = false

    while true do
        Wait(500)
        local ped = PlayerPedId()
        local inVehicle = IsPedInAnyVehicle(ped, false)

        if inVehicle and not wasInVehicle then
            -- Player just entered vehicle
            local vehicle = GetVehiclePedIsIn(ped, false)
            local fuelLevel = GetVehicleFuelLevel(vehicle) -- or your fuel system

            SendNUIMessage({
                type = 'updateFuel',
                fuel = fuelLevel
            })

            wasInVehicle = true
        elseif not inVehicle and wasInVehicle then
            -- Player just exited vehicle
            SendNUIMessage({
                type = 'hideFuel'
            })

            wasInVehicle = false
        end
    end
end)
```

### Continuous Fuel Monitoring

```lua
CreateThread(function()
    while true do
        Wait(1000) -- Update every second

        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local vehicle = GetVehiclePedIsIn(ped, false)
            local fuelLevel = GetVehicleFuelLevel(vehicle) -- or your fuel system

            SendNUIMessage({
                type = 'updateFuel',
                fuel = fuelLevel
            })
        end
    end
end)
```

## How It Works

TiltedHUD automatically monitors BigDaddy-Fuel through:

1. **Vehicle Entry Detection** - Detects when you enter a vehicle
2. **State Bag Monitoring** - Watches `Entity(vehicle).state.fuel` for changes
3. **Decorator Fallback** - Falls back to `_FUEL_LEVEL` decorator if needed
4. **Real-time Updates** - Updates fuel display every second while in vehicle
5. **Auto-Hide** - Hides fuel display when you exit the vehicle

**You don't need to modify BigDaddy-Fuel or add any events!**

## Customization

### Change Fuel Colors

Edit `html/style.css` at line ~319:

```css
.fuel-fill {
    background: linear-gradient(90deg, #YOUR_COLOR_1, #YOUR_COLOR_2);
}

.fuel-fill.low-fuel {
    background: linear-gradient(90deg, #YOUR_LOW_FUEL_COLOR_1, #YOUR_LOW_FUEL_COLOR_2);
}
```

### Change Low Fuel Threshold

Edit `html/script.js` at line ~352 and ~366:

```javascript
if (fuelPercentage <= 25) { // Change 25 to your desired threshold
    fuelFill.classList.add('low-fuel');
}
```

### Change Number of Segments

Edit `html/index.html` (add/remove fuel-bar divs) and update:

```javascript
const segmentValue = 20; // Change to 100/numberOfSegments
```

## Icon Customization

To replace the emoji with an image:

1. Add your fuel icon image to `html/imgs/fuel.png`
2. Edit `html/index.html` line ~126:
   ```html
   <img src="imgs/fuel.png" class="stat-icon fuel-icon" alt="⛽">
   ```
3. Remove the `.fuel-icon` font-size styling from `html/style.css`

## API Functions

The fuel system listens for these NUI message types:

- `updateFuel` - Update fuel level (0-100)
- `hideFuel` - Hide the fuel display

## Notes

- Fuel display automatically shows when vehicle is entered
- Fuel display automatically hides when vehicle is exited
- Low fuel warning activates at 25% or below
- Segments fill/drain smoothly and progressively
- Fully responsive and matches existing HUD design

## Compatibility

**Natively Integrated:**
- ✅ **BigDaddy-Fuel** (automatic integration via state bags & decorators)

**Also Works With:**
- LegacyFuel (requires manual integration via exports)
- Custom fuel systems (requires manual integration)
- Any resource that can send NUI messages

---

## Requirements

- BigDaddy-Fuel must be started **before** TiltedHUD
- TiltedHUD v2.1.0 or higher

---

**Created for TiltedHUD v2.1.0**
**BigDaddy-Fuel Integration by Claude Code**
