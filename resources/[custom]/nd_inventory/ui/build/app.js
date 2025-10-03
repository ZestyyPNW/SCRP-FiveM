// ND Inventory UI
console.log('[ND Inventory] UI script loaded');

let playerInventory = null;
let secondaryInventory = null;
let draggedItem = null;

// Utility: Send data to client
function sendNUI(action, data = {}) {
    fetch(`https://nd_inventory/${action}`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(data)
    });
}

// Close inventory on ESC
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        closeInventory();
    }
});

// Open inventory
function openInventory(data) {
    console.log('[ND Inventory] Opening inventory with data:', data);

    playerInventory = data.playerInventory;
    secondaryInventory = data.secondaryInventory;

    renderInventory('player-inventory', playerInventory, 'player');
    if (secondaryInventory) {
        renderInventory('secondary-inventory', secondaryInventory, 'secondary');
    } else {
        // Create default ground inventory
        secondaryInventory = createDefaultGroundInventory();
        renderInventory('secondary-inventory', secondaryInventory, 'secondary');
    }

    updateWeightDisplays();
    document.getElementById('inventory-container').classList.remove('hidden');
    console.log('[ND Inventory] Inventory opened successfully');
}

// Close inventory
function closeInventory() {
    document.getElementById('inventory-container').classList.add('hidden');
    sendNUI('closeInventory');
}

// Create default ground inventory (for dropping items)
function createDefaultGroundInventory() {
    const items = [];
    for (let i = 1; i <= 24; i++) {
        items.push({slot: i});
    }

    return {
        id: 'ground',
        type: 'ground',
        slots: 24,
        maxWeight: 30000,
        items: items,
        weight: 0
    };
}

// Render inventory grid
function renderInventory(containerId, inventory, side) {
    const container = document.getElementById(containerId);
    container.innerHTML = '';

    if (!inventory || !inventory.items) return;

    inventory.items.forEach((item, index) => {
        const slotDiv = document.createElement('div');
        slotDiv.className = 'inventory-slot';
        slotDiv.dataset.slot = item.slot || (index + 1);
        slotDiv.dataset.side = side;

        // Mark weapon slots
        if (side === 'player' && item.slot <= 2) {
            slotDiv.classList.add('weapon-slot');
        }

        // Slot number
        const slotNumber = document.createElement('div');
        slotNumber.className = 'slot-number';
        slotNumber.textContent = item.slot || (index + 1);
        slotDiv.appendChild(slotNumber);

        if (item.name) {
            // Item image
            const img = document.createElement('img');
            img.className = 'slot-image';
            img.src = `images/${item.image || item.name}.png`;
            img.onerror = () => {
                img.src = 'images/placeholder.png';
            };
            slotDiv.appendChild(img);

            // Item label
            const label = document.createElement('div');
            label.className = 'slot-label';
            label.textContent = item.label || item.name;
            slotDiv.appendChild(label);

            // Item count
            if (item.count > 1) {
                const count = document.createElement('div');
                count.className = 'slot-count';
                count.textContent = item.count;
                slotDiv.appendChild(count);
            }

            // Make draggable
            slotDiv.draggable = true;
            slotDiv.addEventListener('dragstart', handleDragStart);
        }

        // Drag events
        slotDiv.addEventListener('dragover', handleDragOver);
        slotDiv.addEventListener('drop', handleDrop);
        slotDiv.addEventListener('dragleave', handleDragLeave);

        container.appendChild(slotDiv);
    });
}

// Drag start
function handleDragStart(e) {
    console.log('[ND Inventory] Drag started');
    const slot = e.target.closest('.inventory-slot');
    draggedItem = {
        side: slot.dataset.side,
        slot: parseInt(slot.dataset.slot)
    };
    slot.classList.add('dragging');
    console.log('[ND Inventory] Dragging item from slot:', draggedItem);
}

// Drag over
function handleDragOver(e) {
    e.preventDefault();
    const slot = e.target.closest('.inventory-slot');
    if (slot && !slot.classList.contains('dragging')) {
        slot.classList.add('drag-over');
    }
}

// Drag leave
function handleDragLeave(e) {
    const slot = e.target.closest('.inventory-slot');
    if (slot) {
        slot.classList.remove('drag-over');
    }
}

// Drop
function handleDrop(e) {
    e.preventDefault();
    console.log('[ND Inventory] Drop event triggered');

    const targetSlot = e.target.closest('.inventory-slot');
    if (!targetSlot || !draggedItem) {
        console.log('[ND Inventory] Drop cancelled - no target or no dragged item');
        return;
    }

    const targetSide = targetSlot.dataset.side;
    const targetSlotNum = parseInt(targetSlot.dataset.slot);

    console.log('[ND Inventory] Dropping to slot:', targetSlotNum, 'side:', targetSide);

    // Remove drag styling
    document.querySelectorAll('.dragging').forEach(el => el.classList.remove('dragging'));
    document.querySelectorAll('.drag-over').forEach(el => el.classList.remove('drag-over'));

    // Don't allow dropping on same slot
    if (draggedItem.side === targetSide && draggedItem.slot === targetSlotNum) {
        console.log('[ND Inventory] Drop cancelled - same slot');
        draggedItem = null;
        return;
    }

    // Get inventory IDs
    const fromInv = draggedItem.side === 'player' ? playerInventory.id : secondaryInventory.id;
    const toInv = targetSide === 'player' ? playerInventory.id : secondaryInventory.id;

    console.log('[ND Inventory] Moving item:', {
        fromInv: fromInv,
        fromSlot: draggedItem.slot,
        toInv: toInv,
        toSlot: targetSlotNum
    });

    // Send move request to server
    sendNUI('moveItem', {
        fromInv: fromInv,
        fromSlot: draggedItem.slot,
        toInv: toInv,
        toSlot: targetSlotNum,
        count: null // Move entire stack
    });

    draggedItem = null;
}

// Update weight displays
function updateWeightDisplays() {
    if (playerInventory) {
        document.getElementById('player-weight').textContent = (playerInventory.weight / 1000).toFixed(1) + 'kg';
        document.getElementById('player-max-weight').textContent = (playerInventory.maxWeight / 1000).toFixed(1) + 'kg';
    }

    if (secondaryInventory) {
        document.getElementById('secondary-weight').textContent = (secondaryInventory.weight / 1000).toFixed(1) + 'kg';
        document.getElementById('secondary-max-weight').textContent = (secondaryInventory.maxWeight / 1000).toFixed(1) + 'kg';
    }
}

// Refresh inventory
function refreshInventory(data) {
    playerInventory = data.playerInventory || playerInventory;
    secondaryInventory = data.secondaryInventory || secondaryInventory;

    renderInventory('player-inventory', playerInventory, 'player');
    renderInventory('secondary-inventory', secondaryInventory, 'secondary');
    updateWeightDisplays();
}

// Listen for messages from client
window.addEventListener('message', (event) => {
    const data = event.data;

    switch(data.action) {
        case 'openInventory':
            openInventory(data);
            break;
        case 'closeInventory':
            closeInventory();
            break;
        case 'refreshInventory':
            refreshInventory(data);
            break;
    }
});
