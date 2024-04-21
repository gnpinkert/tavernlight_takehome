--[[
Provided Code


function printSmallGuildNames(memberCount)
    -- this method is supposed to print names of all guilds that have less than memberCount max members
    local selectGuildQuery = "SELECT name FROM guilds WHERE max_members < %d;"
    local resultId = db.storeQuery(string.format(selectGuildQuery, memberCount))
    local guildName = result.getString("name")
    print(guildName)
    end

-- New Code

-- Notes:
    -- Printing all of the guild names rather than just one of the guild names
    -- Checking for edge case of no guilds matching query
    -- Assuming that the Open Tibia Server environment is used for SQL queries
    -- Printing the number of max members as well 
    -- Changed the name to better reflect functionality. 

]]

local function printGuildsBelowMaxMembers(memberCount)
    local selectGuildQuery = "SELECT name, max_members FROM guilds WHERE max_members < %d;"
    local smallGuilds = db.storeQuery(string.format(selectGuildQuery, memberCount))

    if smallGuilds then
        -- Fetch the first row
        local guildName = smallGuilds:getString("name")
        local maxMembers = smallGuilds:getNumber("max_members")

        -- Loop through the result set
        while guildName do
            -- Print the guild name and max_members
            print(string.format("Guild: %s, Max Members: %d", guildName, maxMembers))
            -- Move to the next row and fetch data
            if smallGuilds:next() then
                guildName = smallGuilds:getString("name")
                maxMembers = smallGuilds:getNumber("max_members")
            else
                guildName = nil
            end
        end

        -- Ensure resources are properly released
        smallGuilds:free()
    else
        print("No guilds found with fewer than", memberCount, "members.")
    end

end

printGuildsBelowMaxMembers(10)