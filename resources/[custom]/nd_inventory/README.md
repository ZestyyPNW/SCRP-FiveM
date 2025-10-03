# ND Inventory

A custom-built inventory system for NDCore framework.

## Features (v1.0 - MVP)

✅ **Core Functionality:**
- Player inventory with 50 slots
- Drag and drop items between slots
- Weight system (30kg max)
- Item stacking
- Weapon slot restrictions (slots 1-2 for weapons only)
- Ground/drop inventory (24 slots)
- Clean, simple UI

✅ **Completed:**
- Server-side inventory management
- Client-side NUI with drag & drop
- Database integration (MySQL)
- Item system with JSON configuration
- Test commands

🚧 **In Progress:**
- Weapon equip/unequip
- Vehicle storage (trunk/glovebox)
- Drop system with world props
- Shop system
- Crafting system
- Container system (backpacks)

## Installation

1. **Ensure dependencies are started before nd_inventory:**
   - ox_lib
   - oxmysql
   - NDCore

2. **Add to server.cfg:**
   ```
   ensure nd_inventory
   ```

3. **Database:**
   The system uses the existing `characters` table with an `inventory` column (JSON).
   Make sure your characters table has an `inventory` TEXT column.

## Usage

### Opening Inventory
- Press `I` to open/close inventory
- Drag items between slots or to ground
- Items will respect slot restrictions (weapons in slots 1-2 only)

### Admin Commands

```
/giveitem [itemname] [count]  - Give yourself an item
/clearinv                      - Clear your inventory
```

### Testing

1. Join server
2. Type: `/giveitem water 5`
3. Press `I` to open inventory
4. You should see 5x water in your pockets
5. Try dragging items around
6. Drag to ground section to drop (creates default ground inventory)

## Item Configuration

Edit `items.json` to add/modify items. Example:

```json
{
    "name": "water",
    "label": "Water Bottle",
    "weight": 500,
    "stack": true,
    "close": true,
    "description": "A refreshing bottle of water",
    "weapon": false
}
```

### Item Properties:
- `name`: Unique identifier
- `label`: Display name
- `weight`: Weight in grams
- `stack`: Can items stack?
- `close`: Close inventory on use?
- `description`: Item description
- `weapon`: Is this a weapon? (goes in slots 1-2)
- `ammoname`: For weapons, what ammo does it use?

## Exports

### Server-side
```lua
exports['nd_inventory']:AddItem(inventoryId, itemName, count, metadata)
exports['nd_inventory']:RemoveItem(inventoryId, slot, count)
exports['nd_inventory']:GetInventory(inventoryId)
exports['nd_inventory']:CreateInventory(id, type, slots, maxWeight, items)
```

### Client-side
```lua
exports['nd_inventory']:OpenInventory(secondaryInventory)
exports['nd_inventory']:CloseInventory()
```

## Known Limitations (v1.0)

- No weapon system yet (weapons won't equip)
- No vehicle storage yet
- No shop/crafting systems yet
- Ground drops don't create world props yet (just inventory UI)
- No container/backpack system yet

These features will be added in future updates.

## Troubleshooting

**Inventory won't open:**
- Check F8 console for errors
- Ensure ox_lib is started
- Check that NDCore character is loaded

**Items not showing images:**
- Add PNG files to `ui/build/images/` folder
- File name must match item name (e.g., `water.png`)

**Database errors:**
- Ensure characters table has `inventory` TEXT column
- Check oxmysql is configured correctly

## Support

This is a custom-built system. Report issues or request features as needed.
