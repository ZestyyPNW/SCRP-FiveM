
function display(bool) {
    if (bool) {
        $("body").fadeIn(500);
        // Add entrance animation to character cards
        setTimeout(() => {
            $('.character-card').each(function(index) {
                $(this).css('animation-delay', `${index * 0.1}s`);
                $(this).addClass('fadeIn');
            });
        }, 100);
        return;
    }
    $("body").fadeOut(300);
}

// Add smooth transitions for menu displays
function displayMenuWithTransition(menu, status) {
    if (status) {
        $(`#${menu}`).css({
            'opacity': '0',
            'transform': 'scale(0.9) translateY(20px)'
        }).show().animate({
            'opacity': '1'
        }, 300, function() {
            $(this).css('transform', 'scale(1) translateY(0)');
        });

        menus.forEach(item => {
            if (!item.includes(menu)) {
                $(item).hide();
            }
        });
        return;
    }
    $(`#${menu}`).animate({
        'opacity': '0'
    }, 200, function() {
        $(this).hide().css({
            'transform': 'scale(0.9) translateY(20px)'
        });
    });
}

// Global variables
const menus = ["#characterCreator", "#characterEditor", "#exitGameMenu", "#deleteCharacterMenu", "#spawnLocation"];
let characterEdited = null;
let characterDeleting = null;

// Notification system
function showNotification(message, type = 'info') {
    const notification = $(`
        <div class="notification ${type}" style="
            position: fixed;
            top: 20px;
            right: 20px;
            background: ${type === 'error' ? 'linear-gradient(135deg, #e74c3c, #c0392b)' : 'linear-gradient(135deg, #27ae60, #229954)'};
            color: white;
            padding: 16px 20px;
            border-radius: 8px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.3);
            z-index: 9999;
            opacity: 0;
            transform: translateX(100%);
            transition: all 0.3s ease;
            font-weight: 500;
            max-width: 300px;
        ">
            <i class="fas ${type === 'error' ? 'fa-exclamation-circle' : 'fa-check-circle'}" style="margin-right: 8px;"></i>
            ${message}
        </div>
    `);

    $('body').append(notification);

    // Animate in
    setTimeout(() => {
        notification.css({
            'opacity': '1',
            'transform': 'translateX(0)'
        });
    }, 100);

    // Animate out after 3 seconds
    setTimeout(() => {
        notification.css({
            'opacity': '0',
            'transform': 'translateX(100%)'
        });
        setTimeout(() => notification.remove(), 300);
    }, 3000);
}

// Enhanced form interactions
$(document).ready(function() {
    // Add focus effects to inputs
    $('input, select').on('focus', function() {
        $(this).parent().addClass('focused');
    }).on('blur', function() {
        $(this).parent().removeClass('focused');
    });

    // Add character counter for name fields
    $('#firstName, #lastName, #newFirstName, #newLastName').on('input', function() {
        const maxLength = 20;
        const currentLength = $(this).val().length;
        const parent = $(this).parent();

        // Remove existing counter
        parent.find('.char-counter').remove();

        if (currentLength > maxLength * 0.8) {
            const counter = $(`<small class="char-counter" style="color: ${currentLength > maxLength ? '#e74c3c' : '#f39c12'}; float: right; font-size: 11px;">${currentLength}/${maxLength}</small>`);
            parent.append(counter);
        }
    });
});
function displayMenu(menu, status) {
    if (status) {
        $(`#${menu}`).fadeIn("slow");
        menus.forEach(item => {
            if (!item.includes(menu)) {
                $(item).hide();
            }
        });
        return;
    }
    $(`#${menu}`).fadeOut("slow");
}

function createCharacter(firstName, lastName, dateOfBirth, gender, ethnicity, department, id) {
    const job = department ? ` • ${department}` : '';
    const fullName = `${firstName} ${lastName}`;
    const isLongName = (fullName + job).length > 24;

    const characterCard = `
        <div class="character-card fadeIn" data-character-id="${id}" style="animation-delay: ${id * 0.1}s">
            <div class="character-info">
                <div class="character-name ${isLongName ? 'animated' : ''}">
                    <span>${fullName}${job}</span>
                </div>
                <div class="character-details">
                    ${gender} • ${ethnicity} • ${dateOfBirth}
                </div>
            </div>
            <div class="character-actions">
                <button id="characterButton${id}" class="createdButton">
                    <i class="fas fa-play"></i>
                    Play
                </button>
                <button id="characterButtonEdit${id}" class="createdButtonEdit">
                    <i class="fas fa-edit"></i>
                </button>
                <button id="characterButtonDelete${id}" class="createdButtonDelete">
                    <i class="fas fa-trash-alt"></i>
                </button>
            </div>
        </div>
    `;

    $("#charactersSection").append(characterCard);

    // Click on character card to preview
    $(`.character-card[data-character-id="${id}"]`).click(function(e) {
        // Don't trigger if clicking on buttons
        if ($(e.target).closest('button').length) return;

        // Remove selected class from all cards
        $('.character-card').removeClass('selected');
        // Add selected class to this card
        $(this).addClass('selected');

        // Send message to Lua to focus camera on this character
        $.post(`https://${GetParentResourceName()}/previewCharacter`, JSON.stringify({
            id: id
        }));
    });

    $(`#characterButton${id}`).click(function(e) {
        e.stopPropagation();
        displayMenu("spawnLocation", true);
        $.post(`https://${GetParentResourceName()}/setMainCharacter`, JSON.stringify({
            id: id
        }));
        return;
    });

    $(`#characterButtonEdit${id}`).click(function(e) {
        e.stopPropagation();
        displayMenu("characterEditor", true);
        $("#newFirstName").val(firstName);
        $("#newLastName").val(lastName);
        $("#newDateOfBirth").val(dateOfBirth);
        $("#newGender").val(gender);
        $("#newTwtName").val(ethnicity);
        $("#newDepartment").val(department);
        characterEdited = id
        return;
    });

    $(`#characterButtonDelete${id}`).click(function(e) {
        e.stopPropagation();
        displayMenu("deleteCharacterMenu", true);
        characterDeleting = id
        return;
    });
}

$("#characterCreator").submit(function(e) {
    e.preventDefault();

    // Add form validation
    const firstName = $("#firstName").val().trim();
    const lastName = $("#lastName").val().trim();
    const dateOfBirth = $("#dateOfBirth").val();
    const gender = $("#gender").val();
    const ethnicity = $("#twtName").val().trim();
    const department = $("#department").val();

    // Basic validation
    if (!firstName || !lastName || !dateOfBirth || !gender || !ethnicity) {
        showNotification('Please fill in all required fields', 'error');
        return false;
    }

    if (firstName.length < 2 || lastName.length < 2) {
        showNotification('Names must be at least 2 characters long', 'error');
        return false;
    }

    // Disable submit button temporarily
    $("#submitCharacterCreation").prop('disabled', true).text('Creating...');

    $.post(`https://${GetParentResourceName()}/newCharacter`, JSON.stringify({
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
        gender: gender,
        ethnicity: ethnicity,
        department: department
    }));

    displayMenu("characterCreator", false);
    $("#firstName, #lastName, #dateOfBirth, #twtName").val("");
    $("#gender, #department").val("");

    // Re-enable button
    setTimeout(() => {
        $("#submitCharacterCreation").prop('disabled', false).html('<i class="fas fa-plus-circle"></i> Create Character');
    }, 1000);

    return false;
});

$("#characterEditor").submit(function() {
    displayMenu("characterEditor", false);
    $.post(`https://${GetParentResourceName()}/editCharacter`, JSON.stringify({
        firstName: $("#newFirstName").val(),
        lastName: $("#newLastName").val(),
        dateOfBirth: $("#newDateOfBirth").val(),
        gender: $("#newGender").val(),
        ethnicity: $("#newTwtName").val(),
        department: $("#newDepartment").val(),
        id: characterEdited
    }));
    return false;
});

$("#deleteCharacterConfirm").click(function() {
    displayMenu("deleteCharacterMenu", false);

    // Find and remove the character card container
    $(`#characterButton${characterDeleting}`).closest('.character-card').fadeOut("slow", function(){
        $(this).remove();
    });

    $.post(`https://${GetParentResourceName()}/delCharacter`, JSON.stringify({
        character: characterDeleting
    }));
    return;
});

$("#newCharacterButton").click(function() {
    displayMenu("characterCreator", true);
    return;
});

$("#deleteCharacterCancel").click(function() {
    displayMenu("deleteCharacterMenu", false);
    return;
});
$("#cancelCharacterCreation").click(function() {
    displayMenu("characterCreator", false);
    return;
});
$("#cancelCharacterEditing").click(function() {
    displayMenu("characterEditor", false);
    return;
});

$("#tpCancel").click(function() {
    displayMenu("spawnLocation", false);
    setTimeout(function(){
        $("#spawnMenuContainer").empty();
    }, 550);
    return;
});

$("#quitGameButton").click(function() {
    displayMenu("exitGameMenu", true);
    return;
});
$("#exitGameCancel").click(function() {
    displayMenu("exitGameMenu", false);
    return;
});
$("#exitGameConfirm").click(function() {
    $.post(`https://${GetParentResourceName()}/exitGame`);
    return;
});

$(document).on("click", ".spawnButtons", function() {
    const th = $(this)
    $.post(`https://${GetParentResourceName()}/tpToLocation`, JSON.stringify({
        x: th.data("x"),
        y: th.data("y"),
        z: th.data("z"),
        id: th.data("id")
    }));
    displayMenu("spawnLocation", false);
    setTimeout(function(){
        $("#spawnMenuContainer").empty();
    }, 550);
    return;
});
$(document).on("click", "#tpDoNot", function() {
    $.post(`https://${GetParentResourceName()}/tpDoNot`, JSON.stringify({
        id: $("#tpDoNot").data("id")
    }));
    displayMenu("spawnLocation", false);
    setTimeout(function(){
        $("#spawnMenuContainer").empty();
    }, 550);
    return;
});

window.addEventListener("message", function(event) {
    const item = event.data;

    if (item.type === "ui") {
        if (item.status) {
            $("#serverName").text(item.serverName);
            // $("body").css("background-image", `url(../images/${item.background})`);
            $("#playerAmount").text(`(${item.characterAmount})`);
            display(true);
        } else {
            display(false);
        }
    }

    if (item.type === "setSpawns") {
        $("#spawnMenuContainer").empty();
        setTimeout(function(){
            $("#tpDoNot").data("id", item.id);
            JSON.parse(item.spawns).forEach((location) => {
                $("#spawnMenuContainer").append(`<button class="spawnButtons" data-x="${location.coords.x}" data-y="${location.coords.y}" data-z="${location.coords.z}" data-id="${item.id}">${location.label}</button>`);
            });
        }, 10);
    }

    if (item.type === "firstSpawn") {
        $("#tpDoNot").html(`<a class="fas fa-compass" style="color:white;"></a> Do not teleport`)
    }

    if (item.type === "givePerms") {
        $(".departments").empty();
        JSON.parse(item.deptRoles).forEach((job) => {
            $(".departments").append(`<option value="${job.name}">${job.label}</option>`);
        });
    }

    if (item.type === "aop") {
        $("#aop").text(`AOP: ${item.aop}`);
    }

    if (item.type === "refresh") {
        $("#charactersSection").empty();
        displayMenu("characterCreator", false);
        let characters = JSON.parse(item.characters)
        Object.keys(characters).forEach((id) => {
            const char = characters[id]
            if (char) {
                createCharacter(
                    char.firstname || "",
                    char.lastname || "",
                    char.dob || "",
                    char.gender || "",
                    char.metadata.ethnicity || "",
                    char.jobInfo?.label || char.job || "",
                    char.id || "",
                );
            }
        });
        if (item.characterAmount) {
            $("#playerAmount").text(`(${item.characterAmount})`);
        }
    }

    if (item.type === "logo" && item.logo) {
        $("#logo").attr("src", `../images/${item.logo}`);
    }
})
