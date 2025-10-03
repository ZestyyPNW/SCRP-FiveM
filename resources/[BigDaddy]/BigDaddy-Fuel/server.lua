
framework = 'custom' --VALUES CAN BE 'nat', 'qb', 'esx', 'nd', 'bigdaddy' or 'custom'

reason = 'Fuel Purchase'  --reason for the transaction will notify using framework methods

useSociety = false
toSocietyaccount = ''
local currencySymbol = '$'

if framework == 'nat' then
    print('Framework set to nat')
elseif framework == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject()
elseif framework == 'esx' then
    ESX = exports["es_extended"]:getSharedObject()
elseif framework == 'nd' then
    NDCore = exports["ND_Core"]
elseif framework == 'bigdaddy' then
    print('Framework set to Big Daddy')
elseif framework == 'custom' then
    print('LOAD CORE OBJECT HERE IF REQUIRED, if not then you may disregard this statement.')
else
    print('FRAMEWORK IS NOT SET PROPERLY FOR RESOURCE! Check server.lua in ' .. GetCurrentResourceName() .. ' for money events. The current value is set to ' .. framework .. ', and this is not a valid selection.' )
end

RegisterNetEvent('BigDaddy-Fuel:CreditCheck', function(playerId)
	local src = source
    if framework == 'nat' then
        local account = exports.money:getaccount(src)
        if (tonumber(account.bank) <= 75) then
			TriggerClientEvent('BigDaddy-Fuel:CreditCheckResult', src, false)
		else
			TriggerClientEvent('BigDaddy-Fuel:CreditCheckResult', src, true)
        end
    elseif framework == 'qb' then
        local Player = QBCore.Functions.GetPlayer(src)
		if (Player.Functions.GetMoney('bank') <= 75) then
			TriggerClientEvent('BigDaddy-Fuel:CreditCheckResult', src, false)
		else
			TriggerClientEvent('BigDaddy-Fuel:CreditCheckResult', src, true)
        end
    elseif framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        local account = xPlayer.getAccount('bank')
		if (account.money <= 75) then
			TriggerClientEvent('BigDaddy-Fuel:CreditCheckResult', src, false)
		else
			TriggerClientEvent('BigDaddy-Fuel:CreditCheckResult', src, true)
        end
    elseif framework == 'nd' then
        local Player = NDCore:getPlayer(src)
		if (tonumber(Player.bank) <= 75) then
			TriggerClientEvent('BigDaddy-Fuel:CreditCheckResult', src, false)
		else
			TriggerClientEvent('BigDaddy-Fuel:CreditCheckResult', src, true)
        end
    elseif framework == 'bigdaddy' then
		local account = exports['BigDaddy-Money']:GetAccounts(src, playerId, -1)
		if account ~= "" then
			local data = json.decode(account)
			if (tonumber(data.bank) <= 75) then
				TriggerClientEvent('BigDaddy-Fuel:CreditCheckResult', src, false)
			else
				TriggerClientEvent('BigDaddy-Fuel:CreditCheckResult', src, true)
			end
		end
    elseif framework == 'custom' then
        --INSERT CUSTOM CODE HERE FOR CASH MANAGEMENT
		TriggerClientEvent('BigDaddy-Fuel:CreditCheckResult', src, true)
    else
        print('FRAMEWORK IS NOT SET PROPERLY FOR RESOURCE! Check server.lua in ' .. GetCurrentResourceName() .. ' for money events. The current value is set to ' .. framework .. ', and this is not a valid selection.' )
    end
end)

RegisterNetEvent('BigDaddy-Fuel:Pay', function(amount, playerId)
    local src = source

    if framework == 'nat' then
        local account = exports.money:getaccount(src)
        local newbalance = tonumber(account.bank) - tonumber(amount)
        exports.money:updateaccount(src, {cash = account.amount, bank = newbalance})
        exports.money:bankNotify(src, reason .. ' ' .. currencySymbol .. amount )
    elseif framework == 'qb' then
        local Player = QBCore.Functions.GetPlayer(src)
        Player.Functions.RemoveMoney('bank', tonumber(amount), reason)
        if (useSociety) then
            exports['qb-management']:AddMoney(toSocietyaccount, tonumber(amount))
        end
        TriggerClientEvent('QBCore:Notify', src, reason, 'primary', 5000)
    elseif framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        xPlayer.removeAccountMoney('bank', tonumber(amount))
        xPlayer.showNotification(reason)
    elseif framework == 'nd' then
        local Player = NDCore:getPlayer(src)
        Player.DeductMoney('bank', amount, reason)
    elseif framework == 'bigdaddy' then
        local account = exports["BigDaddy-Money"]:GetAccounts(src, playerId)
		if account ~= "" then
            local data = json.decode(account)
            local newbalance = tonumber(data.bank) - tonumber(amount)
            exports['BigDaddy-Money']:UpdateTotals(src, newbalance, data.cash, data.dirty, -1)
            TriggerClientEvent("BigDaddy-Money:Notify", src, 'Paid ' .. currencySymbol .. string.format("%.2f", amount) .. ' ' .. reason)
        end
    elseif framework == 'custom' then
        --INSERT CUSTOM CODE HERE FOR CASH MANAGEMENT
    else
        print('FRAMEWORK IS NOT SET PROPERLY FOR RESOURCE! Check server.lua in ' .. GetCurrentResourceName() .. ' for money events. The current value is set to ' .. framework .. ', and this is not a valid selection.' )
    end
end)