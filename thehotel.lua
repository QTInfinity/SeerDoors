-- Importing the Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
-- Optional: Enabling secure mode for detection reduction (uncomment if needed)
-- getgenv().SecureMode = true
-- Creating the main window with configuration saving enabled
local Window = Rayfield:CreateWindow({
    Name = "ESP Menu",
    LoadingTitle = "Rayfield Interface Suite",
    LoadingSubtitle = "by Sirius",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MyGameESP",
        FileName = "ESPConfig"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
})

-- Creating tabs for UI
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local ConfigTab = Window:CreateTab("Config", 4483362458)

-- Creating sections for ESP Options and Configurations
local ESPSection = VisualsTab:CreateSection("ESP Options")
local ConfigSection = ConfigTab:CreateSection("Config")

-- Default services and player setup
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Centralized tables for ESP objects
local GeneralTable = {
    ESPStorage = {
        Doors = {},
        Entity = {},
        Chests = {},
        Gold = {},
        Guiding = {},
        Targets = {}, -- Renamed from Items
        Items = {},   -- New Items ESP
        Players = {},
        Hideables = {}
    },
    ESPNames = {
        DoorsName = { "Door" },
        EntityName = { "RushMoving", "AmbushMoving", "BackdoorRush", "Eyes" },
        ChestName = { "Chest", "Toolshed_Small" },
        GoldName = { "GoldPile" },
        GuidingName = { "GuidingLight" },
        TargetsName = { "KeyObtain", "LeverForGate", "LiveHintBook" },  -- Renamed from Items
        ItemsName = { "Crucifix" },  -- New Items ESP starts with Crucifix, more to be added
        PlayersName = {},  -- Dynamic, handled per player
        HideablesName = { "Closet", "Bed" }
    }
}

-- Function to apply general ESP (used for doors, entity, etc.)
local function ApplyESP(object, color)
    local highlight = Instance.new("Highlight")
    highlight.Parent = object
    highlight.FillColor = color or Color3.fromRGB(0, 255, 0)
    highlight.FillTransparency = 0.75
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    return highlight
end

-- Function to clear ESP for a specific type
local function ClearESP(type)
    for object, highlight in pairs(GeneralTable.ESPStorage[type]) do
        if highlight then
            highlight:Destroy()
        end
    end
    GeneralTable.ESPStorage[type] = {} -- Clear the table
end

-- Advanced item condition function (from mspaint)
local function IsValidItem(item)
    return item:IsA("Model") and (item:GetAttribute("Pickup") or item:GetAttribute("PropType")) and not item:GetAttribute("FuseID")
end

-- General ESP management function
local function ManageESPByType(type, nameTable, color, filterFunction)
    ClearESP(type)
    local currentRoom = Workspace.CurrentRooms[tostring(LocalPlayer:GetAttribute("CurrentRoom"))]
    if currentRoom then
        for _, object in ipairs(currentRoom:GetDescendants()) do
            for _, name in ipairs(GeneralTable.ESPNames[nameTable]) do
                -- If a filter function is provided (like for Items), use it
                if object.Name == name and (not filterFunction or filterFunction(object)) then
                    GeneralTable.ESPStorage[type][object] = ApplyESP(object, color)
                end
            end
        end
    end
end

-- Specific ESP managers
local function ManageDoorESP()
    ManageESPByType("Doors", "DoorsName", Color3.fromRGB(0, 255, 0))
end

local function ManageEntityESP()
    ClearESP("Entity")
    -- First check in the player's current room
    local currentRoom = Workspace.CurrentRooms[tostring(LocalPlayer:GetAttribute("CurrentRoom"))]
    if currentRoom then
        for _, object in ipairs(currentRoom:GetDescendants()) do
            for _, name in ipairs(GeneralTable.ESPNames.EntityName) do
                if object.Name == name then
                    GeneralTable.ESPStorage.Entity[object] = ApplyESP(object, Color3.fromRGB(255, 100, 0))
                end
            end
        end
    end
    -- Then check globally in the workspace (for entities like RushMoving or AmbushMoving)
    for _, object in ipairs(Workspace:GetDescendants()) do
        for _, name in ipairs(GeneralTable.ESPNames.EntityName) do
            if object.Name == name then
                GeneralTable.ESPStorage.Entity[object] = ApplyESP(object, Color3.fromRGB(255, 0, 0))
            end
        end
    end
end

local function ManageGoldESP()
    ManageESPByType("Gold", "GoldName", Color3.fromRGB(255, 215, 0))
end

local function ManageGuidingESP()
    ManageESPByType("Guiding", "GuidingName", Color3.fromRGB(0, 255, 255))
end

-- Renamed former "Items" to Targets
local function ManageTargetsESP()
    ManageESPByType("Targets", "TargetsName", Color3.fromRGB(255, 0, 100))
end

-- New Items ESP using the ItemCondition filter
local function ManageItemsESP()
    ManageESPByType("Items", "ItemsName", Color3.fromRGB(0, 255, 100), IsValidItem)
end

local function ManagePlayerESP()
    ClearESP("Players")
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                GeneralTable.ESPStorage.Players[player] = ApplyESP(character, Color3.fromRGB(0, 255, 255))
            end
        end
    end
end

local function ManageHideablesESP()
    ManageESPByType("Hideables", "HideablesName", Color3.fromRGB(255, 255, 255))
end

-- Event handler for room change, instant application of ESP
local function OnRoomChange()
    ManageDoorESP()
    ManageEntityESP()
    ManageGoldESP()
    ManageGuidingESP()
    ManageTargetsESP()  -- Renamed from Items
    ManageItemsESP()     -- New Items ESP
    ManagePlayerESP()
    ManageHideablesESP()
end

-- Detect room changes and apply ESP instantly without delay
local function MonitorRoomChanges()
    OnRoomChange()
    LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(OnRoomChange)
end
MonitorRoomChanges()

-- Adding toggles for the new ESP types
VisualsTab:CreateToggle({
    Name = "Door ESP",
    CurrentValue = false,
    Flag = "DoorESP",
    Callback = function(state)
        if state then
            ManageDoorESP()
        else
            ClearESP("Doors")
        end
    end,
})

VisualsTab:CreateToggle({
    Name = "Entity ESP",
    CurrentValue = false,
    Flag = "EntityESP",
    Callback = function(state)
        if state then
            ManageEntityESP()
        else
            ClearESP("Entity")
        end
    end,
})

VisualsTab:CreateToggle({
    Name = "Gold ESP",
    CurrentValue = false,
    Flag = "GoldESP",
    Callback = function(state)
        if state then
            ManageGoldESP()
        else
            ClearESP("Gold")
        end
    end,
})

VisualsTab:CreateToggle({
    Name = "Guiding ESP",
    CurrentValue = false,
    Flag = "GuidingESP",
    Callback = function(state)
        if state then
            ManageGuidingESP()
        else
            ClearESP("Guiding")
        end
    end,
})

VisualsTab:CreateToggle({
    Name = "Targets ESP",  -- Renamed from Items
    CurrentValue = false,
    Flag = "TargetsESP",
    Callback = function(state)
        if state then
            ManageTargetsESP()
        else
            ClearESP("Targets")
        end
    end,
})

VisualsTab:CreateToggle({
    Name = "Items ESP",  -- New Items ESP
    CurrentValue = false,
    Flag = "ItemsESP",
    Callback = function(state)
        if state then
            ManageItemsESP()
        else
            ClearESP("Items")
        end
    end,
})

VisualsTab:CreateToggle({
    Name = "Players ESP",
    CurrentValue = false,
    Flag = "PlayersESP",
    Callback = function(state)
        if state then
            ManagePlayerESP()
        else
            ClearESP("Players")
        end
    end,
})

VisualsTab:CreateToggle({
    Name = "Hideables ESP",
    CurrentValue = false,
    Flag = "HideablesESP",
    Callback = function(state)
        if state then
            ManageHideablesESP()
        else
            ClearESP("Hideables")
        end
    end,
})

-- Button to unload the script
ConfigSection:CreateButton({
    Name = "Unload",
    Callback = function()
        Rayfield:Destroy()
        print("ESP Menu Unloaded")
    end,
})

-- Notify the user
Rayfield:Notify({
    Title = "ESP Loaded",
    Content = "The ESP system is now active.",
    Duration = 6.5,
    Image = 4483362458,
    Actions = {
        Ignore = {
            Name = "Okay",
            Callback = function()
                print("The user tapped Okay!")
            end
        },
    },
})

-- Load the configuration if saved
Rayfield:LoadConfiguration()
