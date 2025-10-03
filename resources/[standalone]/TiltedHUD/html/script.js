let currentHealth = 100;
let currentArmor = 0;
let currentStamina = 100;
let currentFuel = 100;
let isLawEnforcement = false;
let maxStaminaSegments = 5;

// Listen for messages from client
window.addEventListener('message', function(event) {
    const data = event.data;

    // BigDaddy-Fuel integration - intercept their FuelGauge messages
    if (data.action === 'FuelGauge') {
        console.log('[TiltedHUD NUI] Intercepted BigDaddy-Fuel FuelGauge:', data);

        // BigDaddy sends gallons as 0-1 decimal, isCharge = true means show gauge
        if (data.gallons !== undefined && data.gallons !== null) {
            // Convert gallons (0-1 decimal) to percentage (0-100)
            const fuelPercentage = data.gallons * 100;
            console.log('[TiltedHUD NUI] BigDaddy fuel level:', fuelPercentage + '% (isCharge: ' + data.isCharge + ')');

            // Show fuel display
            updateFuel(fuelPercentage);
        } else if (data.isCharge === false) {
            // Explicitly hide when isCharge is false
            console.log('[TiltedHUD NUI] Hiding fuel (isCharge = false)');
            hideFuel();
        }
    }

    if (data.type === 'updateHealth') {
        updateHealth(data.health);
    }

    if (data.type === 'updateArmor') {
        updateArmor(data.armor);
    }

    if (data.type === 'updateStamina') {
        updateStamina(data.stamina);
    }

    if (data.type === 'updateFuel') {
        console.log('[TiltedHUD NUI] Received updateFuel:', data.fuel);
        updateFuel(data.fuel);
    }

    if (data.type === 'setLawEnforcement') {
        setLawEnforcementStatus(data.isLawEnforcement);
    }

    if (data.type === 'setDisplay') {
        setHudDisplay(data.display);
    }

    // New unified HUD message types
    if (data.type === 'updatePriority') {
        updatePriorityStatus(data.zone, data.status, data.user);
    }

    if (data.type === 'updateLocation') {
        updateLocationInfo(data.aop, data.postal, data.street, data.zone);
    }

    if (data.type === 'updateTime') {
        updateTimeDisplay(data.time);
    }

    // Panel visibility toggles
    if (data.type === 'togglePanel') {
        togglePanel(data.panel, data.visible);
    }

    if (data.type === 'openSettings') {
        openSettingsMenu(data.config);
    }

    if (data.type === 'closeSettings') {
        closeSettings();
    }

    if (data.type === 'resetHUD') {
        resetAllPanels();
    }

    if (data.type === 'applyConfig') {
        applyConfigChange(data.setting, data.value);
    }

    // Vehicle state change
    if (data.type === 'updateVehicleState') {
        updateHudPosition(data.inVehicle);
    }

    // Weapon display update
    if (data.type === 'updateWeapon') {
        updateWeaponDisplay(data.weapon);
    }

    // Speed limit updates
    if (data.type === 'updateSpeedLimit') {
        updateSpeedLimit(data.speed);
    }

    if (data.type === 'hideSpeedLimit') {
        hideSpeedLimit();
    }

    // Fuel display control
    if (data.type === 'hideFuel') {
        hideFuel();
    }
});

function updateHealth(health) {
    const healthFill = document.getElementById('health-fill');
    const healthText = document.getElementById('health-text');
    const healthPercentage = Math.max(0, Math.min(100, health));

    if (!healthFill || !healthText) return;

    // Add damage flash effect if health decreased
    if (health < currentHealth) {
        healthFill.classList.add('damage-flash');
        setTimeout(() => {
            healthFill.classList.remove('damage-flash');
        }, 200);
    }

    currentHealth = health;

    // Update health bar width
    healthFill.style.width = healthPercentage + '%';

    // Update health text
    healthText.textContent = Math.round(healthPercentage);

    // Add low health warning
    if (healthPercentage <= 25) {
        healthFill.classList.add('low-health');
        healthText.classList.add('low-health');
    } else {
        healthFill.classList.remove('low-health');
        healthText.classList.remove('low-health');
    }
}

function updateArmor(armor) {
    const armorPercentage = Math.max(0, Math.min(100, armor));
    const armorBars = document.querySelectorAll('.armor-bar');
    const armorText = document.getElementById('armor-text');
    const armorContainer = document.getElementById('armor-container');
    const segmentValue = 20; // Each segment represents 20% armor

    if (!armorText || !armorContainer) return;

    currentArmor = armor;

    // Show/hide armor bar based on value with fade animation
    if (armorPercentage <= 0) {
        // Fade out animation when armor is 0
        armorContainer.style.opacity = '0';
        armorContainer.style.transition = 'opacity 0.5s ease-out';

        // Hide after fade completes
        setTimeout(() => {
            if (currentArmor <= 0) {
                armorContainer.style.display = 'none';
            }
        }, 500);
        return; // Exit early if hiding
    } else {
        // Fade in if hidden
        if (armorContainer.style.display === 'none') {
            armorContainer.style.display = 'flex';
            armorContainer.style.opacity = '0';
            setTimeout(() => {
                armorContainer.style.opacity = '1';
                armorContainer.style.transition = 'opacity 0.3s ease-in';
            }, 10);
        } else {
            armorContainer.style.opacity = '1';
        }
    }

    // Update armor text
    armorText.textContent = Math.round(armorPercentage);

    // Update each armor segment with progressive fill
    armorBars.forEach((bar, index) => {
        const segmentMin = index * segmentValue;
        const segmentMax = (index + 1) * segmentValue;
        const armorFill = bar.querySelector('.armor-fill');

        if (!armorFill) return;

        if (armorPercentage > segmentMin) {
            bar.classList.add('active');
            armorFill.classList.add('active');

            // Calculate fill percentage for this segment - gradual fill/drain within each segment
            const segmentFill = Math.min(100, ((armorPercentage - segmentMin) / segmentValue) * 100);
            armorFill.style.width = segmentFill + '%';
        } else {
            bar.classList.remove('active');
            armorFill.classList.remove('active');
            armorFill.style.width = '0%';
        }
    });
}

function setHudDisplay(display) {
    const hudContainer = document.getElementById('hud-container');
    const priorityPanel = document.getElementById('priority-panel');
    const locationPanel = document.getElementById('location-panel');
    const timePanel = document.getElementById('time-panel');

    if (display) {
        if (hudContainer) hudContainer.style.display = 'flex';
        if (priorityPanel) priorityPanel.style.display = 'block';
        if (locationPanel) locationPanel.style.display = 'block';
        if (timePanel) timePanel.style.display = 'block';
        document.body.classList.remove('hud-hidden');
    } else {
        if (hudContainer) hudContainer.style.display = 'none';
        if (priorityPanel) priorityPanel.style.display = 'none';
        if (locationPanel) locationPanel.style.display = 'none';
        if (timePanel) timePanel.style.display = 'none';
        document.body.classList.add('hud-hidden');
    }
}

function setLawEnforcementStatus(lawEnforcementStatus) {
    isLawEnforcement = lawEnforcementStatus;
    maxStaminaSegments = isLawEnforcement ? 7 : 5;

    const bottomBars = document.querySelector('.stamina-bars-bottom');
    if (isLawEnforcement) {
        bottomBars.style.display = 'flex';
    } else {
        bottomBars.style.display = 'none';
    }
}

function updateStamina(stamina) {
    const staminaBars = document.querySelectorAll('.stamina-bar');
    const staminaText = document.getElementById('stamina-text');
    const staminaContainer = document.getElementById('stamina-container');

    // Calculate max stamina based on law enforcement status
    const maxStamina = isLawEnforcement ? 140 : 100; // 7 segments * 20 = 140, 5 segments * 20 = 100
    const staminaPercentage = Math.max(0, Math.min(maxStamina, stamina));
    const segmentValue = 20; // Each segment represents 20 stamina points

    currentStamina = stamina;

    // Show/hide stamina bar based on value with fade animation
    // Hide if stamina is at or above max (accounting for floating point precision)
    if (stamina >= maxStamina - 0.5) {
        // Fade out animation
        staminaContainer.style.opacity = '0';
        staminaContainer.style.transition = 'opacity 0.5s ease-out';

        // Hide after fade completes
        setTimeout(() => {
            if (currentStamina >= maxStamina - 0.5) {
                staminaContainer.style.display = 'none';
            }
        }, 500);
        return; // Exit early if hiding
    } else {
        // Fade in if hidden
        if (staminaContainer.style.display === 'none') {
            staminaContainer.style.display = 'flex';
            staminaContainer.style.opacity = '0';
            setTimeout(() => {
                staminaContainer.style.opacity = '1';
                staminaContainer.style.transition = 'opacity 0.3s ease-in';
            }, 10);
        } else {
            staminaContainer.style.opacity = '1';
        }
    }

    // Update stamina text
    staminaText.textContent = Math.round(staminaPercentage);

    // Update each stamina segment
    staminaBars.forEach((bar, index) => {
        const segmentMin = index * segmentValue;
        const segmentMax = (index + 1) * segmentValue;
        const staminaFill = bar.querySelector('.stamina-fill');

        // Only show segments up to the max for current role
        if (index >= maxStaminaSegments) {
            bar.style.display = 'none';
            return;
        } else {
            bar.style.display = 'block';
        }

        if (staminaPercentage > segmentMin) {
            bar.classList.add('active');
            staminaFill.classList.add('active');

            // Calculate fill percentage for this segment
            const segmentFill = Math.min(100, ((staminaPercentage - segmentMin) / segmentValue) * 100);
            staminaFill.style.width = segmentFill + '%';

            // Add low stamina warning to active segments when below 25%
            const lowStaminaThreshold = isLawEnforcement ? 35 : 25; // Higher threshold for law enforcement
            if (staminaPercentage <= lowStaminaThreshold) {
                staminaFill.classList.add('low-stamina');
            } else {
                staminaFill.classList.remove('low-stamina');
            }
        } else {
            bar.classList.remove('active');
            staminaFill.classList.remove('active');
            staminaFill.classList.remove('low-stamina');
            staminaFill.style.width = '0%';
        }
    });

    // Update stamina text color
    const lowStaminaThreshold = isLawEnforcement ? 35 : 25;
    if (staminaPercentage <= lowStaminaThreshold) {
        staminaText.classList.add('low-stamina');
    } else {
        staminaText.classList.remove('low-stamina');
    }
}

function updateFuel(fuel) {
    console.log('[TiltedHUD NUI] updateFuel() called with:', fuel);

    const fuelBars = document.querySelectorAll('.fuel-bar');
    const fuelText = document.getElementById('fuel-text');
    const fuelContainer = document.getElementById('fuel-container');
    const segmentValue = 20; // Each segment represents 20% fuel

    console.log('[TiltedHUD NUI] fuelContainer exists:', !!fuelContainer);
    console.log('[TiltedHUD NUI] fuelText exists:', !!fuelText);
    console.log('[TiltedHUD NUI] fuelBars count:', fuelBars.length);

    if (!fuelText || !fuelContainer) {
        console.error('[TiltedHUD NUI] Missing fuel elements!');
        return;
    }

    const fuelPercentage = Math.max(0, Math.min(100, fuel));
    currentFuel = fuel;

    console.log('[TiltedHUD NUI] Current display style:', fuelContainer.style.display);

    // Show/hide fuel bar - always show when in vehicle
    if (fuelContainer.style.display === 'none' || fuelContainer.style.display === '') {
        console.log('[TiltedHUD NUI] Showing fuel container');
        fuelContainer.style.display = 'flex';
        fuelContainer.style.opacity = '0';
        setTimeout(() => {
            fuelContainer.style.opacity = '1';
            fuelContainer.style.transition = 'opacity 0.3s ease-in';
            console.log('[TiltedHUD NUI] Fuel container should now be visible');
        }, 10);
    } else {
        fuelContainer.style.opacity = '1';
    }

    // Update fuel text
    fuelText.textContent = Math.round(fuelPercentage);

    // Update each fuel segment with progressive fill
    fuelBars.forEach((bar, index) => {
        const segmentMin = index * segmentValue;
        const segmentMax = (index + 1) * segmentValue;
        const fuelFill = bar.querySelector('.fuel-fill');

        if (!fuelFill) return;

        if (fuelPercentage > segmentMin) {
            bar.classList.add('active');
            fuelFill.classList.add('active');

            // Calculate fill percentage for this segment - gradual fill/drain within each segment
            const segmentFill = Math.min(100, ((fuelPercentage - segmentMin) / segmentValue) * 100);
            fuelFill.style.width = segmentFill + '%';

            // Add low fuel warning when below 25%
            if (fuelPercentage <= 25) {
                fuelFill.classList.add('low-fuel');
            } else {
                fuelFill.classList.remove('low-fuel');
            }
        } else {
            bar.classList.remove('active');
            fuelFill.classList.remove('active');
            fuelFill.classList.remove('low-fuel');
            fuelFill.style.width = '0%';
        }
    });

    // Update fuel text color for low fuel
    if (fuelPercentage <= 25) {
        fuelText.classList.add('low-fuel');
    } else {
        fuelText.classList.remove('low-fuel');
    }
}

function hideFuel() {
    const fuelContainer = document.getElementById('fuel-container');
    if (fuelContainer) {
        fuelContainer.style.opacity = '0';
        fuelContainer.style.transition = 'opacity 0.5s ease-out';
        setTimeout(() => {
            if (fuelContainer.style.opacity === '0') {
                fuelContainer.style.display = 'none';
            }
        }, 500);
    }
}

// Initialize HUD
document.addEventListener('DOMContentLoaded', function() {
    updateHealth(100);

    // Hide armor, stamina, and fuel initially - they'll appear when needed
    const armorContainer = document.getElementById('armor-container');
    const staminaContainer = document.getElementById('stamina-container');
    const fuelContainer = document.getElementById('fuel-container');

    if (armorContainer) armorContainer.style.display = 'none';
    if (staminaContainer) staminaContainer.style.display = 'none';
    if (fuelContainer) fuelContainer.style.display = 'none';

    setHudDisplay(true);
});

// =================== NEW UNIFIED HUD FUNCTIONS ===================

function updatePriorityStatus(zone, status, user) {
    const statusElement = document.querySelector(`#${zone}-status .zone-status`);
    if (statusElement) {
        // Remove all status classes
        statusElement.classList.remove('available', 'active', 'hold', 'cooldown');

        // Extract base status for CSS class (remove countdown timer if present)
        let baseStatus = status.toLowerCase();
        if (baseStatus.includes('cooldown')) {
            baseStatus = 'cooldown';
        }

        // Add CSS class based on base status
        statusElement.classList.add(baseStatus);

        // Set display text (can include countdown timer)
        statusElement.textContent = status.charAt(0).toUpperCase() + status.slice(1);

        // Add user info if provided and status is active
        if (user && baseStatus === 'active') {
            statusElement.textContent = `Active (${user})`;
        }
    }
}

function updateLocationInfo(aop, postal, street, zone) {
    const aopElement = document.querySelector('#aop-display .info-value');
    const postalElement = document.querySelector('#postal-display .info-value');
    const streetElement = document.querySelector('#street-display .info-value');
    const districtElement = document.querySelector('#district-display .info-value');

    if (aopElement && aop) {
        aopElement.textContent = aop;
    }

    if (postalElement && postal) {
        postalElement.textContent = postal;
    }

    if (streetElement && street) {
        streetElement.textContent = street;
    }

    if (districtElement && zone) {
        districtElement.textContent = zone;
    }
}

function updateTimeDisplay(time) {
    const timeElement = document.getElementById('time-display');
    if (timeElement && time) {
        timeElement.textContent = time;
    }
}

// Utility function to format time
function formatTime(hours, minutes) {
    const h = hours.toString().padStart(2, '0');
    const m = minutes.toString().padStart(2, '0');
    return `${h}:${m}`;
}

// Weapon display function
function updateWeaponDisplay(weapon) {
    const weaponPanel = document.getElementById('weapon-panel');

    if (!weapon || !weapon.name) {
        // Hide weapon panel if no weapon
        if (weaponPanel) {
            weaponPanel.style.display = 'none';
        }
        return;
    }

    // Show weapon panel
    if (weaponPanel) {
        weaponPanel.style.display = 'block';

        // Update weapon name
        const weaponName = document.getElementById('weapon-name');
        if (weaponName) {
            weaponName.textContent = weapon.name || 'Unknown';
        }

        // Update ammo info
        const weaponAmmo = document.getElementById('weapon-ammo');
        const weaponMaxAmmo = document.getElementById('weapon-max-ammo');
        if (weaponAmmo && weaponMaxAmmo) {
            weaponAmmo.textContent = weapon.ammo || 0;
            weaponMaxAmmo.textContent = weapon.maxAmmo || 0;
        }

        // Update clip info
        const weaponClip = document.getElementById('weapon-clip');
        const weaponClipSize = document.getElementById('weapon-clip-size');
        if (weaponClip && weaponClipSize) {
            weaponClip.textContent = weapon.clip || 0;
            weaponClipSize.textContent = weapon.clipSize || 0;
        }

        // Update reserve ammo
        const weaponReserve = document.getElementById('weapon-reserve');
        if (weaponReserve) {
            weaponReserve.textContent = weapon.reserve || 0;
        }
    }
}

// =================== PANEL TOGGLE FUNCTIONS ===================

function togglePanel(panel, visible) {
    let element = null;

    switch(panel) {
        case 'priority':
            element = document.getElementById('priority-panel');
            break;
        case 'location':
            element = document.getElementById('location-panel');
            break;
        case 'time':
            element = document.getElementById('time-panel');
            break;
        case 'health':
            element = document.getElementById('hud-container');
            break;
    }

    if (element) {
        element.style.display = visible ? 'block' : 'none';
    }
}

function resetAllPanels() {
    const priorityPanel = document.getElementById('priority-panel');
    const locationPanel = document.getElementById('location-panel');
    const timePanel = document.getElementById('time-panel');
    const hudContainer = document.getElementById('hud-container');

    if (priorityPanel) priorityPanel.style.display = 'block';
    if (locationPanel) locationPanel.style.display = 'block';
    if (timePanel) timePanel.style.display = 'block';
    if (hudContainer) hudContainer.style.display = 'flex';
}

// =================== SETTINGS MENU FUNCTIONS ===================

function openSettingsMenu(config) {
    // Create settings overlay if it doesn't exist
    let settingsMenu = document.getElementById('settings-menu');

    if (!settingsMenu) {
        settingsMenu = document.createElement('div');
        settingsMenu.id = 'settings-menu';
        settingsMenu.className = 'settings-overlay';
        settingsMenu.innerHTML = `
            <div class="settings-container">
                <h2>HUD Settings</h2>
                <div class="settings-tabs">
                    <button class="tab-btn active" onclick="showTab('display')">Display</button>
                    <button class="tab-btn" onclick="showTab('colors')">Colors</button>
                    <button class="tab-btn" onclick="showTab('position')">Position</button>
                </div>

                <div id="display-tab" class="tab-content active">
                    <h3>Toggle Panels</h3>
                    <label><input type="checkbox" id="toggle-health" checked> Health/Armor</label>
                    <label><input type="checkbox" id="toggle-priority" checked> Priority Status</label>
                    <label><input type="checkbox" id="toggle-location" checked> Location Info</label>
                    <label><input type="checkbox" id="toggle-time" checked> Time Display</label>
                </div>

                <div id="colors-tab" class="tab-content">
                    <h3>Color Settings</h3>
                    <label>Health Bar: <input type="color" id="color-health" value="#ff6666"></label>
                    <label>Armor Bar: <input type="color" id="color-armor" value="#66aaff"></label>
                    <label>Text: <input type="color" id="color-text" value="#ffffff"></label>
                </div>

                <div id="position-tab" class="tab-content">
                    <h3>Panel Positions</h3>
                    <p>Drag panels to reposition them (Coming Soon)</p>
                </div>

                <div class="settings-buttons">
                    <button onclick="saveSettings()">Save</button>
                    <button onclick="closeSettings()">Close</button>
                </div>
            </div>
        `;
        document.body.appendChild(settingsMenu);
    }

    settingsMenu.style.display = 'flex';
}

function closeSettings() {
    const settingsMenu = document.getElementById('settings-menu');
    if (settingsMenu) {
        settingsMenu.style.display = 'none';
    }

    // Tell FiveM to release focus
    const resourceName = (typeof GetParentResourceName === 'function') ? GetParentResourceName() : 'TiltedHUD';
    fetch(`https://${resourceName}/closeSettings`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    });
}

function saveSettings() {
    // Save toggle states
    const panels = ['health', 'priority', 'location', 'time'];
    panels.forEach(panel => {
        const checkbox = document.getElementById(`toggle-${panel}`);
        if (checkbox) {
            togglePanel(panel, checkbox.checked);
        }
    });

    closeSettings();
}

function showTab(tabName) {
    // Hide all tabs
    document.querySelectorAll('.tab-content').forEach(tab => {
        tab.classList.remove('active');
    });
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.remove('active');
    });

    // Show selected tab
    const selectedTab = document.getElementById(`${tabName}-tab`);
    if (selectedTab) selectedTab.classList.add('active');
    if (event && event.target) event.target.classList.add('active');
}


function applyConfigChange(setting, value) {
    // Apply configuration changes dynamically
}

function updateHudPosition(inVehicle) {
    const hudContainer = document.getElementById('hud-container');
    if (hudContainer) {
        if (inVehicle) {
            hudContainer.classList.add('in-vehicle');
        } else {
            hudContainer.classList.remove('in-vehicle');
        }
    } else {
    }
}

function updateSpeedLimit(speed) {
    const speedLimitPanel = document.getElementById('speedlimit-panel');
    const speedLimitValue = document.getElementById('speedlimit-value');

    if (speedLimitPanel && speedLimitValue && speed) {
        speedLimitValue.textContent = speed;
        speedLimitPanel.style.display = 'block';
    }
}

function hideSpeedLimit() {
    const speedLimitPanel = document.getElementById('speedlimit-panel');
    if (speedLimitPanel) {
        speedLimitPanel.style.display = 'none';
    }
}

// Smooth animations
function smoothUpdateHealth(targetHealth) {
    const startHealth = currentHealth;
    const difference = targetHealth - startHealth;
    const duration = 300; // 300ms animation
    const startTime = Date.now();

    function animate() {
        const elapsed = Date.now() - startTime;
        const progress = Math.min(elapsed / duration, 1);

        const currentValue = startHealth + (difference * progress);
        updateHealth(currentValue);

        if (progress < 1) {
            requestAnimationFrame(animate);
        }
    }

    animate();
}