-- Temporary file to check database tables
CreateThread(function()
    Wait(3000) -- Wait for oxmysql to be ready

    print('[nd_inventory] Checking database tables...')

    MySQL.Async.fetchAll('SHOW TABLES', {}, function(tables)
        print('[nd_inventory] Available tables in database:')
        for i, table in ipairs(tables) do
            local tableName = table[next(table)] -- Get first column value
            print('  - ' .. tostring(tableName))
        end
    end)
end)
