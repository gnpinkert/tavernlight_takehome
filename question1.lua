--Provided Code

local function releaseStorage(player)
    player:setStorageValue(1000, -1)
end
    
function onLogout(player)
    if player:getStorageValue(1000) == 1 then
        addEvent(releaseStorage, 1000, player)
    end
    return true
end




-- Notes: 
    -- Making all functions local since we don't know if they are used outside
    -- current scope.

    -- Creating a player class

local scheduledEvents = {}

-- Function to add an event to be executed on an object
local function addEvent(event, callback, player)
    local eventEntry = {
        event = event,
        callback = callback,
        player = player
    }
    table.insert(scheduledEvents, eventEntry)
end

-- Function to handle events
local function handleEvents(event)
    for i = #scheduledEvents, 1, -1 do
        local eventEntry = scheduledEvents[i]
        if eventEntry.event == event then
            -- Execute the callback with the object as argument
            eventEntry.callback(eventEntry.player)
            -- Remove the event from the list
            table.remove(scheduledEvents, i)
        end
    end
end

local Player = {}
local storageKey = 1000

-- Define a constructor function
function Player.new(name)
    local self = { storage = {} }  -- Create a new object (instance)
    self.name = name
    setmetatable(self, { __index = Player })  -- Set the metatable to MyClass
    return self
end

function Player:overwriteStorage(key, value)
    -- The implementation of this function is largely dependent on the use case
    -- If there isn't much data to store, then we can just save the value as a class 
    -- member. If the data is so large that memory space becomes a concern, perhaps
    -- we want to save the data in a database, or we want data to persist across runs.

    -- For the sake of this exercise, I will assume that data is small and we will save as a member
    if self.storage[key] ~= nil then
        print(string.format("Overwriting current storage key '%d' with current value '%d'", key, value))
    end

    self.storage[key] = value

end

local function onLogout(player)
    if player.storage[storageKey] == 1 then    -- Doesn't make since to have a function for accessing data when there isn't functionality for private members
        print("Clearing storage at key '" .. storageKey .. "' with value '" .. player.storage[storageKey] .. "'")
        player.storage[storageKey] = -1
    end
    -- removing return value of true. It always returned true, which is, in essence, a void.
end

local myPlayer = Player.new("Grant")

myPlayer.storage[storageKey] = 1

addEvent("logout", onLogout, myPlayer)




handleEvents("logout")