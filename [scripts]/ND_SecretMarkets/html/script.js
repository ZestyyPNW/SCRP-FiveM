let currentDealerId = null;

// Listen for NUI messages from Lua
window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.action === 'showQuestBoard') {
        showQuestBoard(data.data);
    }
});

function showQuestBoard(data) {
    currentDealerId = data.dealerId;
    const questBoard = document.getElementById('questBoard');
    const boardTitle = document.getElementById('boardTitle');
    const questGrid = document.getElementById('questGrid');

    // Set title
    boardTitle.textContent = data.title;

    // Clear existing quests
    questGrid.innerHTML = '';

    // Add quest items
    data.quests.forEach((quest, index) => {
        const questElement = createQuestElement(quest, index);
        questGrid.appendChild(questElement);
    });

    // Show the board
    questBoard.style.display = 'flex';
}

function createQuestElement(quest, index) {
    const questDiv = document.createElement('div');
    questDiv.className = 'quest-item';
    questDiv.style.animationDelay = `${index * 0.05}s`;

    // Get quest type icon
    const typeIcons = {
        'delivery': '🚚',
        'collection': '📋',
        'elimination': '🎯',
        'heist_prep': '💻'
    };

    const icon = typeIcons[quest.metadata.questType] || '📋';

    // Get difficulty info
    const difficulty = getDifficulty(quest.metadata.questType);

    questDiv.innerHTML = `
        <span class="quest-type-icon">${icon}</span>
        <div class="quest-title">${quest.metadata.label}</div>
        <div class="quest-description">${quest.metadata.description}</div>
        <div class="quest-rewards">💰 ${quest.metadata.rewards}</div>
        <div class="quest-meta">
            <span class="quest-difficulty ${difficulty.class}">${difficulty.name}</span>
            <span class="quest-type">${quest.metadata.questType.replace('_', ' ')}</span>
        </div>
    `;

    // Add click handler
    questDiv.addEventListener('click', function() {
        acceptQuest(quest.metadata.questId, quest.metadata.label);
    });

    return questDiv;
}

function getDifficulty(questType) {
    const difficulties = {
        'delivery': { name: 'Easy', class: 'difficulty-easy' },
        'collection': { name: 'Easy', class: 'difficulty-easy' },
        'heist_prep': { name: 'Medium', class: 'difficulty-medium' },
        'elimination': { name: 'Hard', class: 'difficulty-hard' }
    };

    return difficulties[questType] || { name: 'Easy', class: 'difficulty-easy' };
}

function acceptQuest(questId, questTitle) {
    // Show confirmation dialog
    if (confirm(`Accept mission: ${questTitle}?`)) {
        // Send acceptance to Lua
        fetch(`https://${GetParentResourceName()}/acceptQuest`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                dealerId: currentDealerId,
                questId: questId
            })
        });

        closeQuestBoard();
    }
}

function closeQuestBoard() {
    const questBoard = document.getElementById('questBoard');
    questBoard.style.display = 'none';

    // Send close message to Lua
    fetch(`https://${GetParentResourceName()}/closeQuestBoard`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    });
}

// Close on ESC key
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeQuestBoard();
    }
});

// Utility function for resource name
function GetParentResourceName() {
    return 'ND_SecretMarkets';
}